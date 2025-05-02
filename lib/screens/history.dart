// lib/screens/history.dart
import 'package:flutter/material.dart';
import 'package:harf_ba_harf/models/meeting_model.dart';
import 'package:harf_ba_harf/widgets/past_meeting_card.dart';
import 'package:harf_ba_harf/widgets/navbar.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Column(
        children: [
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<Meeting>>(
              stream: Meeting.getPastMeetings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print('Error: ${snapshot.error}');
                  return const Center(child: Text("Error loading meetings"));
                }
                final pastMeetings = snapshot.data ?? [];

                return ListView.builder(
                  itemCount: pastMeetings.length,
                  itemBuilder: (context, index) {
                    final meeting = pastMeetings[index];
                    return PastMeetingCard(
                      meeting: meeting,
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/meeting-detail',
                        arguments: meeting,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: FloatingNavBar(
        context: context,
        currentIndex: 1, // Calendar is index 1
      ),
    );
  }
}