// widgets/history/meeting_card.dart
import 'package:flutter/material.dart';
import 'package:harf_ba_harf/models/meeting_model.dart';
import 'package:harf_ba_harf/services/app_colors.dart';
import 'package:harf_ba_harf/services/text_styles.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/upload_progress_provider.dart';

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
    final progressProvider = Provider.of<UploadProgressProvider>(context);
    final progress = progressProvider.getProgress(meeting.id);
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
                      meeting.status == 'error' ? 'Error' : meeting.status,
                      style: AppTextStyles.body2.copyWith(
                        color:
                            meeting.status == 'error'
                                ? Colors.red
                                : AppColors.blackish,
                        fontWeight:
                            meeting.status == 'error'
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (meeting.status == 'uploading' && progress != null) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        color: AppColors.mainSageGreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: AppTextStyles.body2,
                    ),
                  ],
                ],
              ),
              if (meeting.status == 'error' && meeting.transcript.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      meeting.transcript.first.text,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
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
