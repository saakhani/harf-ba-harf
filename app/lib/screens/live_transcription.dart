// live_transcription_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:harf_ba_harf/services/app_colors.dart';
import 'package:harf_ba_harf/services/firestore_service.dart';
import 'package:harf_ba_harf/services/remote_config_service.dart';
import 'package:harf_ba_harf/services/text_styles.dart';
import 'package:harf_ba_harf/widgets/navbar.dart';
import 'package:harf_ba_harf/widgets/sidebar.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LiveTranscriptionPage extends StatefulWidget {
  const LiveTranscriptionPage({super.key});

  @override
  State<LiveTranscriptionPage> createState() => _LiveTranscriptionPageState();
}

class _LiveTranscriptionPageState extends State<LiveTranscriptionPage> {
  final _formKey = GlobalKey<FormState>();
  final _zoomLinkController = TextEditingController();
  final _meetingIdController = TextEditingController();
  final _passcodeController = TextEditingController();
  final _userNameController = TextEditingController();
  final _titleController = TextEditingController();
  bool _isLoading = false;
  String? _responseMessage;
  String? _meetingDocId; // Persist meetingDocId
  bool _isMeetingInProgress = false; // Track if meeting is in progress
  bool _isStopping = false; // Track if stop is in progress
  bool _hasStopped = false; // Track if meeting has been stopped
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _zoomLinkController.dispose();
    _meetingIdController.dispose();
    _passcodeController.dispose();
    _userNameController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _restoreMeetingState();
    _startMeetingStatusPolling();
  }

  Future<void> _restoreMeetingState() async {
    final prefs = await SharedPreferences.getInstance();
    final inProgress = prefs.getBool('live_meeting_in_progress') ?? false;
    final docId = prefs.getString('live_meeting_doc_id');
    if (inProgress && docId != null) {
      setState(() {
        _isMeetingInProgress = true;
        _meetingDocId = docId;
      });
    }
  }

  Future<void> _persistMeetingState({
    required bool inProgress,
    String? docId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('live_meeting_in_progress', inProgress);
    if (inProgress && docId != null) {
      await prefs.setString('live_meeting_doc_id', docId);
    } else {
      await prefs.remove('live_meeting_doc_id');
    }
  }

  void _startMeetingStatusPolling() {
    // Poll every 5 seconds if a meeting is in progress
    Future.doWhile(() async {
      if (_disposed || !_isMeetingInProgress || _meetingDocId == null)
        return false;
      await Future.delayed(const Duration(seconds: 5));
      if (_disposed) return false;
      await _checkMeetingStatus();
      return !_disposed && _isMeetingInProgress && mounted;
    });
  }

  Future<void> _checkMeetingStatus() async {
    if (_meetingDocId == null || _disposed) return;
    try {
      final remoteConfig = await RemoteConfigService.initialize();
      final ngrokUrl = remoteConfig.ngrokUrl;
      final url = '$ngrokUrl/get_meeting_status';
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({'meeting_id': _meetingDocId}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        final status = jsonDecode(response.body)['status'];
        if ((status == 'left' || status == 'completed') &&
            mounted &&
            !_disposed) {
          setState(() {
            _isMeetingInProgress = false;
            _hasStopped = true;
            _responseMessage = 'Bot has left the meeting.';
          });
        }
      }
    } catch (e) {
      // Optionally handle polling errors
    }
  }

  Future<void> _triggerZoomBot() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _responseMessage = null;
      _hasStopped = false;
    });
    final zoomLink = _zoomLinkController.text.trim();
    final meetingId = _meetingIdController.text.trim();
    final passcode = _passcodeController.text.trim();
    final userFullName = _userNameController.text.trim();
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() {
        _isLoading = false;
        _responseMessage = 'Title is required.';
      });
      return;
    }
    String? meetingDocId;
    FirestoreService? firestoreService;
    try {
      print('Creating Firestore meeting document...');
      firestoreService = FirestoreService();
      meetingDocId = await firestoreService.createMeetingEntryAutoId(
        title: title,
        filePath: '', // No file for live transcription
        status: 'Zoom', // Set status to 'Zoom' for Zoom meetings
      );
      setState(() {
        _meetingDocId = meetingDocId;
        _isMeetingInProgress = true;
      });
      await _persistMeetingState(inProgress: true, docId: meetingDocId);
      print('Meeting doc ID: ' + meetingDocId);
      // Get backend URL from Remote Config
      final remoteConfig = await RemoteConfigService.initialize();
      final zoom_url = remoteConfig.zoomBotUrl;
      final ngrok_url =
          remoteConfig.ngrokUrl; // Assume this is set in RemoteConfigService
      print('Zoom bot URL from remote config: ' + zoom_url);
      print('Ngrok URL from remote config: ' + ngrok_url);
      final url = '$zoom_url/trigger-zoom-bot';
      print('Full backend URL: ' + url);
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final body = jsonEncode({
        if (zoomLink.isNotEmpty) 'zoom_link': zoomLink,
        if (meetingId.isNotEmpty) 'meeting_id': meetingId,
        if (passcode.isNotEmpty) 'passcode': passcode,
        'user_full_name': userFullName,
        'recording_duration': 3600,
        'meeting_doc_id': meetingDocId,
        'ngrok_url': ngrok_url,
        'generated_meeting_id': meetingDocId,
        'user_id': userId,
      });
      print('POST body: ' + body);
      final response = await http.post(
        Uri.parse(url),
        body: body,
        headers: {'Content-Type': 'application/json'},
      );
      print('Response status: ' + response.statusCode.toString());
      print('Response body: ' + response.body);
      if (response.statusCode == 200) {
        if (!mounted || _disposed) return;
        setState(() {
          _responseMessage = 'Zoom bot triggered successfully!';
          // Keep meeting in progress until stopped
        });
        // Do not navigate here; let user stop manually
      } else {
        await firestoreService.setMeetingError(
          meetingId: meetingDocId,
          errorMessage:
              'Zoom bot trigger failed: \u001b[200m${response.body}\u001b[0m',
        );
        if (!mounted || _disposed) return;
        setState(() {
          _responseMessage = 'Error:  ${response.body}';
          _isMeetingInProgress = false;
        });
      }
    } catch (e) {
      print('Exception: $e');
      if (firestoreService != null && meetingDocId != null) {
        await firestoreService.setMeetingError(
          meetingId: meetingDocId,
          errorMessage: 'Exception: $e',
        );
      }
      if (!mounted || _disposed) return;
      setState(() {
        _responseMessage = 'Error: $e';
        _isMeetingInProgress = false;
      });
    } finally {
      if (!mounted || _disposed) return;
      setState(() => _isLoading = false);
      // Do not navigate here
    }
  }

  Future<void> _stopZoomBot() async {
    if (_meetingDocId == null) return;
    setState(() {
      _isStopping = true;
      _responseMessage = null;
    });
    try {
      final remoteConfig = await RemoteConfigService.initialize();
      final zoom_url = remoteConfig.zoomBotUrl;
      final ngrok_url = remoteConfig.ngrokUrl;
      final url = '$zoom_url/stop-zoom-bot';
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({'meeting_id': _meetingDocId}),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        if (!mounted || _disposed) return;
        setState(() {
          _responseMessage = 'Recording stopped.';
          _isMeetingInProgress = false;
          _hasStopped = true;
        });
        await _persistMeetingState(inProgress: false);
        if (_isLoading){
          setState(() {
            _isLoading = false;
          });
        }

        // Optionally show stopped message, then navigate home
        // await Future.delayed(const Duration(seconds: 1));
        // if (mounted && !_disposed) {
        //   Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        // }
        // After navigation, trigger upload to backend (if needed)
        // final audioPath = 'C:/users/msaad/${_meetingDocId}_audio.wav';
        // final firestoreService = FirestoreService();
        // firestoreService
        //     .uploadAndTranscribeWithProgress(
        //       filePath: audioPath,
        //       meetingId: _meetingDocId!,
        //       backendUrl: ngrok_url,
        //       onProgress: (progress) async {
        //         if (progress >= 1.0) {
        //           await firestoreService.setMeetingProcessing(
        //             meetingId: _meetingDocId!,
        //           );
        //         }
        //       },
        //     )
        //     .then((_) async {
        //       await firestoreService.setMeetingCompleted(
        //         meetingId: _meetingDocId!,
        //       );
        //     })
        //     .catchError((e) async {
        //       await firestoreService.setMeetingError(
        //         meetingId: _meetingDocId!,
        //         errorMessage: 'Exception: $e',
        //       );
        //     });
      } else if (response.statusCode == 404) {
        if (!mounted || _disposed) return;
        setState(() {
          _responseMessage = 'No recording in progress.';
          _isMeetingInProgress = false;
          _hasStopped = false;
          _meetingDocId = null;
        });
        await _persistMeetingState(inProgress: false);
        // Navigate to home after a short delay
        await Future.delayed(const Duration(seconds: 1));
        if (mounted && !_disposed) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        if (!mounted || _disposed) return;
        setState(() {
          _responseMessage = 'Failed to stop: ${response.body}';
        });
      }
    } catch (e) {
      if (!mounted || _disposed) return;
      setState(() {
        _responseMessage = 'Error stopping: $e';
      });
    } finally {
      if (!mounted || _disposed) return;
      setState(() {
        _isStopping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarDrawer(),
      appBar: AppBar(automaticallyImplyLeading: true),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 0,
                              top: 0,
                              bottom: 16.0,
                            ),
                            child: Text(
                              "Live Transcription",
                              style: AppTextStyles.pageTitle.copyWith(
                                color: AppColors.blackish,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          // Title field first
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Title',
                            ),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? 'Title is required'
                                        : null,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Trigger ZoomBot to Join Meeting',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _zoomLinkController,
                            decoration: const InputDecoration(
                              labelText: 'Zoom Link (optional)',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _meetingIdController,
                            decoration: const InputDecoration(
                              labelText: 'Meeting ID (optional)',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passcodeController,
                            decoration: const InputDecoration(
                              labelText: 'Passcode (optional)',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _userNameController,
                            decoration: const InputDecoration(
                              labelText: 'Your Full Name',
                            ),
                            validator:
                                (v) =>
                                    v == null || v.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          _isLoading
                              ? const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(width: 16),
                                    Text('ZoomBot Started'),
                                  ],
                                ),
                              )
                              : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      _isMeetingInProgress
                                          ? null
                                          : _triggerZoomBot,
                                  child: const Text('Join Zoom Meeting'),
                                ),
                              ),
                          // Show Stop Recording button if meeting is in progress and docId is available
                          if (_isMeetingInProgress && _meetingDocId != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.stop),
                                  label:
                                      _isStopping
                                          ? const Text('Stopping...')
                                          : const Text('Stop Recording'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed:
                                      _isStopping || _hasStopped
                                          ? null
                                          : _stopZoomBot,
                                ),
                              ),
                            ),
                          // if (_hasStopped)
                          //   Padding(
                          //     padding: const EdgeInsets.only(top: 8.0),
                          //     child: Text(
                          //       'Recording stopped.',
                          //       style: TextStyle(
                          //         color: Colors.green,
                          //         fontWeight: FontWeight.bold,
                          //       ),
                          //     ),
                          //   ),
                          if (_responseMessage != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              _responseMessage!,
                              style: TextStyle(color: Colors.blue),
                            ),

                          ],

                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: FloatingNavBar(context: context, currentIndex: 0),
    ); // End of Scaffold
  }
}
