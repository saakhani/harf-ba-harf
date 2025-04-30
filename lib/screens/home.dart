//home.dart
import 'package:flutter/material.dart';
import 'package:harf_ba_harf/data/dummy_data.dart';
import 'package:harf_ba_harf/models/meeting_model.dart';
import 'package:harf_ba_harf/services/firestore_service.dart';
import 'package:harf_ba_harf/widgets/meeting_card.dart';
import 'package:harf_ba_harf/widgets/navbar.dart';
import 'package:harf_ba_harf/widgets/sidebar.dart';
import 'package:harf_ba_harf/widgets/upcoming_meetings_card.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final int _currentNavIndex = 2;
  final FirestoreService _firestoreService = FirestoreService();
  final List<Color> upcomingColors = [
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
    Colors.teal.shade100,
  ];

  @override
  Widget build(BuildContext context) {
    final currentDate = DateFormat('EEEE, d MMMM y').format(DateTime.now());
    final recentHistory = DummyData.pastMeetings.take(2).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Meetings Today"),
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
      drawer: const SidebarDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 8),

            // Calendar View Button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/calendar');
                },
                icon: const Icon(Icons.calendar_today, size: 16),
                label: const Text("Calendar View"),
              ),
            ),
            const SizedBox(height: 16),

            // Upcoming Meetings Header
            const Text(
              "Upcoming Meetings",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Upcoming Meeting Cards
            FutureBuilder<List<Meeting>>(
              future: _firestoreService.fetchUserMeetings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading meetings"));
                }

                final meetings = snapshot.data ?? [];
                final todayMeetings =
                    meetings.where((meeting) {
                      return meeting.date.isAfter(
                            DateTime.now().subtract(const Duration(days: 1)),
                          ) &&
                          meeting.date.isBefore(
                            DateTime.now().add(const Duration(days: 1)),
                          );
                    }).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: todayMeetings.length,
                  itemBuilder: (context, index) {
                    final meeting = todayMeetings[index];
                    return UpcomingMeetingCard(
                      title: meeting.title,
                      time:
                          '${DateFormat('h:mm a').format(meeting.date)} - '
                          '${DateFormat('h:mm a').format(meeting.date.add(meeting.duration))}',
                      notes: meeting.notes,
                      color: Colors.blue.shade100,
                      margin: const EdgeInsets.only(bottom: 16),
                    );
                  },
                );
              },
            ),

            // History Section
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "History",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/history'),
                  child: const Text("View All"),
                ),
              ],
            ),

            // Historical Meeting Cards
            ...recentHistory.map(
              (meeting) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MeetingCard(
                  meeting: meeting,
                  onTap: () => _navigateToDetail(context, meeting),
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: FloatingNavBar(
        context: context,
        currentIndex: _currentNavIndex,
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Meeting meeting) {
    Navigator.pushNamed(context, '/meeting-detail', arguments: meeting);
  }
}
