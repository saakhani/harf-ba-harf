// calendar_page.dart
import 'package:flutter/material.dart';
import 'package:harf_ba_harf/widgets/navbar.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(title: const Text('Calendar')),
      body: const Center(child: Text('Calendar Content')),
      bottomNavigationBar: FloatingNavBar(
        context: context,
        currentIndex: 3, // Calendar is index 1
      ),
    );
  }
}

// Similar structure for other pages (index 2 for Live, 3 for History, 4 for Profile)