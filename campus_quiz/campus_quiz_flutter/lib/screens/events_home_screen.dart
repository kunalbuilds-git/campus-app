import 'package:campus_quiz_client/campus_quiz_client.dart';
import 'package:flutter/material.dart';

import '../data/events_repository.dart';
import '../utils/event_format.dart';
import '../widgets/event_card.dart';
import 'account_screen.dart';
import 'event_detail_screen.dart';

/// The student's main screen: upcoming events with category filters, plus
/// a tab listing the events the student has responded to.
class EventsHomeScreen extends StatefulWidget {
  /// The source of the event data. Defaults to the Serverpod backend.
  final EventsRepository events;

  const EventsHomeScreen({
    super.key,
    this.events = const ServerpodEventsRepository(),
  });

  @override
  State<EventsHomeScreen> createState() => _EventsHomeScreenState();
}

class _EventsHomeScreenState extends State<EventsHomeScreen> {
  List<EventSummary> _summaries = const [];
  Map<UuidValue, RsvpStatus> _myResponses = const {};
  List<Rsvp> _myRsvps = const [];

  bool _loading = true;
  String? _error;
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        widget.events.listEvents(category: _selectedFilter?.toLowerCase()),
        widget.events.myRsvps(),
      ]);
      final summaries = results[0] as List<EventSummary>;
      final myRsvps = results[1] as List<Rsvp>;

      if (!mounted) return;
      setState(() {
        _summaries = summaries;
        _myRsvps = myRsvps;
        _myResponses = {
          for (final rsvp in myRsvps) rsvp.eventId: rsvp.status,
        };
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load events. Please try again.';
      });
    }
  }

  Future<void> _changeFilter(String? filter) async {
    setState(() {
      _selectedFilter = (filter == 'All') ? null : filter;
    });
    await _load();
  }

  Future<void> _openEvent(UuidValue eventId, RsvpStatus? myStatus) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EventDetailScreen(
          eventId: eventId,
          initialMyStatus: myStatus,
          events: widget.events,
        ),
      ),
    );
    // The student may have changed their response on the detail screen.
    await _load();
  }

  Future<void> _openAccount() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AccountScreen(events: widget.events),
      ),
    );
    // Signing in with an email changes the identity the RSVPs belong to.
    await _load();
  }

  Future<void> _cancelRsvp(Rsvp rsvp) async {
    try {
      await widget.events.cancelRsvp(rsvp.eventId);
      await _load();
    } catch (e) {
      _showError('Could not cancel your response. Please try again.');
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Campus Events'),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              tooltip: 'Account',
              onPressed: _openAccount,
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming', icon: Icon(Icons.event)),
              Tab(text: 'My Events', icon: Icon(Icons.bookmark_border)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUpcomingTab(),
            _buildMyEventsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTab() {
    return Column(
      children: [
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              for (final label in categoryFilterLabels)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: (_selectedFilter ?? 'All') == label,
                    onSelected: (_) => _changeFilter(label),
                  ),
                ),
            ],
          ),
        ),
        Expanded(child: _buildUpcomingList()),
      ],
    );
  }

  Widget _buildUpcomingList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _ErrorRetry(message: _error!, onRetry: _load);
    }
    if (_summaries.isEmpty) {
      return const _EmptyState(
        icon: Icons.event_busy,
        message:
            'No upcoming events here yet.\nCheck another category or come back later.',
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _summaries.length,
        itemBuilder: (context, index) {
          final summary = _summaries[index];
          // Events that come from the server always have an id.
          final eventId = summary.event.id!;
          return EventCard(
            summary: summary,
            myStatus: _myResponses[eventId],
            onTap: () => _openEvent(eventId, _myResponses[eventId]),
          );
        },
      ),
    );
  }

  Widget _buildMyEventsTab() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _ErrorRetry(message: _error!, onRetry: _load);
    }
    if (_myRsvps.isEmpty) {
      return const _EmptyState(
        icon: Icons.bookmark_border,
        message:
            'You have not responded to any events yet.\n'
            'Find an event on the Upcoming tab and mark it Going or Interested.',
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _myRsvps.length,
        itemBuilder: (context, index) {
          final rsvp = _myRsvps[index];
          final event = rsvp.event;
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              title: Text(
                event?.title ?? 'Event',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: event == null
                  ? null
                  : Text(
                      formatEventTime(event.startsAt, event.endsAt),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Chip(
                    label: Text(rsvpStatusLabel(rsvp.status)),
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    tooltip: 'Cancel response',
                    icon: const Icon(Icons.close),
                    onPressed: () => _cancelRsvp(rsvp),
                  ),
                ],
              ),
              onTap: () => _openEvent(rsvp.eventId, rsvp.status),
            ),
          );
        },
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: colors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
