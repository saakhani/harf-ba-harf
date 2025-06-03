// widgets/history/meeting_card.dart
import 'package:flutter/material.dart';
import 'package:harf_ba_harf/models/meeting_model.dart';
import 'package:harf_ba_harf/services/app_colors.dart';
import 'package:harf_ba_harf/services/text_styles.dart';
import 'package:intl/intl.dart';

class PastMeetingCard extends StatelessWidget {
  final Meeting meeting;
  final VoidCallback onTap;
  final double? uploadProgress;

  const PastMeetingCard({
    super.key,
    required this.meeting,
    required this.onTap,
    this.uploadProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0, // Remove shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.mainSageGreen, width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meeting.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('EEEE, d MMMM y').format(meeting.date),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                _formatDuration(meeting.duration),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _statusBgColor(meeting.status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      meeting.status,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.blackish,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours} h, ${minutes.toString().padLeft(2, '0')} min, ${seconds.toString().padLeft(2, '0')} sec';
  }

  Color _statusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'error':
        return AppColors.peachPink;
      case 'completed':
        return AppColors.sageGreenLight; // light sage green
      case 'in progress':
        return AppColors.yellow;
      case 'uploading':
        return AppColors.lightBlue;
      default:
        return AppColors.lightGrey;
    }
  }
}
