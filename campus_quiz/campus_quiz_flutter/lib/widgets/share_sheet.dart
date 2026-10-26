import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../data/campus_repository.dart';
import '../theme/brand.dart';

/// AirDrop-style sharing, campus edition: anything in the app becomes a
/// six-character code. The other student types it (or scans the QR) and the
/// item opens on their side — no accounts exchanged, no contacts added.
class ShareSheet {
  const ShareSheet._();

  /// Turns an item into a share code and shows it.
  static Future<void> showShare(
    BuildContext context, {
    required String kind,
    required String title,
    required String payload,
  }) async {
    final shared = await CampusRepository().createShare(
      kind: kind,
      payload: payload,
    );
    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1B1B1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        if (shared == null) {
          return const _SheetBody(
            child: Text(
              'Sharing needs the campus server — it is not reachable right '
              'now, so no code could be made.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }
        return _SheetBody(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: QrImageView(
                  data: shared.code,
                  size: 150,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'or type this code in CampHere',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Brand.ember.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Brand.ember.withValues(alpha: 0.4)),
                ),
                child: Text(
                  shared.code,
                  style: const TextStyle(
                    color: Brand.emberLight,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 6,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Opens the type-a-code importer and shows whatever the code carries.
  static Future<void> showImport(BuildContext context) async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B1B1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Enter a share code',
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 6,
          textCapitalization: TextCapitalization.characters,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            letterSpacing: 6,
            fontWeight: FontWeight.w600,
          ),
          decoration: const InputDecoration(
            hintText: 'ABC234',
            counterText: '',
            hintStyle: TextStyle(color: Colors.white24),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Brand.ember),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(controller.text.trim().toUpperCase()),
            child: const Text(
              'Open',
              style: TextStyle(color: Brand.emberLight),
            ),
          ),
        ],
      ),
    );
    if (code == null || code.length != 6 || !context.mounted) return;

    final shared = await CampusRepository().resolveShare(code);
    if (!context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1B1B1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        if (shared == null) {
          return const _SheetBody(
            child: Text(
              'No share with that code — it may have expired or been typed '
              'wrong.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }
        return _SheetBody(
          child: _SharedItemView(kind: shared.kind, payload: shared.payload),
        );
      },
    );
  }
}

class _SheetBody extends StatelessWidget {
  const _SheetBody({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 34),
      child: Center(child: child),
    );
  }
}

/// Renders whatever a resolved code carries.
class _SharedItemView extends StatelessWidget {
  const _SharedItemView({required this.kind, required this.payload});

  final String kind;
  final String payload;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data;
    try {
      data = jsonDecode(payload) as Map<String, dynamic>;
    } catch (_) {
      return const Text(
        'This share could not be read.',
        style: TextStyle(color: Colors.white70),
      );
    }

    if (kind == 'event') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shared event',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            data['event']?['title'] as String? ?? 'An event',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${data['event']?['location'] ?? ''} · '
            '${data['event']?['organizer'] ?? ''}',
            style: const TextStyle(color: Colors.white70, fontSize: 13.5),
          ),
          const SizedBox(height: 4),
          Text(
            '${data['goingCount'] ?? 0} going · '
            '${data['interestedCount'] ?? 0} interested',
            style: const TextStyle(color: Colors.white54, fontSize: 12.5),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              data['category'] as String? ?? 'Notice',
              style: const TextStyle(
                color: Brand.emberLight,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              data['office'] as String? ?? '',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          data['title'] as String? ?? 'A notice',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          data['body'] as String? ?? '',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13.5,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
