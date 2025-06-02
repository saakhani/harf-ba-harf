import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:harf_ba_harf/models/meeting_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// ✅ Fetch all meetings of current user
  Future<List<Meeting>> fetchUserMeetings() async {
    print('FirestoreService: fetchUserMeetings called');
    final user = _auth.currentUser;
    print('FirestoreService: currentUser = $user');
    if (user == null) return [];

    final query =
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('meetings')
            .orderBy('createdAt', descending: true)
            .get();
    print('FirestoreService: fetched ${query.docs.length} meetings');

    return query.docs.map((doc) {
      print('FirestoreService: Meeting doc: ${doc.id}, data: ${doc.data()}');
      return Meeting.fromFirestore(doc);
    }).toList();
  }

  Future<String> createMeetingEntryAutoId({
    required String title,
    required List<String> tags,
    required String filePath,
  }) async {
    print('FirestoreService: createMeetingEntryAutoId called');
    final user = _auth.currentUser;
    print('FirestoreService: currentUser = $user');
    if (user == null) {
      print('FirestoreService: User not logged in!');
      return Future.error('User not logged in.');
    }

    try {
      final docRef =
          _firestore
              .collection('users')
              .doc(user.uid)
              .collection('meetings')
              .doc();

      print('FirestoreService: Creating meeting doc with id ${docRef.id}');
      final now = DateTime.now().subtract(
        const Duration(seconds: 1),
      ); // ⬅️ force into past

      await docRef.set({
        'title': title,
        'tags': tags,
        'status': 'uploading',
        'userId': user.uid,
        'fileName': filePath.split('/').last,
        'createdAt': FieldValue.serverTimestamp(),
        'date': now, // ⬅️ Already in the past
        'duration_seconds': 0,
      });

      print('FirestoreService: Meeting doc created');
      return docRef.id;
    } catch (e, stack) {
      print('FirestoreService: Exception in createMeetingEntryAutoId: $e');
      print(stack);
      return Future.error(e);
    }
  }

  /// ✅ Step 2: Upload audio file to FastAPI and update status to 'processing'
  Future<void> uploadAndTranscribe({
    required String filePath,
    required String meetingId,
    required String backendUrl,
      required void Function(double) onProgress,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in.');
    }

    final uri = Uri.parse(
      backendUrl.endsWith('/')
          ? '${backendUrl}diarize_transcribe'
          : '$backendUrl/diarize_transcribe',
    );

    final extension = filePath.split('.').last.toLowerCase();
    String mimeType = 'audio/wav';
    if (extension == 'm4a') mimeType = 'audio/x-m4a';
    if (extension == 'mp3') mimeType = 'audio/mpeg';
    if (extension == 'aac') mimeType = 'audio/aac';

    final request =
        http.MultipartRequest('POST', uri)
          ..fields['user_id'] = user.uid
          ..fields['meeting_id'] = meetingId
          ..files.add(
            await http.MultipartFile.fromPath(
              'audio',
              filePath,
              contentType: MediaType.parse(mimeType),
            ),
          );



    final response = await request.send();
      final total = File(filePath).lengthSync();
  int bytesTransferred = 0;
    response.stream.listen(
    (chunk) {
      bytesTransferred += chunk.length;
      double progress = (bytesTransferred / total) * 100;
      onProgress(progress);
    },
    onDone: () async {
      print("✅ Upload complete.");
      onProgress(100);
      await response.stream.drain(); // Ensure full stream read
    },
    onError: (e) {
      print("❌ Error uploading: $e");
      throw Exception("Upload failed");
    },
    cancelOnError: true,
  );

    if (response.statusCode == 200) {
      print("✅ Upload successful, backend processing started.");

      await _firestore.runTransaction((transaction) async {
        final docRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('meetings')
            .doc(meetingId);

        final snapshot = await transaction.get(docRef);

        final currentStatus = snapshot.data()?['status'];

        if (currentStatus == 'uploading') {
          transaction.update(docRef, {
            'status': 'processing',
            'uploadCompletedAt': FieldValue.serverTimestamp(),
          });
          print("📥 Status safely updated to 'processing'");
        } else {
          print(
            "⚠️ Skipping status update. Current status is '$currentStatus'",
          );
        }
      });
    } else {
      final body = await response.stream.bytesToString();
      throw Exception('❌ Upload failed: ${response.statusCode} → $body');
    }
  }
}
