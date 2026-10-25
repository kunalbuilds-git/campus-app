import 'package:serverpod_auth_idp_server/providers/anonymous.dart';

/// By extending [AnonymousIdpBaseEndpoint], anonymous account creation is
/// enabled, so the app can give every visitor an identity without a
/// registered account. The identity can later be upgraded to an email
/// account through the email sign-in flow.
class AnonymousIdpEndpoint extends AnonymousIdpBaseEndpoint {}
