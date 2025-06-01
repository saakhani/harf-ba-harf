import 'package:flutter/material.dart';

import 'package:harf_ba_harf/screens/add_new_meeting.dart';
import 'package:harf_ba_harf/models/meeting_model.dart';

class UpcomingMeetingCard extends StatelessWidget {
  final String title;
  final String time;
  final String? notes;
  final String duration;
  final Color color;
  final EdgeInsetsGeometry margin;
  final Meeting meeting; // Pass the Meeting object
  final VoidCallback? onTap;

  static List<Color> colorOptions = [
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
    Colors.teal.shade100,
  ];

  const UpcomingMeetingCard({
    super.key,
    required this.title,
    required this.time,
    this.notes,
    required this.duration,
    required this.color,
    this.margin = EdgeInsets.zero,
    required this.meeting, // Required Meeting object
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => AddMeetingForm(
                  meeting: meeting, // Pass the meeting to the form
                ),
          ),
        );
      },
      child: Card(
        margin: margin,
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(time, style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(height: 8),
              Text(
                'Duration: $duration',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              Text(
                'Status: ${meeting.status}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              if (notes != null) ...[
                const SizedBox(height: 12),
                const Text(
                  "Notes:",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(notes!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
