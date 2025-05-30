import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:harf_ba_harf/models/meeting_model.dart';
import 'package:http/http.dart' as http;

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Meeting>> fetchUserMeetings() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    // Fetch user document
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    // print(userDoc.data());
    final meetingIDs = List<String>.from(userDoc['meetingIDs'] ?? []);

    // Fetch meetings
    final meetingsQuery =
        await _firestore
            .collection('meetings')
            .where(FieldPath.documentId, whereIn: meetingIDs)
            .get();

    return meetingsQuery.docs.map((doc) => Meeting.fromFirestore(doc)).toList();
  }

  Future<void> uploadAndTranscribe({
    required String filePath,
    required String title,
    required List<String> tags,
    required String backendUrl,
  }) async {
    // Upload file to backend and get transcription
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        backendUrl.endsWith('/')
            ? '${backendUrl}diarize_transcribe'
            : '$backendUrl/diarize_transcribe',
      ),
    );
    request.files.add(await http.MultipartFile.fromPath('audio', filePath));
    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Failed to transcribe audio');
    }

    final responseBody = await response.stream.bytesToString();
    final data = jsonDecode(responseBody);
    // print(data);

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      throw Exception("User not logged in");
    }

    // Generate a new meeting ID
    final meetingId =
        FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('meetings')
            .doc()
            .id;

    // Write the meeting under the user's scoped collection
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('meetings')
        .doc(meetingId)
        .set({
          'title': title,
          'date': DateTime.now(),
          'duration_seconds': data['duration_seconds'],
          'audio_url': "",
          'tags': tags,
          'transcript': data['transcript'],
          'notes': '',
          'summary': '',
        });

    // ✅ No need to update 'meetingIDs' list in user doc anymore
  }
}

