import 'package:campus_quiz_client/campus_quiz_client.dart';
import 'package:flutter/material.dart';

import '../utils/event_format.dart';

/// A card summarising one event for the home list.
class EventCard extends StatelessWidget {
  final EventSummary summary;

  /// The student's current response to this event, or null.
  final RsvpStatus? myStatus;

  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.summary,
    required this.myStatus,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final event = summary.event;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Chip(
                    label: Text(
                      categoryLabel(event.category.name),
                      style: theme.textTheme.labelSmall,
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: colors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      formatEventTime(event.startsAt, event.endsAt),
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.place, size: 16, color: colors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${event.location} · ${event.organizer}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              if (event.description.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  event.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.group_outlined, size: 16, color: colors.primary),
                  const SizedBox(width: 6),
                  Text(
                    '${summary.goingCount} going · ${summary.interestedCount} interested',
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  if (myStatus != null) _MyStatusBadge(status: myStatus!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyStatusBadge extends StatelessWidget {
  final RsvpStatus status;

  const _MyStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isGoing = status == RsvpStatus.going;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isGoing ? colors.primaryContainer : colors.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isGoing ? Icons.check_circle : Icons.star_outline,
            size: 14,
            color: isGoing
                ? colors.onPrimaryContainer
                : colors.onSecondaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            rsvpStatusLabel(status),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isGoing
                  ? colors.onPrimaryContainer
                  : colors.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
