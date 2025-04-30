import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:harf_ba_harf/models/meeting_model.dart';

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
}
