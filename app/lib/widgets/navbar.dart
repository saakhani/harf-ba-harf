import 'package:flutter/material.dart';
import 'package:harf_ba_harf/screens/home.dart';
import 'package:harf_ba_harf/services/app_colors.dart';

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
                color: Colors.black.withAlpha((0.1 * 255).toInt()),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.mic, 'Live', 0, () {
                if (currentIndex != 0) {
                  Navigator.pushReplacementNamed(
                    context,
                    '/live-transcription',
                  );
                }
              }),
              _buildNavItem(Icons.history, 'History', 1, () {
                if (currentIndex != 1) {
                  Navigator.pushReplacementNamed(context, '/history');
                }
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
                if (currentIndex != 3) {
                  Navigator.pushReplacementNamed(context, '/calendar');
                }
              }),
              _buildNavItem(Icons.person, 'Profile', 4, () {
                if (currentIndex != 4) {
                  Navigator.pushReplacementNamed(context, '/profile');
                }
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
            color:
                currentIndex == index
                    ? AppColors.mainSageGreen
                    : AppColors.darkGrey,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color:
                  currentIndex == index
                      ? AppColors.mainSageGreen
                      : AppColors.darkGrey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
