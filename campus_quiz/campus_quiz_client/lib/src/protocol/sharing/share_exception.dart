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
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// Exception reported when a share cannot be created or resolved.
abstract class ShareException
    implements
        _isc.SerializableException,
        _isc.SerializableModel,
        _isc.ProtocolSerialization {
  ShareException._({
    required this.code,
    required this.message,
  });

  factory ShareException({
    required String code,
    required String message,
  }) = _ShareExceptionImpl;

  factory ShareException.fromJson(Map<String, dynamic> jsonSerialization) {
    return ShareException(
      code: jsonSerialization['code'] as String,
      message: jsonSerialization['message'] as String,
    );
  }

  /// Machine-readable error code.
  String code;

  /// Human-readable message for display in the app.
  String message;

  /// Returns a shallow copy of this [ShareException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ShareException copyWith({
    String? code,
    String? message,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ShareException',
      'code': code,
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ShareException',
      'code': code,
      'message': message,
    };
  }

  @override
  String toString() {
    return 'ShareException(code: $code, message: $message)';
  }
}

class _ShareExceptionImpl extends ShareException {
  _ShareExceptionImpl({
    required String code,
    required String message,
  }) : super._(
         code: code,
         message: message,
       );

  /// Returns a shallow copy of this [ShareException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ShareException copyWith({
    String? code,
    String? message,
  }) {
    return ShareException(
      code: code ?? this.code,
      message: message ?? this.message,
    );
  }
}
