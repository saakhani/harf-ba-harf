// widgets/history/transcript_entry.dart
import 'package:flutter/material.dart';
import 'package:harf_ba_harf/services/language_detector_service.dart';
import 'package:harf_ba_harf/widgets/duration_formatter.dart';
import '../models/meeting_model.dart';


class TranscriptEntryWidget extends StatelessWidget {
  final TranscriptEntry entry;

  const TranscriptEntryWidget({super.key, required this.entry});

  @override
Widget build(BuildContext context) {
  final bool isUrdu = LanguageDetectorService.containsUrdu(entry.text);

  return Padding(
    padding: const EdgeInsets.only(bottom: 24.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry.speaker,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DurationFormatter.format(entry.timestamp),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),

        // 🟢 Dynamic Font Text
        Text(
          entry.text,
          style: TextStyle(
            fontSize: 16,
            fontFamily: isUrdu ? 'NotoNastaliq' : null,
          ),
          textAlign: isUrdu ? TextAlign.right : TextAlign.left,
        ),

        const Divider(height: 24),
      ],
    ),
  );
}
}