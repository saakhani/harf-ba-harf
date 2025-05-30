import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:harf_ba_harf/main.dart';
import 'package:harf_ba_harf/providers/user_provider.dart';
import 'package:provider/provider.dart';

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
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      _user = user;
      notifyListeners();

      final context = navigatorKey.currentContext;
      if (context != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        if (user != null) {
          await userProvider.loadUser(); // 🔥 Load Firestore profile on login
        } else {
          userProvider.clearUser(); // 🔥 Clear Firestore profile on logout
        }
      }
    });
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();

    // Clear the cached Firestore profile too
    _user = null;
    notifyListeners();

    // Also clear the user provider
    final context = navigatorKey.currentContext;
    if (context != null) {
      Provider.of<UserProvider>(context, listen: false).clearUser();
    }
  }
}
