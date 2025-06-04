// screens/meeting_detail_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:harf_ba_harf/services/app_colors.dart';
import 'package:harf_ba_harf/services/text_styles.dart';
import 'package:harf_ba_harf/widgets/duration_formatter.dart';
import 'package:harf_ba_harf/widgets/transcript_entry.dart';
import 'package:intl/intl.dart';
import '../models/meeting_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MeetingDetailPage extends StatefulWidget {
  final Meeting meeting;

  const MeetingDetailPage({super.key, required this.meeting});

  @override
  State<MeetingDetailPage> createState() => _MeetingDetailPageState();
}

class _MeetingDetailPageState extends State<MeetingDetailPage> {
  late List<TranscriptEntry> _transcript;

  @override
  void initState() {
    super.initState();
    _transcript = List<TranscriptEntry>.from(widget.meeting.transcript);
  }

  Future<void> _updateTranscript(int index, String newText) async {
    setState(() {
      _transcript[index] = TranscriptEntry(
        speaker: _transcript[index].speaker,
        timestamp: _transcript[index].timestamp,
        text: newText,
      );
    });
    final userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('meetings')
        .doc(widget.meeting.id)
        .update({'transcript': _transcript.map((e) => e.toMap()).toList()});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Delete Meeting',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Delete Meeting'),
                      content: const Text(
                        'Are you sure you want to delete this meeting? This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
              );
              if (confirm == true) {
                final userId = FirebaseAuth.instance.currentUser!.uid;
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('meetings')
                    .doc(widget.meeting.id)
                    .delete();
                if (mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.meeting.title,
              style: AppTextStyles.pageTitle.copyWith(
                color: AppColors.blackish,
              ),
            ),
            Text(
              DateFormat('EEEE, d MMMM y').format(widget.meeting.date),
              style: AppTextStyles.subtext.copyWith(color: AppColors.blackish),
            ),
            const SizedBox(height: 24),
            _buildDetailRow(
              'Start',
              DateFormat('h:mm a').format(widget.meeting.date),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Duration',
              DurationFormatter.format(widget.meeting.duration),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Status', widget.meeting.status),
            const Divider(height: 40),
            ..._transcript.asMap().entries.map(
              (entry) => TranscriptEntryWidget(
                entry: entry.value,
                isEditable: true,
                rightAlignIfUrdu: true,
                onEdit: (newText, newSpeaker) async {
                  // If speaker changed, update all entries with old speaker
                  if (newSpeaker != entry.value.speaker) {
                    final oldSpeaker = entry.value.speaker;
                    setState(() {
                      for (int i = 0; i < _transcript.length; i++) {
                        if (_transcript[i].speaker == oldSpeaker) {
                          _transcript[i] = TranscriptEntry(
                            speaker: newSpeaker,
                            timestamp: _transcript[i].timestamp,
                            text:
                                i == entry.key ? newText : _transcript[i].text,
                          );
                        }
                      }
                    });
                  } else {
                    setState(() {
                      _transcript[entry.key] = TranscriptEntry(
                        speaker: newSpeaker,
                        timestamp: _transcript[entry.key].timestamp,
                        text: newText,
                      );
                    });
                  }
                  final userId = FirebaseAuth.instance.currentUser!.uid;
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .collection('meetings')
                      .doc(widget.meeting.id)
                      .update({
                        'transcript':
                            _transcript.map((e) => e.toMap()).toList(),
                      });
                },
              ),
            ),
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
