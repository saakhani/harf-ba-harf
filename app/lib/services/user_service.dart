import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:harf_ba_harf/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetch current user profile once
  Future<AppUser?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    final appUser = AppUser.fromFirestore(doc.data()!, user.uid);
    return appUser;
  }

  // Stream current user profile
  Stream<AppUser?> streamCurrentUserProfile() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();
    return _firestore.collection('users').doc(user.uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      final appUser = AppUser.fromFirestore(doc.data()!, user.uid);
      return appUser;
    });
  }
}
