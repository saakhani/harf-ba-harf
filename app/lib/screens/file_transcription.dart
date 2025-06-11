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
  double _uploadProgress = 0.0;

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
        _uploadProgress = 0.0;
      });

      String? meetingId;
      FirestoreService? firestoreService;
      try {
        print("🚀 Initializing remote config...");
        final remoteConfig = await RemoteConfigService.initialize();
        final ngrokUrl = remoteConfig.ngrokUrl;
        print("🌐 FastAPI URL: $ngrokUrl");

        firestoreService = FirestoreService();

        print("📄 Creating Firestore meeting document...");
        meetingId = await firestoreService.createMeetingEntryAutoId(
          title: _title!,
          filePath: _filePath!,
        );

        print("✅ Firestore document created with ID: $meetingId");

        // Immediately return to home screen before uploading/transcribing
        Navigator.of(context).popUntil((route) => route.isFirst);

        // Start upload and transcription in the background with progress
        final progressProvider = Provider.of<UploadProgressProvider>(
          context,
          listen: false,
        );
        firestoreService
            .uploadAndTranscribeWithProgress(
              filePath: _filePath!,
              meetingId: meetingId,
              backendUrl: ngrokUrl,
              onProgress: (progress) async {
                // Only update the provider, never call setState here
                progressProvider.setProgress(meetingId!, progress);
                if (progress >= 1.0) {
                  // Set status to processing when upload is complete
                  await firestoreService?.setMeetingProcessing(
                    meetingId: meetingId,
                  );
                }
              },
            )
            .then((_) async {
              print("🧠 Backend transcription triggered.");
              progressProvider.removeProgress(meetingId!);
              // Try to set status to completed if processing is done
              await firestoreService?.setMeetingCompleted(meetingId: meetingId);
            })
            .catchError((e) async {
              print("❌ FastAPI error: $e");
              if (firestoreService != null && meetingId != null) {
                await firestoreService.setMeetingError(
                  meetingId: meetingId,
                  errorMessage: 'Exception: $e',
                );
              }
              progressProvider.removeProgress(meetingId!);
            });
      } catch (e) {
        print("❌ Exception during upload: $e");
        if (firestoreService != null && meetingId != null) {
          await firestoreService.setMeetingError(
            meetingId: meetingId,
            errorMessage: 'Exception: $e',
          );
        }
        // Only show error if it happens before navigation
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
                    Text(
                      'Selected File: ${_filePath!.split(RegExp(r'[\\/]+')).last}',
                    ),
                  const SizedBox(height: 16),
                  _isUploading
                      ? Column(
                        children: [
                          CircularProgressIndicator(),

                          const SizedBox(height: 8),
                          Text(
                            'Uploading: ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                            style: AppTextStyles.body2,
                          ),
                        ],
                      )
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
