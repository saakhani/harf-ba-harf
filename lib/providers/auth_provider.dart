import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomAuthProvider extends ChangeNotifier {
  User? _user;
  User? get user => _user;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  CustomAuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _user = FirebaseAuth.instance.currentUser;
    _isLoading = false;
    notifyListeners();
    
    // Listen for auth changes
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}