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

/// Category used to group events in the campus app.
enum EventCategory implements _isc.SerializableModel {
  sports,
  cultural,
  academic,
  tech,
  workshop,
  community,
  other;

  static EventCategory fromJson(String name) {
    switch (name) {
      case 'sports':
        return EventCategory.sports;
      case 'cultural':
        return EventCategory.cultural;
      case 'academic':
        return EventCategory.academic;
      case 'tech':
        return EventCategory.tech;
      case 'workshop':
        return EventCategory.workshop;
      case 'community':
        return EventCategory.community;
      case 'other':
        return EventCategory.other;
      default:
        throw ArgumentError(
          'Value "$name" cannot be converted to "EventCategory"',
        );
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
