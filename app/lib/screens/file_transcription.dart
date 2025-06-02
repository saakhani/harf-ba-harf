import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:harf_ba_harf/providers/upload_progress_provider.dart';
import 'package:harf_ba_harf/services/firestore_service.dart';
import 'package:harf_ba_harf/services/remote_config_service.dart';
import 'package:provider/provider.dart';

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
      print("🎧 File selected: $_filePath");
    } else {
      print("⚠️ No file selected.");
    }
  }

  Future<void> _uploadFile() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      if (_filePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a file to upload.')),
        );
        print("❌ Upload cancelled: No file selected.");
        return;
      }

      setState(() {
        _isUploading = true;
      });

      try {
        print("🚀 Initializing remote config...");
        final remoteConfig = await RemoteConfigService.initialize();
        final ngrokUrl = remoteConfig.ngrokUrl;
        print("🌐 FastAPI URL: $ngrokUrl");

        final firestoreService = FirestoreService();

        print("📄 Creating Firestore meeting document...");
        final meetingId = await firestoreService.createMeetingEntryAutoId(
          title: _title!,
          tags: _tags,
          filePath: _filePath!,
        );
        final uploadProgressProvider = Provider.of<UploadProgressProvider>(
          context,
          listen: false,
        );

        print("✅ Firestore document created with ID: $meetingId");

        print("📤 Uploading file to FastAPI...");
        firestoreService
            .uploadAndTranscribe(
              filePath: _filePath!,
              meetingId: meetingId,
              backendUrl: ngrokUrl,
            )
            .then((_) => print("🧠 Backend transcription triggered."))
            .catchError((e) => print("❌ FastAPI error: $e"));

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File uploaded! Processing started.')),
        );

        print("🔙 Returning to home screen...");
        Navigator.of(context).popUntil((route) => route.isFirst);
      } catch (e) {
        print("❌ Exception during upload: $e");
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
