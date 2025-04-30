// lib/screens/history.dart
import 'package:flutter/material.dart';
import 'package:harf_ba_harf/data/dummy_data.dart';
import 'package:harf_ba_harf/models/meeting_model.dart';
import 'package:harf_ba_harf/services/firestore_service.dart';
import 'package:harf_ba_harf/widgets/meeting_card.dart';
import 'package:harf_ba_harf/widgets/navbar.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _currentFilter = 'By Date';
    final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Column(
        children: [
          // HistoryFilterChips(
          //   onFilterChanged: _applyFilter,
          //   initialFilter: _currentFilter,
          // ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<Meeting>>(
              future: _firestoreService.fetchUserMeetings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Error loading meetings"));
                }
                final meetings = snapshot.data ?? [];
                final pastMeetings =
                    meetings.where((meeting) {
                      return meeting.date.isBefore(DateTime.now());
                    }).toList();

                return ListView.builder(
                  itemCount: pastMeetings.length,
                  itemBuilder: (context, index) {
                    final meeting = pastMeetings[index];
                    return MeetingCard(
                      meeting: meeting,
                      onTap:
                          () => Navigator.pushNamed(
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

  // void _applyFilter(String filterType) {
  //   setState(() {
  //     _currentFilter = filterType;
  //     if (filterType == 'By Speaker') {
  //       _displayedMeetings = [...DummyData.allMeetings]..sort((a, b) {
  //         final aSpeaker =
  //             a.transcript.isNotEmpty ? a.transcript.first.speaker : '';
  //         final bSpeaker =
  //             b.transcript.isNotEmpty ? b.transcript.first.speaker : '';
  //         return aSpeaker.compareTo(bSpeaker);
  //       });
  //     } else {
  //       _displayedMeetings = [...DummyData.allMeetings]
  //         ..sort((a, b) => b.date.compareTo(a.date));
  //     }
  //   });
  // }

  void _navigateToDetail(BuildContext context, Meeting meeting) {
    Navigator.pushNamed(context, '/meeting-detail', arguments: meeting);
  }
}
