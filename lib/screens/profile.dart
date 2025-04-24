// profile_page.dart
import 'package:flutter/material.dart';
import 'package:harf_ba_harf/widgets/navbar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Profile Page')),
      bottomNavigationBar: FloatingNavBar(
        context: context,
        currentIndex: 4, // Calendar is index 1
      ),

    );
  }
}