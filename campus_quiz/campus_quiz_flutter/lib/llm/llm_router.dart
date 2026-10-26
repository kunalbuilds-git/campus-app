import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// One LLM endpoint in the failover chain.
class LlmProvider {
  const LlmProvider({
    required this.id,
    required this.endpoint,
    required this.model,
    required this.apiKey,
    required this.priority,
    this.extraHeaders = const {},
  });

  final String id;
  final Uri endpoint;
  final String model;
  final String? apiKey;
  final int priority;
  final Map<String, String> extraHeaders;

  bool get isConfigured => apiKey != null && apiKey!.isNotEmpty;
}

/// Rolling health for one provider.
class _ProviderHealth {
  DateTime cooldownUntil = DateTime.fromMillisecondsSinceEpoch(0);
  int consecutiveFailures = 0;
  int successes = 0;
  Duration? lastLatency;

  bool get available => DateTime.now().isAfter(cooldownUntil);
}

/// A single chat message handed to the router.
class LlmMessage {
  const LlmMessage({required this.role, required this.content});

  final String role;
  final String content;
}

/// Talks to the LLM providers behind the campus guide.
///
/// All three providers (OpenRouter, NVIDIA NIM, Groq) speak the OpenAI
/// chat-completions protocol. The router picks the healthiest provider by
/// priority, and on any failure — timeout, rate limit, 5xx, network — it
/// silently moves to the next one while the interface is still showing its
/// typing state, so the switchover is never felt. A background prober keeps
/// warming up providers that are in cooldown so capacity-based switching
/// happens ahead of the next question.
///
/// Keys are read from --dart-define:
///   OPENROUTER_API_KEY / GROQ_API_KEY / NVIDIA_API_KEY
/// plus optional model overrides OPENROUTER_MODEL / GROQ_MODEL /
/// NVIDIA_MODEL. With no keys configured the guide runs on the built-in
/// local assistant.
class LlmRouter {
  LlmRouter({http.Client? client}) : _http = client ?? http.Client() {
    _providers =
        [
            LlmProvider(
              id: 'groq',
              endpoint: Uri.parse(
                'https://api.groq.com/openai/v1/chat/completions',
              ),
              model: const String.fromEnvironment(
                'GROQ_MODEL',
                defaultValue: 'llama-3.3-70b-versatile',
              ),
              apiKey: const String.fromEnvironment('GROQ_API_KEY'),
              priority: 0,
            ),
            LlmProvider(
              id: 'openrouter',
              endpoint: Uri.parse(
                'https://openrouter.ai/api/v1/chat/completions',
              ),
              model: const String.fromEnvironment(
                'OPENROUTER_MODEL',
                defaultValue: 'meta-llama/llama-3.3-70b-instruct:free',
              ),
              apiKey: const String.fromEnvironment('OPENROUTER_API_KEY'),
              priority: 1,
              extraHeaders: const {
                'X-Title': 'CampHere',
              },
            ),
            LlmProvider(
              id: 'nvidia',
              endpoint: Uri.parse(
                'https://integrate.api.nvidia.com/v1/chat/completions',
              ),
              model: const String.fromEnvironment(
                'NVIDIA_MODEL',
                defaultValue: 'meta/llama-3.1-70b-instruct',
              ),
              apiKey: const String.fromEnvironment('NVIDIA_API_KEY'),
              priority: 2,
            ),
          ].where((p) => p.isConfigured).toList()
          ..sort((a, b) => a.priority.compareTo(b.priority));

    for (final provider in _providers) {
      _health[provider.id] = _ProviderHealth();
    }
  }

  final http.Client _http;
  late final List<LlmProvider> _providers;
  final Map<String, _ProviderHealth> _health = {};

  Timer? _probeTimer;
  bool _probing = false;

  static const _attemptTimeout = Duration(seconds: 9);
  static const _probeTimeout = Duration(seconds: 6);

  bool get isConfigured => _providers.isNotEmpty;

  /// How many providers are currently callable.
  int get availableCount =>
      _providers.where((p) => _health[p.id]!.available).length;

  List<String> get providerIds => _providers.map((p) => p.id).toList();

