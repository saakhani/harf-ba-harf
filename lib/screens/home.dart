import 'package:flutter/material.dart';
import 'package:harf_ba_harf/providers/auth_provider.dart';
import 'package:harf_ba_harf/widgets/sidebar.dart';
import 'package:harf_ba_harf/widgets/transcription_menu.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  // Color sequence for meeting cards
  final List<Color> cardColors = [
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.orange.shade100,
  ];

  // Dummy meeting data
  final List<Map<String, dynamic>> todayMeetings = [
    {
      'title': 'UI/UX Standup',
      'time': '9:00 AM - 10:30 AM',
      'notes': 'Access to Figma on your emails.',
    },
    {
      'title': 'Softech Sync',
      'time': '12:00 PM - 1:00 PM',
      'notes': 'Please download the following docker.',
    },
    {
      'title': 'DevOps Standup',
      'time': '3:00 PM - 4:30 PM',
      'notes': 'Please download the following docker.',
    },
  ];

  final List<Map<String, dynamic>> pastMeetings = [
    {
      'title': 'UI/UX Stand-Up',
      'date': 'Wednesday, 25 February 2025',
      'time': '9:00 AM - 10:32 AM',
    },
  ];

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<CustomAuthProvider>(context);
    final user = authProvider.user;
    final currentDate = DateFormat('EEEE, d MMMM y').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text("Your Meetings Today"),
        // In HomePage's AppBar actions:
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.add),
            onSelected: (value) {
              if (value == 'live') {
                Navigator.pushNamed(context, '/live-transcription');
              } else {
                Navigator.pushNamed(context, '/file-transcription');
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem<String>(
                    value: 'live',
                    child: ListTile(
                      leading: Icon(Icons.mic),
                      title: Text('Live Transcription'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'file',
                    child: ListTile(
                      leading: Icon(Icons.upload_file),
                      title: Text('File Transcription'),
                    ),
                  ),
                ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: SidebarDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header
            Text(
              currentDate,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),

            // Calendar View Button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.calendar_today, size: 16),
                label: Text("Calendar View"),
              ),
            ),
            SizedBox(height: 16),

            // Today's Meetings Header
            Text(
              "Today's Meetings",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Meeting Cards
            ...todayMeetings.asMap().entries.map((entry) {
              int idx = entry.key;
              var meeting = entry.value;
              return MeetingCard(
                title: meeting['title'],
                time: meeting['time'],
                notes: meeting['notes'],
                color: cardColors[idx % cardColors.length],
                margin: EdgeInsets.only(bottom: 16),
              );
            }),

            // History Section
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "History",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: () {}, child: Text("View All")),
              ],
            ),

            // Past Meetings
            ...pastMeetings.map(
              (meeting) => PastMeetingCard(
                title: meeting['title'],
                date: meeting['date'],
                time: meeting['time'],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MeetingCard extends StatelessWidget {
  final String title;
  final String time;
  final String notes;
  final Color color;
  final EdgeInsetsGeometry margin;

  const MeetingCard({
    required this.title,
    required this.time,
    required this.notes,
    required this.color,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      color: color,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(time, style: TextStyle(color: Colors.grey.shade700)),
            SizedBox(height: 12),
            Text("Notes:", style: TextStyle(fontWeight: FontWeight.w500)),
            Text(notes),
          ],
        ),
      ),
    );
  }
}

class PastMeetingCard extends StatelessWidget {
  final String title;
  final String date;
  final String time;

  const PastMeetingCard({
    required this.title,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(date),
            SizedBox(height: 4),
            Text(time),
          ],
        ),
      ),
    );
  }
}
