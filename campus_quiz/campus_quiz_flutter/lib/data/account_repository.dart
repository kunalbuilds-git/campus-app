import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../client.dart';

/// The account information the app needs from the backend.
abstract interface class AccountRepository {
  /// Whether the signed-in user has an email account attached.
  ///
  /// A visitor that only tapped "continue as guest" has no email account.
  Future<bool> hasEmailAccount();

  /// Signs the user out on this device.
  Future<void> signOut();
}

/// Reads the account state through the Serverpod client.
class ServerpodAccountRepository implements AccountRepository {
  const ServerpodAccountRepository();

  @override
  Future<bool> hasEmailAccount() => client.emailIdp.hasAccount();

  @override
  Future<void> signOut() => client.auth.signOutDevice();
}
