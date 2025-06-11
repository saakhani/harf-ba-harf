import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:harf_ba_harf/models/meeting_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';

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
    required String filePath,
    String status = 'uploading', // Default to 'uploading', but allow override
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

      print('FirestoreService: Creating meeting doc with id [0m${docRef.id}');
      final now = DateTime.now().subtract(
        const Duration(seconds: 1),
      ); // ⬅️ force into past

      await docRef.set({
        'title': title,
        'tags': "",
        'status': status, // Use the provided status
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
      // Update Firestore with error status and error message in transcript
      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('meetings')
          .doc(meetingId);
      await docRef.update({
        'status': 'error',
        'transcript': [
          {
            'speaker': 'Error',
            'timestamp_seconds': 0,
            'text': 'Upload failed: ${response.statusCode} → $body',
          },
        ],
        'updatedAt': FieldValue.serverTimestamp(),
      });
      throw Exception('❌ Upload failed: ${response.statusCode} → $body');
    }
  }

  /// Upload audio file to FastAPI with progress callback
  Future<void> uploadAndTranscribeWithProgress({
    required String filePath,
    required String meetingId,
    required String backendUrl,
    required void Function(double) onProgress,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in.');
    }
    final uri =
        backendUrl.endsWith('/')
            ? '${backendUrl}diarize_transcribe'
            : '$backendUrl/diarize_transcribe';
    final extension = filePath.split('.').last.toLowerCase();
    String mimeType = 'audio/wav';
    if (extension == 'm4a') mimeType = 'audio/x-m4a';
    if (extension == 'mp3') mimeType = 'audio/mpeg';
    if (extension == 'aac') mimeType = 'audio/aac';
    final dio = Dio();
    final formData = FormData.fromMap({
      'user_id': user.uid,
      'meeting_id': meetingId,
      'audio': await MultipartFile.fromFile(
        filePath,
        filename: filePath.split('/').last,
        contentType: MediaType.parse(mimeType),
      ),
    });
    try {
      final response = await dio.post(
        uri,
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) onProgress(sent / total);
        },
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          sendTimeout: const Duration(
            minutes: 10,
          ), // Increased from 2 to 10 minutes
          receiveTimeout: const Duration(
            minutes: 10,
          ), // Increased from 2 to 10 minutes
        ),
      );
      if (response.statusCode == 200) {
        // Always set status to 'processing' after upload
        final docRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('meetings')
            .doc(meetingId);
        await docRef.update({
          'status': 'processing',
          'uploadCompletedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await setMeetingError(
          meetingId: meetingId,
          errorMessage:
              'Upload failed: ${response.statusCode} → ${response.data}',
        );
        throw Exception(
          '❌ Upload failed: ${response.statusCode} → ${response.data}',
        );
      }
    } catch (e) {
      await setMeetingError(
        meetingId: meetingId,
        errorMessage: 'Exception: $e',
      );
      rethrow;
    }
  }

  /// Set meeting status to 'error' and store error message in transcript
  Future<void> setMeetingError({
    required String meetingId,
    required String errorMessage,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in.');
    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('meetings')
        .doc(meetingId);
    await docRef.update({
      'status': 'error',
      'transcript': [
        {'speaker': 'Error', 'timestamp_seconds': 0, 'text': errorMessage},
      ],
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Set meeting status to 'processing' and store uploadCompletedAt
  Future<void> setMeetingProcessing({required String meetingId}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in.');
    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('meetings')
        .doc(meetingId);
    final doc = await docRef.get();
    final currentStatus = doc.data()?['status'];
    if (currentStatus == 'uploading') {
      await docRef.update({
        'status': 'processing',
        'uploadCompletedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Set meeting status to 'completed' and store uploadCompletedAt
  Future<void> setMeetingCompleted({required String meetingId}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in.');
    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('meetings')
        .doc(meetingId);
    final doc = await docRef.get();
    final currentStatus = doc.data()?['status'];
    if (currentStatus == 'processing') {
      await docRef.update({
        'status': 'completed',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
