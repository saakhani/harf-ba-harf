// live_transcription_page.dart
import 'package:flutter/material.dart';

class LiveTranscriptionPage extends StatelessWidget {
  const LiveTranscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Transcription')),
      body: const Center(child: Text('Live Transcription Page')),
    );
  }
}

