// lib/screens/history.dart
import 'package:flutter/material.dart';
import 'package:harf_ba_harf/models/meeting_model.dart';
import 'package:harf_ba_harf/services/app_colors.dart';
import 'package:harf_ba_harf/services/text_styles.dart';
import 'package:harf_ba_harf/widgets/past_meeting_card.dart';
import 'package:harf_ba_harf/widgets/navbar.dart';
import 'package:harf_ba_harf/widgets/sidebar.dart';
import 'package:provider/provider.dart';
import 'package:harf_ba_harf/providers/upload_progress_provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarDrawer(),
      appBar: AppBar(automaticallyImplyLeading: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // <-- left align heading
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 4.0),
            child: Text(
              "History",
              style: AppTextStyles.pageTitle.copyWith(
                color: AppColors.blackish,
              ),
              textAlign: TextAlign.left, // ensure left alignment
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Meeting>>(
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
                if (pastMeetings is! List<Meeting>) {
                  return const Center(
                    child: Text("Data format error: Meetings list is invalid."),
                  );
                }
                return ListView.builder(
                  itemCount: pastMeetings.length,
                  itemBuilder: (context, index) {
                    final meeting = pastMeetings[index];
                    return Consumer<UploadProgressProvider>(
                      builder: (context, progressProvider, child) {
                        final progress = progressProvider.getProgress(
                          meeting.id,
                        );
                        return PastMeetingCard(
                          meeting: meeting,
                          onTap:
                              () => Navigator.pushNamed(
                                context,
                                '/meeting-detail',
                                arguments: meeting,
                              ),
                          uploadProgress: progress,
                        );
                      },
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
