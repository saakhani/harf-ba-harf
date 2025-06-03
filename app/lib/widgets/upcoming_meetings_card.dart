import 'package:flutter/material.dart';
import 'package:harf_ba_harf/screens/add_new_meeting.dart';
import 'package:harf_ba_harf/models/meeting_model.dart';
import 'package:harf_ba_harf/services/app_colors.dart';
import 'package:harf_ba_harf/services/text_styles.dart';
import 'package:harf_ba_harf/widgets/duration_formatter.dart';

class UpcomingMeetingCard extends StatelessWidget {
  final Meeting meeting;
  final int index;
  final VoidCallback? onTap;

  static const List<Color> colorOptions = [
    AppColors.peachPink,
    AppColors.yellow,
    AppColors.lightBlue,
  ];

  const UpcomingMeetingCard({
    super.key,
    required this.meeting,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = colorOptions[index % colorOptions.length];
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddMeetingForm(meeting: meeting),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meeting.title,
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.blackish,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Duration: ${DurationFormatter.format(meeting.duration)}',
                style: AppTextStyles.body2.copyWith(
                  color: const Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
