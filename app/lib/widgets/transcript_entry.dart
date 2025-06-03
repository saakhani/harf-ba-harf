// widgets/history/transcript_entry.dart
import 'package:flutter/material.dart';
import 'package:harf_ba_harf/services/language_detector_service.dart';
import 'package:harf_ba_harf/widgets/duration_formatter.dart';
import '../models/meeting_model.dart';

class TranscriptEntryWidget extends StatelessWidget {
  final TranscriptEntry entry;
  final bool isEditable;
  final void Function(String, String)? onEdit;
  final bool rightAlignIfUrdu;

  const TranscriptEntryWidget({
    super.key,
    required this.entry,
    this.isEditable = false,
    this.onEdit,
    this.rightAlignIfUrdu = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUrdu = LanguageDetectorService.containsUrdu(entry.text);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isEditable
              ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              entry.speaker,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () async {
                                final controller = TextEditingController(
                                  text: entry.text,
                                );
                                final speakerController = TextEditingController(
                                  text: entry.speaker,
                                );
                                final bool isUrdu =
                                    LanguageDetectorService.containsUrdu(
                                      entry.text,
                                    );
                                final result = await showDialog<
                                  Map<String, String>
                                >(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: const Text('Edit Transcript'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: speakerController,
                                              decoration: const InputDecoration(
                                                labelText: 'Speaker',
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            TextField(
                                              controller: controller,
                                              maxLines: 5,
                                              textAlign:
                                                  rightAlignIfUrdu && isUrdu
                                                      ? TextAlign.right
                                                      : TextAlign.left,
                                              decoration: const InputDecoration(
                                                labelText: 'Text',
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(context, {
                                                  'text': controller.text,
                                                  'speaker':
                                                      speakerController.text,
                                                }),
                                            child: const Text('Save'),
                                          ),
                                        ],
                                      ),
                                );
                                if (result != null && onEdit != null) {
                                  onEdit!(result['text']!, result['speaker']!);
                                }
                              },
                              child: Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
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
                        Align(
                          alignment:
                              rightAlignIfUrdu && isUrdu
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Text(
                            entry.text,
                            textAlign:
                                rightAlignIfUrdu && isUrdu
                                    ? TextAlign.right
                                    : TextAlign.left,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: isUrdu ? 'NotoNastaliq' : null,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
              : Column(
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
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment:
                        rightAlignIfUrdu && isUrdu
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                    child: Text(
                      entry.text,
                      textAlign:
                          rightAlignIfUrdu && isUrdu
                              ? TextAlign.right
                              : TextAlign.left,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: isUrdu ? 'NotoNastaliq' : null,
                      ),
                    ),
                  ),
                ],
              ),
          const Divider(height: 24),
        ],
      ),
    );
  }
}
