import 'package:flutter/material.dart';
import 'package:harf_ba_harf/models/meeting_model.dart';
import 'package:harf_ba_harf/screens/add_new_meeting.dart';
import 'package:harf_ba_harf/widgets/upcoming_meetings_card.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: StreamBuilder<List<Meeting>>(
        stream: Meeting.getUpcomingMeetings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No upcoming meetings.'));
          }
          final meetings = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListView.builder(
              itemCount: meetings.length,
              itemBuilder: (context, index) {
                final meeting = meetings[index];
                return UpcomingMeetingCard(
                  meeting: meeting,
                  title: meeting.title,
                  time: '${meeting.date}',
                  duration: '${meeting.duration.inMinutes} mins',
                  color: UpcomingMeetingCard.colorOptions[index %
                      UpcomingMeetingCard.colorOptions.length],
                  margin: const EdgeInsets.symmetric(vertical: 8),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMeetingForm()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}