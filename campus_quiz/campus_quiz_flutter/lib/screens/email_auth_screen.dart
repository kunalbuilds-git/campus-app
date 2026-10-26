import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../client.dart';

/// The email sign-in and registration flow.
///
/// Pops with `true` once the student is signed in with an email address.
class EmailAuthScreen extends StatelessWidget {
  /// The screen the flow starts on: sign in, or create a new account.
  final EmailFlowScreen startScreen;

  const EmailAuthScreen({
    super.key,
    required this.startScreen,
  });

  @override
  Widget build(BuildContext context) {
    final creating = startScreen == EmailFlowScreen.startRegistration;

    return Scaffold(
      appBar: AppBar(
        title: Text(creating ? 'Create an account' : 'Sign in'),
      ),
      body: EmailSignInWidget(
        client: client,
        startScreen: startScreen,
        // The server sends an eight digit verification code.
        verificationCodeConfig: VerificationCodeConfig.numbersOnly(length: 8),
        onAuthenticated: () {
          if (context.mounted) {
            Navigator.of(context).pop(true);
          }
        },
        onError: (error) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not sign in: $error')),
          );
        },
      ),
    );
  }
}
