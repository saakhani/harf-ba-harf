import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:harf_ba_harf/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetch current user profile once
  Future<AppUser?> getCurrentUserProfile() async {
    print('UserService: getCurrentUserProfile called');
    final user = _auth.currentUser;
    print('UserService: FirebaseAuth.currentUser = $user');
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    print(
      'UserService: Firestore doc exists: ${doc.exists}, data: ${doc.data()}',
    );
    if (!doc.exists) return null;
    final appUser = AppUser.fromFirestore(doc.data()!, user.uid);
    print('UserService: Returning AppUser: $appUser');
    return appUser;
  }

  // Stream current user profile
  Stream<AppUser?> streamCurrentUserProfile() {
    final user = _auth.currentUser;
    print('UserService: streamCurrentUserProfile called, user: $user');
    if (user == null) return const Stream.empty();
    return _firestore.collection('users').doc(user.uid).snapshots().map((doc) {
      print(
        'UserService: Firestore stream doc exists: ${doc.exists}, data: ${doc.data()}',
      );
      if (!doc.exists || doc.data() == null) return null;
      final appUser = AppUser.fromFirestore(doc.data()!, user.uid);
      print('UserService: Stream returning AppUser: $appUser');
      return appUser;
    });
  }
}
