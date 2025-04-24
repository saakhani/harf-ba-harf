import 'package:flutter/material.dart';

class UpcomingMeetingCard extends StatelessWidget {
  final String title;
  final String time;
  final String notes;
  final Color color;
  final EdgeInsetsGeometry margin;

  const UpcomingMeetingCard({
    super.key,
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
