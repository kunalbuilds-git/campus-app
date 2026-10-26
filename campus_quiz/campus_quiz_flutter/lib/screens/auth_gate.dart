import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../client.dart';
import 'events_home_screen.dart';

/// Signs the student in silently with an anonymous account and then shows
/// the events home screen.
///
/// Every visitor gets their own Serverpod auth user, so RSVPs are tied to
/// this browser without putting a sign-in wall in front of the app.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _signedIn = client.auth.isAuthenticated;
  String? _error;
  bool _signingIn = false;

  @override
  void initState() {
    super.initState();
    client.auth.authInfoListenable.addListener(_onAuthChanged);
    if (!_signedIn) {
      _signInAnonymously();
    }
  }

  @override
  void dispose() {
    client.auth.authInfoListenable.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (!mounted) return;
    final signedIn = client.auth.isAuthenticated;
    setState(() {
      _signedIn = signedIn;
    });
    if (!signedIn && !_signingIn) {
      // The student signed out, so they get a fresh guest account.
      _signInAnonymously();
    }
  }

  Future<void> _signInAnonymously() async {
    setState(() {
      _signingIn = true;
      _error = null;
    });

    final controller = AnonymousAuthController(client: client);
    await controller.login();

    if (!mounted) return;
    if (controller.state == AnonymousAuthState.authenticated) {
      setState(() {
        _signedIn = true;
        _signingIn = false;
      });
    } else {
      setState(() {
        _signingIn = false;
        _error =
            'Could not connect to the campus server. '
            'Check that the backend is running and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_signedIn) {
      return const EventsHomeScreen();
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Campus Events',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 32),
            if (_signingIn) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Connecting…'),
            ] else if (_error != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _signInAnonymously,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
