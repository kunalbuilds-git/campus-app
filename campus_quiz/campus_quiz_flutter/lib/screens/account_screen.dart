import 'package:campus_quiz_client/campus_quiz_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../data/account_repository.dart';
import '../data/events_repository.dart';
import 'email_auth_screen.dart';

/// The student's account.
///
/// A visitor browses as a guest with an anonymous account that only lives on
/// this device. Creating an email account gives the student an identity that
/// follows them to another device; the responses they made as a guest are
/// moved to that account.
class AccountScreen extends StatefulWidget {
  /// The source of the event data. Defaults to the Serverpod backend.
  final EventsRepository events;

  /// The source of the account state. Defaults to the Serverpod backend.
  final AccountRepository accounts;

  const AccountScreen({
    super.key,
    this.events = const ServerpodEventsRepository(),
    this.accounts = const ServerpodAccountRepository(),
  });

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _loading = true;
  bool _hasEmailAccount = false;

  /// The responses of the current identity, captured before the student
  /// switches to an email account.
  List<Rsvp> _responses = const [];

  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    try {
      final results = await Future.wait([
        widget.accounts.hasEmailAccount(),
        widget.events.myRsvps(),
      ]);
      if (!mounted) return;
      setState(() {
        _hasEmailAccount = results[0] as bool;
        _responses = results[1] as List<Rsvp>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
      _showMessage('Could not load your account. Please try again.');
    }
  }

  Future<void> _startEmailFlow(EmailFlowScreen startScreen) async {
    final signedIn = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EmailAuthScreen(startScreen: startScreen),
      ),
    );
    if (signedIn != true) return;

    setState(() {
      _busy = true;
    });
    await _moveGuestResponses();
    await _load();
    if (!mounted) return;
    setState(() {
      _busy = false;
    });
  }

  /// Copies the guest responses to the account the student just signed in to.
  ///
  /// The server gives every identity its own rows, so the responses of the
  /// anonymous account are not visible after the sign-in. Responses that the
  /// new account already has are left untouched.
  Future<void> _moveGuestResponses() async {
    if (_responses.isEmpty) return;

    try {
      final existing = await widget.events.myRsvps();
      final answered = {for (final rsvp in existing) rsvp.eventId};

      var moved = 0;
      for (final rsvp in _responses) {
        if (answered.contains(rsvp.eventId)) continue;
        try {
          await widget.events.rsvp(rsvp.eventId, status: rsvp.status);
          moved++;
        } catch (e) {
          // The event may have ended or be full. The guest response stays
          // behind instead of blocking the sign-in.
        }
      }

      if (moved > 0) {
        _showMessage('Moved $moved of your responses to your email account.');
      }
    } catch (e) {
      _showMessage('You are signed in, but your responses could not be moved.');
    }
  }

  Future<void> _signOut() async {
    setState(() {
      _busy = true;
    });

    try {
      await widget.accounts.signOut();
      if (!mounted) return;
      // The auth gate signs the student in as a new guest, so this screen has
      // nothing left to show.
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
      });
      _showMessage('Could not sign out. Please try again.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final responseCount = _responses.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _hasEmailAccount
                          ? Icons.mail_outline
                          : Icons.person_outline,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _hasEmailAccount
                            ? 'Signed in with your email address'
                            : 'Browsing as a guest',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _hasEmailAccount
                      ? 'Your responses follow your email address to every '
                            'device you sign in on.'
                      : 'Your $responseCount '
                            '${responseCount == 1 ? 'response is' : 'responses are'} '
                            'saved to this device. Create an account to keep them '
                            'when you switch device.',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_hasEmailAccount)
          OutlinedButton.icon(
            onPressed: _busy ? null : _signOut,
            icon: const Icon(Icons.logout),
            label: const Text('Sign out'),
          )
        else ...[
          FilledButton.icon(
            onPressed: _busy
                ? null
                : () => _startEmailFlow(EmailFlowScreen.startRegistration),
            icon: const Icon(Icons.person_add_outlined),
            label: const Text('Create an account with email'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _busy
                ? null
                : () => _startEmailFlow(EmailFlowScreen.login),
            icon: const Icon(Icons.login),
            label: const Text('Sign in with email'),
          ),
        ],
      ],
    );
  }
}
