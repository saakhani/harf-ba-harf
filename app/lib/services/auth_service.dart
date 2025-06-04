import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Sign up with email and password, and save profile
  Future<User?> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final user = userCredential.user;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
      if (user != null) {
        // Update displayName in Firebase Auth
        await user.updateDisplayName(name);
        await user.reload();
        // Create Firestore user doc
        await _createUserProfileIfNeeded(user, name);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('An account already exists for that email.');
      }
      throw Exception(e.message ?? 'Failed to sign up. Please try again.');
    }
  }

  // Login with email and password (no doc creation)
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Failed to log in. Please try again.');
    }
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;
      if (user != null) {
        // Only create Firestore doc if it doesn't exist
        await _createUserProfileIfNeeded(user, googleUser.displayName ?? '');
      }
      return user;
    } catch (e) {
      // print("Sign-in error: $e");
      return null;
    }
  }

  // Sign out from both Google and Firebase
  Future<void> signOut(BuildContext context) async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
    // Clear navigation stack and go to login
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  // Create Firestore user doc if it doesn't exist
  Future<void> _createUserProfileIfNeeded(User user, String name) async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    final doc = await userDoc.get();
    if (!doc.exists) {
      await userDoc.set({
        'uid': user.uid,
        'name': name,
        'email': user.email ?? '',
        'profilePhoto': user.photoURL ?? '',
        'created_at': FieldValue.serverTimestamp(),
        'last_login': FieldValue.serverTimestamp(),
        'role': 'user',
        'settings': {'language': 'en', 'notifications': true},
        'onboarded': false,
        'deleted': false,
      });
    } else {
      await userDoc.update({'last_login': FieldValue.serverTimestamp()});
    }
  }
}
