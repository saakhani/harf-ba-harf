// lib/data/dummy_data.dart
import 'package:harf_ba_harf/models/meeting_model.dart';

class DummyData {
  static final List<Meeting> todayMeetings = [
    Meeting(
      id: '1',
            audioUrl: "test",
      notes: "",
      summary: "",
      title: 'UI/UX Standup',
      date: DateTime.now().copyWith(hour: 9, minute: 0),
      duration: const Duration(hours: 1, minutes: 30),
      tags: ['Design', 'Internal'],
      transcript: [
        TranscriptEntry(
          speaker: 'Maham',
          timestamp: const Duration(seconds: 21),
          text: 'Assalam o Alaikumi Umead hai ke aap sab ne kal wok saare kaam paore kar liye hange...',
        ),
      ],
    ),
    Meeting(
      id: '2',
      title: 'Softech Sync',
      date: DateTime.now().copyWith(hour: 12, minute: 0),
      duration: const Duration(hours: 1),
      tags: ['Softech', 'Sync'],
      audioUrl: "test",
      notes: "",
      summary: "",
      transcript: [],
    ),
    Meeting(
      id: '3',
      title: 'DevOps Standup',
      date: DateTime.now().copyWith(hour: 15, minute: 0),
      duration: const Duration(hours: 1, minutes: 30),
      tags: ['DevOps', 'Internal'],
            audioUrl: "test",
      notes: "",
      summary: "",
      transcript: [],
    ),
  ];

  static final List<Meeting> pastMeetings = [
    Meeting(
      id: '4',
      title: 'UI/UX Stand-Up',
      date: DateTime(2025, 2, 25, 9, 0),
      duration: const Duration(hours: 1, minutes: 32),
      tags: ['Design', 'Internal'],
            audioUrl: "test",
      notes: "",
      summary: "",
      transcript: [
        TranscriptEntry(
          speaker: 'Maham',
          timestamp: const Duration(seconds: 21),
          text: 'Assalam o Alaikumi Umead hai ke aap sab ne kal wok saare kaam paore kar liye hange...',
        ),
        TranscriptEntry(
          speaker: 'Nimra',
          timestamp: const Duration(minutes: 1, seconds: 49),
          text: 'Walaikum Assalam, jee maine log in ka poora user flow bana lia hai...',
        ),
      ],
    ),
        Meeting(
      id: '4',
            audioUrl: "test",
      notes: "",
      summary: "",
      title: 'UI/UX Stand-Up',
      date: DateTime(2025, 2, 25, 9, 0),
      duration: const Duration(hours: 1, minutes: 32),
      tags: ['Design', 'Internal'],
      transcript: [
        TranscriptEntry(
          speaker: 'Maham',
          timestamp: const Duration(seconds: 21),
          text: 'Assalam o Alaikumi Umead hai ke aap sab ne kal wok saare kaam paore kar liye hange...',
        ),
        TranscriptEntry(
          speaker: 'Nimra',
          timestamp: const Duration(minutes: 1, seconds: 49),
          text: 'Walaikum Assalam, jee maine log in ka poora user flow bana lia hai...',
        ),
      ],
    ),
        Meeting(
      id: '4',
            audioUrl: "test",
      notes: "",
      summary: "",
      title: 'UI/UX Stand-Up',
      date: DateTime(2025, 2, 25, 9, 0),
      duration: const Duration(hours: 1, minutes: 32),
      tags: ['Design', 'Internal'],
      transcript: [
        TranscriptEntry(
          speaker: 'Maham',
          timestamp: const Duration(seconds: 21),
          text: 'Assalam o Alaikumi Umead hai ke aap sab ne kal wok saare kaam paore kar liye hange...',
        ),
        TranscriptEntry(
          speaker: 'Nimra',
          timestamp: const Duration(minutes: 1, seconds: 49),
          text: 'Walaikum Assalam, jee maine log in ka poora user flow bana lia hai...',
        ),
      ],
    ),
    Meeting(
      id: '5',
            audioUrl: "test",
      notes: "",
      summary: "",
      title: 'Softech Sync',
      date: DateTime(2025, 2, 24, 16, 0),
      duration: const Duration(minutes: 47),
      tags: ['Harf ba Harf', 'Softech'],
      transcript: [],
    ),
  ];

  // Get all meetings (today + past)
  static List<Meeting> get allMeetings => [...todayMeetings, ...pastMeetings];
}