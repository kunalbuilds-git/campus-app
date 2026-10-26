import 'package:campus_quiz_client/campus_quiz_client.dart';
import 'package:flutter/material.dart';

import '../data/events_repository.dart';
import '../utils/event_format.dart';

/// Full information about one event and the student's response to it.
class EventDetailScreen extends StatefulWidget {
  final UuidValue eventId;

  /// The student's response as known by the calling screen, used until the
  /// fresh data arrives.
  final RsvpStatus? initialMyStatus;

  /// The source of the event data. Defaults to the Serverpod backend.
  final EventsRepository events;

  const EventDetailScreen({
    super.key,
    required this.eventId,
    this.initialMyStatus,
    this.events = const ServerpodEventsRepository(),
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  EventSummary? _summary;
  RsvpStatus? _myStatus;
  bool _loading = true;
  String? _error;
  bool _actionInProgress = false;

  @override
  void initState() {
    super.initState();
    _myStatus = widget.initialMyStatus;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final summary = await widget.events.getEvent(widget.eventId);
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _loading = false;
      });
    } on EventException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load this event. Please try again.';
      });
    }
  }

  Future<void> _rsvp(RsvpStatus status) async {
    if (_actionInProgress) return;
    setState(() {
      _actionInProgress = true;
    });

    try {
      final rsvp = await widget.events.rsvp(widget.eventId, status: status);
      if (!mounted) return;
      setState(() {
        _myStatus = rsvp.status;
        _actionInProgress = false;
      });
      await _refreshCounts();
    } on EventException catch (e) {
      if (!mounted) return;
      setState(() {
        _actionInProgress = false;
      });
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _actionInProgress = false;
      });
      _showError('Could not save your response. Please try again.');
    }
  }

  Future<void> _cancelRsvp() async {
    if (_actionInProgress) return;
    setState(() {
      _actionInProgress = true;
    });

    try {
      await widget.events.cancelRsvp(widget.eventId);
      if (!mounted) return;
      setState(() {
        _myStatus = null;
        _actionInProgress = false;
      });
      await _refreshCounts();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _actionInProgress = false;
      });
      _showError('Could not cancel your response. Please try again.');
    }
  }

  Future<void> _refreshCounts() async {
    try {
      final summary = await widget.events.getEvent(widget.eventId);
      if (!mounted) return;
      setState(() {
        _summary = summary;
      });
    } catch (e) {
      // Counts are decorative; the response itself is already saved.
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Event details')),
      body: _buildBody(theme, colors),
    );
  }

  Widget _buildBody(ThemeData theme, ColorScheme colors) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null || _summary == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 48, color: colors.error),
              const SizedBox(height: 16),
              Text(
                _error ?? 'This event is not available.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final event = _summary!.event;
    final hasEnded =
        event.endsAt != null && event.endsAt!.isBefore(DateTime.now());

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            event.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              Chip(
                label: Text(categoryLabel(event.category.name)),
                visualDensity: VisualDensity.compact,
              ),
              if (hasEnded)
                Chip(
                  label: const Text('Ended'),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: colors.errorContainer,
                ),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: Text(formatEventTime(event.startsAt, event.endsAt)),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.place),
            title: Text(event.location),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person_outline),
            title: Text(event.organizer),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.group_outlined),
            title: Text(
              '${_summary!.goingCount} going · ${_summary!.interestedCount} interested'
              '${event.capacity == null ? '' : ' · capacity ${event.capacity}'}',
            ),
          ),
          if (event.description.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'About this event',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(event.description),
          ],
          const SizedBox(height: 24),
          _buildResponseSection(theme, colors, hasEnded),
        ],
      ),
    );
  }

  Widget _buildResponseSection(
    ThemeData theme,
    ColorScheme colors,
    bool hasEnded,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _myStatus == null
                  ? 'Will you attend?'
                  : 'Your response: ${rsvpStatusLabel(_myStatus!)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<RsvpStatus>(
              segments: const [
                ButtonSegment(
                  value: RsvpStatus.going,
                  icon: Icon(Icons.check_circle_outline),
                  label: Text('Going'),
                ),
                ButtonSegment(
                  value: RsvpStatus.interested,
                  icon: Icon(Icons.star_outline),
                  label: Text('Interested'),
                ),
              ],
              selected: {
                ?_myStatus,
              },
              // The student may not have responded yet, and tapping the
              // selected response clears the selection again.
              emptySelectionAllowed: true,
              onSelectionChanged: hasEnded || _actionInProgress
                  ? null
                  : (selection) {
                      if (selection.isEmpty) return;
                      final status = selection.first;
                      if (status != _myStatus) {
                        _rsvp(status);
                      }
                    },
            ),
            if (_myStatus != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _actionInProgress || hasEnded ? null : _cancelRsvp,
                icon: const Icon(Icons.close),
                label: const Text('Cancel my response'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
