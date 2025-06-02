// screens/meeting_detail_page.dart
import 'package:flutter/material.dart';
import 'package:harf_ba_harf/widgets/duration_formatter.dart';
import 'package:harf_ba_harf/widgets/transcript_entry.dart';
import 'package:intl/intl.dart';
import '../models/meeting_model.dart';

class MeetingDetailPage extends StatelessWidget {
  final Meeting meeting;

  const MeetingDetailPage({super.key, required this.meeting});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(meeting.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, d MMMM y').format(meeting.date),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Start', DateFormat('h:mm a').format(meeting.date)),
            const SizedBox(height: 16),
            _buildDetailRow('Duration', DurationFormatter.format(meeting.duration)),
            const SizedBox(height: 16),
            _buildDetailRow('Text', 'Roman'),
            const Divider(height: 40),
            ...meeting.transcript
                .map((entry) => TranscriptEntryWidget(entry: entry))
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(value)),
      ],
    );
  }
}