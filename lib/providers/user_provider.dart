import 'dart:async';
import 'package:flutter/material.dart';
import 'package:harf_ba_harf/models/user_model.dart';
import 'package:harf_ba_harf/services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  AppUser? _user;
  AppUser? get user => _user;
  bool _loading = false;
  bool get loading => _loading;
  bool _hasLoaded = false;
  StreamSubscription<AppUser?>? _userSub;

  // Load user profile from Firestore (only if not already loaded)
  Future<void> loadUser() async {
    _hasLoaded = false;
    _userSub?.cancel();
    _loading = true;
    notifyListeners();
    _user = await _userService.getCurrentUserProfile();
    _loading = false;
    _hasLoaded = true;
    notifyListeners();
    listenToUser(); // Always listen to changes for the current user
  }

  // Listen to user profile changes
  void listenToUser() {

    _userSub?.cancel();
    final stream = _userService.streamCurrentUserProfile();
    _userSub = stream.listen((appUser) {
      _user = appUser;
      notifyListeners();
    });
  }

  // Clear user state
  void clearUser() {
    _userSub?.cancel();
    _user = null;
    _hasLoaded = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }
}