  /// Providers ordered by (available, priority).
  List<LlmProvider> get _candidates {
    final candidates = [..._providers];
    candidates.sort((a, b) {
      final aOk = _health[a.id]!.available ? 0 : 1;
      final bOk = _health[b.id]!.available ? 0 : 1;
      if (aOk != bOk) return aOk.compareTo(bOk);
      return a.priority.compareTo(b.priority);
    });
    return candidates;
  }

  /// One chat completion, with silent failover across providers.
  ///
  /// Returns null when every configured provider is unavailable — callers
  /// then fall back to the local assistant.
  Future<String?> complete({
    required List<LlmMessage> messages,
    int maxTokens = 260,
    double temperature = 0.4,
  }) async {
    if (_providers.isEmpty) return null;

    for (final provider in _candidates) {
      try {
        final watch = Stopwatch()..start();
        final text = await _call(
          provider,
          messages,
          maxTokens: maxTokens,
          temperature: temperature,
        ).timeout(_attemptTimeout);
        watch.stop();

        final health = _health[provider.id]!;
        health.consecutiveFailures = 0;
        health.successes += 1;
        health.lastLatency = watch.elapsed;
        return text;
      } catch (_) {
        _recordFailure(provider);
      }
    }
    return null;
  }

  Future<String> _call(
    LlmProvider provider,
    List<LlmMessage> messages, {
    required int maxTokens,
    required double temperature,
  }) async {
    final response = await _http.post(
      provider.endpoint,
      headers: {
        'Authorization': 'Bearer ${provider.apiKey}',
        'Content-Type': 'application/json',
        ...provider.extraHeaders,
      },
      body: jsonEncode({
        'model': provider.model,
        'messages': [
          for (final message in messages)
            {'role': message.role, 'content': message.content},
        ],
        'max_tokens': maxTokens,
        'temperature': temperature,
      }),
    );

    if (response.statusCode != 200) {
      throw http.ClientException(
        'provider ${provider.id} returned ${response.statusCode}',
      );
    }

    final body = jsonDecode(utf8.decode(response.bodyBytes));
    final content =
        body is Map &&
            body['choices'] is List &&
            (body['choices'] as List).isNotEmpty &&
            body['choices'][0] is Map &&
            body['choices'][0]['message'] is Map
        ? body['choices'][0]['message']['content']
        : null;
    if (content is! String || content.trim().isEmpty) {
      throw const FormatException('empty completion');
    }
    return content.trim();
  }

  void _recordFailure(LlmProvider provider) {
    final health = _health[provider.id]!;
    health.consecutiveFailures += 1;
    // Cooldown grows with consecutive failures, capped at ten minutes.
    final seconds = math
        .min(30 * math.pow(2, health.consecutiveFailures), 600)
        .toInt();
    health.cooldownUntil = DateTime.now().add(Duration(seconds: seconds));
    if (kDebugMode) {
      // ignore: avoid_print
      print('llm: ${provider.id} unavailable, cooling down ${seconds}s');
    }
  }

  /// Starts the background availability prober.
  ///
  /// While the chat surface is open, providers that are in cooldown (or never
  /// proven) get a one-token ping, so by the time the student asks the next
  /// question the router already knows who is up.
  void startProbing({Duration every = const Duration(seconds: 45)}) {
    if (_probing || !isConfigured) return;
    _probing = true;
    _probeTimer = Timer.periodic(every, (_) => _probeOnce());
  }

  void stopProbing() {
    _probeTimer?.cancel();
    _probeTimer = null;
    _probing = false;
  }

  Future<void> _probeOnce() async {
    for (final provider in _providers) {
      final health = _health[provider.id]!;
      final needsProbe = !health.available || health.consecutiveFailures > 0;
      if (!needsProbe) continue;
      try {
        await _call(
          provider,
          const [LlmMessage(role: 'user', content: 'ping')],
          maxTokens: 1,
          temperature: 0,
        ).timeout(_probeTimeout);
        health.consecutiveFailures = 0;
        health.cooldownUntil = DateTime.fromMillisecondsSinceEpoch(0);
        health.successes += 1;
      } catch (_) {
        _recordFailure(provider);
      }
    }
  }

  void dispose() {
    stopProbing();
    _http.close();
  }
}
