// lib/screens/history.dart
import 'package:flutter/material.dart';
import 'package:harf_ba_harf/data/dummy_data.dart';
import 'package:harf_ba_harf/models/meeting.dart';
import 'package:harf_ba_harf/widgets/meeting_card.dart';
import 'package:harf_ba_harf/widgets/navbar.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late List<Meeting> _displayedMeetings = DummyData.allMeetings;
  String _currentFilter = 'By Date';

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
            child: ListView.builder(
              itemCount: _displayedMeetings.length,
              itemBuilder:
                  (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: MeetingCard(
                      meeting: _displayedMeetings[index],
                      onTap:
                          () => _navigateToDetail(
                            context,
                            _displayedMeetings[index],
                          ),
                    ),
                  ),
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

  void _applyFilter(String filterType) {
    setState(() {
      _currentFilter = filterType;
      if (filterType == 'By Speaker') {
        _displayedMeetings = [...DummyData.allMeetings]..sort((a, b) {
          final aSpeaker =
              a.transcript.isNotEmpty ? a.transcript.first.speaker : '';
          final bSpeaker =
              b.transcript.isNotEmpty ? b.transcript.first.speaker : '';
          return aSpeaker.compareTo(bSpeaker);
        });
      } else {
        _displayedMeetings = [...DummyData.allMeetings]
          ..sort((a, b) => b.date.compareTo(a.date));
      }
    });
  }

  void _navigateToDetail(BuildContext context, Meeting meeting) {
    Navigator.pushNamed(context, '/meeting-detail', arguments: meeting);
  }
}
