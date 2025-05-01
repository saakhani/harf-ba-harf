import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:harf_ba_harf/services/firestore_service.dart';
import 'package:harf_ba_harf/services/remote_config_service.dart';

class FileTranscriptionPage extends StatefulWidget {
  const FileTranscriptionPage({super.key});

  @override
  State<FileTranscriptionPage> createState() => _FileTranscriptionPageState();
}

class _FileTranscriptionPageState extends State<FileTranscriptionPage> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  List<String> _tags = [];
  String? _filePath;
  bool _isUploading = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      if (_filePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a file to upload.')),
        );
        return;
      }

      setState(() {
        _isUploading = true;
      });

      try {
        final remoteConfig = await RemoteConfigService.initialize();
        final ngrokUrl = remoteConfig.ngrokUrl;

        // Send file to backend for transcription
        final firestoreService = FirestoreService();
        await firestoreService.uploadAndTranscribe(
          filePath: _filePath!,
          title: _title!,
          tags: _tags,
          backendUrl: ngrokUrl,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File uploaded successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File Transcription')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                validator:
                    (value) =>
                        value?.isEmpty ?? true ? 'Title is required' : null,
                onSaved: (value) => _title = value,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Tags (comma-separated)',
                ),
                onSaved: (value) {
                  if (value != null) {
                    _tags = value.split(',').map((tag) => tag.trim()).toList();
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickFile,
                child: const Text('Pick Audio File'),
              ),
              if (_filePath != null) Text('Selected File: $_filePath'),
              const SizedBox(height: 16),
              _isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _uploadFile,
                    child: const Text('Upload and Transcribe'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
