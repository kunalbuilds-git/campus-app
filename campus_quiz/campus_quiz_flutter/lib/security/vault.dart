import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// AES-256-GCM vault for the small pieces of data the app keeps on the
/// device.
///
/// The key never travels: a 256-bit key is generated on first use and stored
/// in the platform's credential store (Keychain / Keystore / encrypted
/// preferences). Everything written through [encryptJson] is sealed with a
/// fresh 96-bit nonce and an authentication tag, so a tampered blob simply
/// fails to open.
class Vault {
  const Vault._();

  static const _keyName = 'camphere.aes256.key.v1';
  static final AesGcm _aes = AesGcm.with256bits();
  static final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();

  static Uint8List? _memoryKey;
  static bool _platformKeyAvailable = true;

  /// The vault key: platform credential store when possible, a process-local
  /// key otherwise (web previews without secure storage), never hardcoded.
  static Future<Uint8List> _key() async {
    if (_memoryKey != null) return _memoryKey!;

    if (_platformKeyAvailable) {
      try {
        final stored = await _secureStorage.read(key: _keyName);
        if (stored != null) {
          return Uint8List.fromList(base64Url.decode(stored));
        }
        final generated = Uint8List.fromList(
          List<int>.generate(32, (_) => Random.secure().nextInt(256)),
        );
        await _secureStorage.write(
          key: _keyName,
          value: base64Url.encode(generated),
        );
        return generated;
      } catch (_) {
        // No credential store in this context (e.g. a plain web preview).
        _platformKeyAvailable = false;
      }
    }

    // Process-local key: encryption still applies, but the ciphertext only
    // outlives the session if the platform can hold the key.
    _memoryKey = Uint8List.fromList(
      List<int>.generate(32, (_) => Random.secure().nextInt(256)),
    );
    return _memoryKey!;
  }

  /// Seals [data] into a portable envelope:
  /// `{"v":1,"n":…,"c":…,"m":…}` — version, nonce, ciphertext, tag.
  static Future<String> encryptJson(Map<String, Object?> data) async {
    final key = await _key();
    final nonce = _aes.newNonce();
    final secretBox = await _aes.encrypt(
      utf8.encode(jsonEncode(data)),
      secretKey: SecretKey(key),
      nonce: nonce,
    );
    return jsonEncode({
      'v': 1,
      'n': base64Url.encode(nonce),
      'c': base64Url.encode(secretBox.cipherText),
      'm': base64Url.encode(secretBox.mac.bytes),
    });
  }

  /// Opens an envelope produced by [encryptJson]; null when it was tampered
  /// with or was sealed with a different key.
  static Future<Map<String, Object?>?> decryptJson(String envelope) async {
    Map<String, dynamic> parts;
    try {
      parts = jsonDecode(envelope) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
    if (parts['v'] != 1) return null;

    try {
      final key = await _key();
      final clearText = await _aes.decrypt(
        SecretBox(
          base64Url.decode(parts['c'] as String),
          nonce: base64Url.decode(parts['n'] as String),
          mac: Mac(base64Url.decode(parts['m'] as String)),
        ),
        secretKey: SecretKey(key),
      );
      return jsonDecode(utf8.decode(clearText)) as Map<String, dynamic>;
    } catch (_) {
      if (kDebugMode) debugPrint('vault: envelope failed to open');
      return null;
    }
  }
}
