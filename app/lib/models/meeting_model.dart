import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Meeting {
  final String id;
  final String title;
  final DateTime date;
  final Duration duration;
  final List<String> tags;
  final List<TranscriptEntry> transcript;
  final String notes;
  final String summary;
  final String status;
  double? uploadProgress; // Local-only, not from Firestore

  Meeting({
    required this.id,
    required this.title,
    required this.date,
    required this.duration,
    required this.tags,
    required this.transcript,
    required this.notes,
    required this.summary,
    required this.status,
    this.uploadProgress, // Optional, local use only
  });

  factory Meeting.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // Fix tags field to always be a List<String>
    List<String> tags = [];
    if (data['tags'] is List) {
      tags = List<String>.from((data['tags'] as List).map((e) => e.toString()));
    } else if (data['tags'] is String && (data['tags'] as String).isNotEmpty) {
      tags = [(data['tags'] as String)];
    }
    return Meeting(
      id: doc.id,
      title: data['title'] ?? 'Untitled Meeting',
      date:
          (data['date'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      duration: Duration(seconds: data['duration_seconds'] ?? 0),
      tags: tags,
      transcript:
          data['transcript'] != null
              ? (data['transcript'] as List<dynamic>)
                  .map((entry) => TranscriptEntry.fromMap(entry))
                  .toList()
              : <TranscriptEntry>[],
      notes: data['notes'] ?? '',
      summary: data['summary'] ?? '',
      status: data['status'] ?? 'unknown',
    );
  }

  static Stream<List<Meeting>> getUpcomingMeetings() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('meetings')
        .where('status', isEqualTo: 'scheduled') // ✅ skip 'processing' meetings
        .where('date', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .orderBy('date', descending: false) // Ascending order for upcoming
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Meeting.fromFirestore(doc)).toList(),
        );
  }

  static Stream<List<Meeting>> getPastMeetings() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('meetings')
        .where('date', isLessThanOrEqualTo: DateTime.now())
        .orderBy('date', descending: true) // Descending order for past
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Meeting.fromFirestore(doc)).toList(),
        );
  }

  Future<void> saveToFirestore() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('meetings')
        .add({
          'title': title,
          'date': Timestamp.fromDate(date),
          'duration_seconds': duration.inSeconds,
          'tags': tags,
          'transcript': transcript.map((e) => e.toMap()).toList(),
          'notes': notes,
          'summary': summary,
          'status': status,
        });
  }
}

class TranscriptEntry {
  final String speaker;
  final Duration timestamp;
  final String text;

  TranscriptEntry({
    required this.speaker,
    required this.timestamp,
    required this.text,
  });

  factory TranscriptEntry.fromMap(Map<String, dynamic> map) {
    return TranscriptEntry(
      speaker: map['speaker'],
      timestamp: Duration(seconds: map['timestamp_seconds']),
      text: map['text'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'speaker': speaker,
      'timestamp_seconds': timestamp.inSeconds,
      'text': text,
    };
  }
}
