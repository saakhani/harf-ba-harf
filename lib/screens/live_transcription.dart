// live_transcription_page.dart
import 'package:flutter/material.dart';
import 'package:harf_ba_harf/widgets/navbar.dart';

class LiveTranscriptionPage extends StatelessWidget {
  const LiveTranscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Transcription')),
      body: const Center(child: Text('Live Transcription Page')),
      bottomNavigationBar: FloatingNavBar(
        context: context,
        currentIndex: 0, // Calendar is index 1
      ),
    );
  }
}

