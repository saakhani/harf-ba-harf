// file_transcription_page.dart
import 'package:flutter/material.dart';

class FileTranscriptionPage extends StatelessWidget {
  const FileTranscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File Transcription')),
      body: const Center(child: Text('File Transcription Page')),
    );
  }
}