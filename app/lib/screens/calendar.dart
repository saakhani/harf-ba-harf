import 'package:flutter/material.dart';
import 'package:harf_ba_harf/models/meeting_model.dart';
import 'package:harf_ba_harf/screens/add_new_meeting.dart';
import 'package:harf_ba_harf/widgets/navbar.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/google_calendar_service.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;


class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  final GoogleCalendarService _calendarService = GoogleCalendarService();
  List<calendar.Event> _googleEvents = [];
  List<Meeting> _customMeetings = [];
  bool _loadingGoogle = false;
  String? _googleError;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchGoogleEvents();
    _fetchCustomMeetings();
  }

  Future<void> _fetchGoogleEvents() async {
    setState(() {
      _loadingGoogle = true;
      _googleError = null;
    });
    try {
      final events = await _calendarService.fetchUpcomingEvents();
      setState(() {
        _googleEvents = events;
      });
    } catch (e) {
      setState(() {
        _googleError = e.toString();
      });
    } finally {
      setState(() {
        _loadingGoogle = false;
      });
    }
  }

  void _fetchCustomMeetings() {
    Meeting.getUpcomingMeetings().listen((meetings) {
      setState(() {
        _customMeetings = meetings;
      });
    });
  }

  Map<DateTime, List<_UnifiedMeeting>> get _eventsByDay {
    final Map<DateTime, List<_UnifiedMeeting>> map = {};
    final now = DateTime.now();
    for (final e in _googleEvents) {
      final date = (e.start?.dateTime ?? e.start?.date ?? now).toLocal();
      final day = DateTime(date.year, date.month, date.day);
      map.putIfAbsent(day, () => []).add(_UnifiedMeeting.fromGoogle(e));
    }
    for (final m in _customMeetings) {
      final date = m.date.toLocal();
      final day = DateTime(date.year, date.month, date.day);
      map.putIfAbsent(day, () => []).add(_UnifiedMeeting.fromLocal(m));
    }
    return map;
  }

  List<_UnifiedMeeting> get _selectedDayEvents {
    final day =
        _selectedDay != null
            ? DateTime(
              _selectedDay!.year,
              _selectedDay!.month,
              _selectedDay!.day,
            )
            : DateTime.now();
    return _eventsByDay[day] ?? [];
  }

  void _onAddEvent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddMeetingForm()),
    );
    if (result == true) {
      _fetchCustomMeetings();
    }
  }

  void _onEditEvent(_UnifiedMeeting event) async {
    if (event.source == 'custom' && event.localMeeting != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddMeetingForm(meeting: event.localMeeting),
        ),
      );
      if (result == true) {
        _fetchCustomMeetings();
      }
    } else if (event.source == 'google') {
      // Optionally, show a dialog that Google events can't be edited locally
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('External Event'),
              content: const Text(
                'Google Calendar events can only be edited in Google Calendar.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _onAddEvent,
            tooltip: 'Add Event',
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            eventLoader:
                (day) =>
                    _eventsByDay[DateTime(day.year, day.month, day.day)] ?? [],
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isEmpty) return null;
                final typedEvents =
                    events.whereType<_UnifiedMeeting>().toList();
                final hasGoogle = typedEvents.any((e) => e.source == 'google');
                final hasLocal = typedEvents.any((e) => e.source == 'custom');
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (hasGoogle)
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (hasLocal)
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child:
                _loadingGoogle
                    ? const Center(child: CircularProgressIndicator())
                    : _googleError != null
                    ? Center(
                      child: Text('Google Calendar Error: $_googleError'),
                    )
                    : _selectedDayEvents.isEmpty
                    ? const Center(child: Text('No events for this day.'))
                    : ListView.builder(
                      itemCount: _selectedDayEvents.length,
                      itemBuilder: (context, index) {
                        final event = _selectedDayEvents[index];
                        return GestureDetector(
                          onTap: () => _onEditEvent(event),
                          child: Card(
                            color:
                                event.source == 'google'
                                    ? Colors.blue[100]
                                    : Colors.green[100],
                            child: ListTile(
                              title: Text(event.title),
                              subtitle: Text('${event.date}'),
                              trailing:
                                  event.zoomBotEnabled
                                      ? const Icon(
                                        Icons.videocam,
                                        color: Colors.deepPurple,
                                      )
                                      : null,
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      bottomNavigationBar: FloatingNavBar(context: context, currentIndex: 3),
    );
  }
}

class _UnifiedMeeting {
  final String id;
  final String title;
  final DateTime date;
  final Duration duration;
  final String source; // 'google' or 'custom'
  final bool zoomBotEnabled;
  final Meeting? localMeeting;
  final calendar.Event? googleEvent;

  _UnifiedMeeting({
    required this.id,
    required this.title,
    required this.date,
    required this.duration,
    required this.source,
    this.zoomBotEnabled = false,
    this.localMeeting,
    this.googleEvent,
  });

  factory _UnifiedMeeting.fromLocal(Meeting m) => _UnifiedMeeting(
    id: m.id,
    title: m.title,
    date: m.date,
    duration: m.duration,
    source: 'custom',
    zoomBotEnabled: m.tags.contains('zoom_bot'),
    localMeeting: m,
  );

  factory _UnifiedMeeting.fromGoogle(calendar.Event e) => _UnifiedMeeting(
    id: e.id ?? e.hashCode.toString(),
    title: e.summary ?? 'No Title',
    date: e.start?.dateTime ?? e.start?.date ?? DateTime.now(),
    duration: const Duration(minutes: 60),
    source: 'google',
    googleEvent: e,
  );
}
