class Meeting {
  final String id;
  final String title;
  final DateTime date;
  final Duration duration;
  final String? notes;
  final List<String> tags;
  final List<TranscriptEntry> transcript;

  Meeting({
    required this.id,
    required this.title,
    required this.date,
    required this.duration,
    required this.tags,
    required this.transcript,
    this.notes,
  });
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
}
