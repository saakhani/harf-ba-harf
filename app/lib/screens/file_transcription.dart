import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:harf_ba_harf/providers/upload_progress_provider.dart';
import 'package:harf_ba_harf/services/app_colors.dart';
import 'package:harf_ba_harf/services/firestore_service.dart';
import 'package:harf_ba_harf/services/remote_config_service.dart';
import 'package:harf_ba_harf/services/text_styles.dart';
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
          filePath: _filePath!,
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
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // <-- left align heading
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 4.0),
            child: Text(
              "Upload File",
              style: AppTextStyles.pageTitle.copyWith(
                color: AppColors.blackish,
              ),
              textAlign: TextAlign.left, // ensure left alignment
            ),
          ),
          Padding(
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _pickFile,
                    child: const Text('Pick Audio File'),
                  ),
                    if (_filePath != null)
                    Text('Selected File: ${_filePath!.split(RegExp(r'[\\/]+')).last}'),
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
        ],
      ),
    );
  }
}
