/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import '../attendance/attendance_endpoint.dart' as _i1ousd01;
import '../auth/anonymous_idp_endpoint.dart' as _in0zita6;
import '../auth/email_idp_endpoint.dart' as _iuc1hd5t;
import '../auth/jwt_refresh_endpoint.dart' as _inwq3ztq;
import '../events/events_endpoint.dart' as _iwysfsn2;
import '../greetings/greeting_endpoint.dart' as _il624ik7;
import '../notices/notices_endpoint.dart' as _i0doq22u;
import '../sharing/share_endpoint.dart' as _i6n1rrzq;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'attendance': _i1ousd01.AttendanceEndpoint()
        ..initialize(
          server,
          'attendance',
          null,
        ),
      'anonymousIdp': _in0zita6.AnonymousIdpEndpoint()
        ..initialize(
          server,
          'anonymousIdp',
          null,
        ),
      'emailIdp': _iuc1hd5t.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'jwtRefresh': _inwq3ztq.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'events': _iwysfsn2.EventsEndpoint()
        ..initialize(
          server,
          'events',
          null,
        ),
      'greeting': _il624ik7.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
      'notices': _i0doq22u.NoticesEndpoint()
        ..initialize(
          server,
          'notices',
          null,
        ),
      'share': _i6n1rrzq.ShareEndpoint()
        ..initialize(
          server,
          'share',
          null,
        ),
    };
    connectors['attendance'] = _is.EndpointConnector(
      name: 'attendance',
      endpoint: endpoints['attendance']!,
      methodConnectors: {
        'myAttendance': _is.MethodConnector(
          name: 'myAttendance',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['attendance'] as _i1ousd01.AttendanceEndpoint)
                      .myAttendance(session),
        ),
        'upsert': _is.MethodConnector(
          name: 'upsert',
          params: {
            'subjectCode': _is.ParameterDescription(
              name: 'subjectCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'subjectName': _is.ParameterDescription(
              name: 'subjectName',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'attended': _is.ParameterDescription(
              name: 'attended',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'total': _is.ParameterDescription(
              name: 'total',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['attendance'] as _i1ousd01.AttendanceEndpoint)
                      .upsert(
                        session,
                        subjectCode: params['subjectCode'],
                        subjectName: params['subjectName'],
                        attended: params['attended'],
                        total: params['total'],
                      ),
        ),
      },
    );
    connectors['anonymousIdp'] = _is.EndpointConnector(
      name: 'anonymousIdp',
      endpoint: endpoints['anonymousIdp']!,
      methodConnectors: {
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'token': _is.ParameterDescription(
              name: 'token',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['anonymousIdp'] as _in0zita6.AnonymousIdpEndpoint)
                      .login(
                        session,
                        token: params['token'],
                      ),
        ),
      },
    );
    connectors['emailIdp'] = _is.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint).login(
                    session,
                    email: params['email'],
                    password: params['password'],
                  ),
        ),
        'startRegistration': _is.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _is.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _is.ParameterDescription(
              name: 'accountRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _is.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _is.ParameterDescription(
              name: 'registrationToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _is.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _is.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _is.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _is.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _is.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'newPassword': _is.ParameterDescription(
              name: 'newPassword',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
        'hasAccount': _is.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['jwtRefresh'] = _is.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _is.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _is.ParameterDescription(
              name: 'refreshToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['jwtRefresh'] as _inwq3ztq.JwtRefreshEndpoint)
                      .refreshAccessToken(
                        session,
                        refreshToken: params['refreshToken'],
                      ),
        ),
      },
    );
    connectors['events'] = _is.EndpointConnector(
      name: 'events',
      endpoint: endpoints['events']!,
      methodConnectors: {
        'listEvents': _is.MethodConnector(
          name: 'listEvents',
          params: {
            'category': _is.ParameterDescription(
              name: 'category',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'upcomingOnly': _is.ParameterDescription(
              name: 'upcomingOnly',
              type: _is.getType<bool?>(),
              nullable: true,
            ),
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['events'] as _iwysfsn2.EventsEndpoint).listEvents(
                    session,
                    category: params['category'],
                    upcomingOnly: params['upcomingOnly'],
                    limit: params['limit'],
                  ),
        ),
        'getEvent': _is.MethodConnector(
          name: 'getEvent',
          params: {
            'eventId': _is.ParameterDescription(
              name: 'eventId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['events'] as _iwysfsn2.EventsEndpoint).getEvent(
                    session,
                    params['eventId'],
                  ),
        ),
        'rsvp': _is.MethodConnector(
          name: 'rsvp',
          params: {
            'eventId': _is.ParameterDescription(
              name: 'eventId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'status': _is.ParameterDescription(
              name: 'status',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['events'] as _iwysfsn2.EventsEndpoint).rsvp(
                session,
                params['eventId'],
                status: params['status'],
              ),
        ),
        'cancelRsvp': _is.MethodConnector(
          name: 'cancelRsvp',
          params: {
            'eventId': _is.ParameterDescription(
              name: 'eventId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['events'] as _iwysfsn2.EventsEndpoint).cancelRsvp(
                    session,
                    params['eventId'],
                  ),
        ),
        'myRsvps': _is.MethodConnector(
          name: 'myRsvps',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['events'] as _iwysfsn2.EventsEndpoint)
                  .myRsvps(session),
        ),
      },
    );
    connectors['greeting'] = _is.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _is.MethodConnector(
          name: 'hello',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['greeting'] as _il624ik7.GreetingEndpoint).hello(
                    session,
                    params['name'],
                  ),
        ),
      },
    );
    connectors['notices'] = _is.EndpointConnector(
      name: 'notices',
      endpoint: endpoints['notices']!,
      methodConnectors: {
        'listNotices': _is.MethodConnector(
          name: 'listNotices',
          params: {
            'category': _is.ParameterDescription(
              name: 'category',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'pinnedOnly': _is.ParameterDescription(
              name: 'pinnedOnly',
              type: _is.getType<bool?>(),
              nullable: true,
            ),
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['notices'] as _i0doq22u.NoticesEndpoint)
                  .listNotices(
                    session,
                    category: params['category'],
                    pinnedOnly: params['pinnedOnly'],
                    limit: params['limit'],
                  ),
        ),
        'publish': _is.MethodConnector(
          name: 'publish',
          params: {
            'title': _is.ParameterDescription(
              name: 'title',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'body': _is.ParameterDescription(
              name: 'body',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'category': _is.ParameterDescription(
              name: 'category',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'office': _is.ParameterDescription(
              name: 'office',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'pinned': _is.ParameterDescription(
              name: 'pinned',
              type: _is.getType<bool?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['notices'] as _i0doq22u.NoticesEndpoint).publish(
                    session,
                    title: params['title'],
                    body: params['body'],
                    category: params['category'],
                    office: params['office'],
                    pinned: params['pinned'],
                  ),
        ),
      },
    );
    connectors['share'] = _is.EndpointConnector(
      name: 'share',
      endpoint: endpoints['share']!,
      methodConnectors: {
        'createShare': _is.MethodConnector(
          name: 'createShare',
          params: {
            'kind': _is.ParameterDescription(
              name: 'kind',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'payload': _is.ParameterDescription(
              name: 'payload',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['share'] as _i6n1rrzq.ShareEndpoint).createShare(
                    session,
                    kind: params['kind'],
                    payload: params['payload'],
                  ),
        ),
        'resolveShare': _is.MethodConnector(
          name: 'resolveShare',
          params: {
            'code': _is.ParameterDescription(
              name: 'code',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['share'] as _i6n1rrzq.ShareEndpoint).resolveShare(
                    session,
                    params['code'],
                  ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _iais.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _iacs.Endpoints()
      ..initializeEndpoints(server);
  }
}
