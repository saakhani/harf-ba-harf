import 'package:cloud_firestore/cloud_firestore.dart';

class Meeting {
  final String id;
  final String title;
  final DateTime date;
  final Duration duration;
  final String audioUrl;
  final List<String> tags;
  final List<TranscriptEntry> transcript;
  final String notes;
  final String summary;

  Meeting({
    required this.id,
    required this.title,
    required this.date,
    required this.duration,
    required this.audioUrl,
    required this.tags,
    required this.transcript,
    required this.notes,
    required this.summary,
  });

  factory Meeting.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Meeting(
      id: doc.id,
      title: data['title'],
      date: (data['date'] as Timestamp).toDate(),
      duration: Duration(seconds: data['duration_seconds']),
      audioUrl: data['audio_url'],
      tags: List<String>.from(data['tags']),
      transcript: (data['transcript'] as List<dynamic>)
          .map((entry) => TranscriptEntry.fromMap(entry))
          .toList(),
      notes: data['notes'] ?? '',
      summary: data['summary'] ?? '',
    );
  }

  static Stream<List<Meeting>> getUpcomingMeetings() {
    return FirebaseFirestore.instance
        .collection('meetings')
        .where('date', isGreaterThan: DateTime.now())
        .orderBy('date', descending: false) // Ascending order for upcoming
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Meeting.fromFirestore(doc))
            .toList());
  }
  
  static Stream<List<Meeting>> getPastMeetings() {
    return FirebaseFirestore.instance
        .collection('meetings')
        .where('date', isLessThan: DateTime.now())
        .orderBy('date', descending: true) // Descending order for past
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Meeting.fromFirestore(doc))
            .toList());
  }

  Future<void> saveToFirestore() async {
    await FirebaseFirestore.instance.collection('meetings').add({
      'title': title,
      'date': Timestamp.fromDate(date),
      'duration_seconds': duration.inSeconds,
      'audio_url': audioUrl,
      'tags': tags,
      'transcript': transcript.map((e) => e.toMap()).toList(),
      'notes': notes,
      'summary': summary,
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