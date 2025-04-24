// widgets/history/meeting_card.dart
import 'package:flutter/material.dart';
import 'package:harf_ba_harf/models/meeting.dart';
import 'package:intl/intl.dart';


class MeetingCard extends StatelessWidget {
  final Meeting meeting;
  final VoidCallback onTap;

  const MeetingCard({
    super.key,
    required this.meeting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meeting.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              _buildDateRow(context),
              const SizedBox(height: 12),
              _buildTags(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('EEEE, d MMMM y').format(meeting.date),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          '${DateFormat('h:mm a').format(meeting.date)} - '
          '${DateFormat('h:mm a').format(meeting.date.add(meeting.duration))}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 8,
      children: meeting.tags
          .map((tag) => Chip(
                label: Text(tag),
                backgroundColor: Colors.grey[200],
              ))
          .toList(),
    );
  }
}