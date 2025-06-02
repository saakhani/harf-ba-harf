import 'package:flutter/material.dart';

class TranscriptionMenu extends StatelessWidget {
  const TranscriptionMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMenuItem(
              context,
              icon: Icons.mic,
              title: 'Live Transcription',
              onTap: () {
                Navigator.pop(context); // Close menu
                Navigator.pushNamed(context, '/live-transcription');
              },
            ),
            const Divider(height: 1),
            _buildMenuItem(
              context,
              icon: Icons.upload_file,
              title: 'File Transcription',
              onTap: () {
                Navigator.pop(context); // Close menu
                Navigator.pushNamed(context, '/file-transcription');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      onTap: onTap,
    );
  }
}