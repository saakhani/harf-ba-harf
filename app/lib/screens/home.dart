import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:harf_ba_harf/models/meeting_model.dart';
import 'package:harf_ba_harf/widgets/past_meeting_card.dart';
import 'package:harf_ba_harf/widgets/navbar.dart';
import 'package:harf_ba_harf/widgets/sidebar.dart';
import 'package:harf_ba_harf/widgets/upcoming_meetings_card.dart';
import 'package:harf_ba_harf/providers/upload_progress_provider.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final int _currentNavIndex = 2;
  final List<Color> upcomingColors = UpcomingMeetingCard.colorOptions;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {}); // Triggers UI refresh when coming back
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = DateFormat('EEEE, d MMMM y').format(DateTime.now());
    final progressProvider = Provider.of<UploadProgressProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Meetings Today"),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.add),
            onSelected: (value) {
              if (value == 'live') {
                Navigator.pushNamed(
                  context,
                  '/live-transcription',
                ).then((_) => setState(() {}));
              } else {
                Navigator.pushNamed(
                  context,
                  '/file-transcription',
                ).then((_) => setState(() {}));
              }
            },
            itemBuilder: (context) => [
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
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentDate,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
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
              const Text(
                "Upcoming Meetings",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<Meeting>>(
                stream: Meeting.getUpcomingMeetings(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading meetings"));
                  }
                  final meetings = snapshot.data ?? [];
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: meetings.length,
                    itemBuilder: (context, index) {
                      final meeting = meetings[index];
                      return UpcomingMeetingCard(
                        meeting: meeting,
                        title: meeting.title,
                        time:
                            '${DateFormat('h:mm a').format(meeting.date)} - '
                            '${DateFormat('h:mm a').format(meeting.date.add(meeting.duration))}',
                        duration: '${meeting.duration.inMinutes} minutes',
                        notes: meeting.notes,
                        color: upcomingColors[index % upcomingColors.length],
                        margin: const EdgeInsets.only(bottom: 16),
                      );
                    },
                  );
                },
              ),
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
              StreamBuilder<List<Meeting>>(
                stream: Meeting.getPastMeetings(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Error loading meetings: ${snapshot.error}"),
                    );
                  }
                  final pastMeetings = snapshot.data ?? [];
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pastMeetings.length,
                    itemBuilder: (context, index) {
                      final meeting = pastMeetings[index];
                      return PastMeetingCard(
                        meeting: meeting,
                        uploadProgress:
                            progressProvider.getProgress(meeting.id),
                        onTap: () => _navigateToDetail(context, meeting),
                      );
                    },
                  );
                },
              ),
            ],
          ),
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
