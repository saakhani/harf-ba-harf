import 'package:flutter/material.dart';
import 'package:harf_ba_harf/screens/home.dart';

class FloatingNavBar extends StatelessWidget {
  final BuildContext context;
  final int currentIndex;

  const FloatingNavBar({
    super.key,
    required this.context,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.mic, 'Live', 0, () {
                Navigator.pushNamed(context, '/live-transcription');
              }),
              _buildNavItem(Icons.history, 'History', 1, () {
                Navigator.pushNamed(context, '/history');
              }),
              _buildNavItem(Icons.home, 'Home', 2, () {
                if (currentIndex != 2) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                }
              }),
              _buildNavItem(Icons.calendar_today, 'Calendar', 3, () {
                Navigator.pushNamed(context, '/calendar');
              }),
              _buildNavItem(Icons.person, 'Profile', 4, () {
                Navigator.pushNamed(context, '/profile');
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: currentIndex == index ? Colors.blue : Colors.grey,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: currentIndex == index ? Colors.blue : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
