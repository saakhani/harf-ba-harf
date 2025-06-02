// live_transcription_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:harf_ba_harf/widgets/navbar.dart';
import 'package:http/http.dart' as http;

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
  final _durationController = TextEditingController(text: '3600');
  bool _isLoading = false;
  String? _responseMessage;

  @override
  void dispose() {
    _zoomLinkController.dispose();
    _meetingIdController.dispose();
    _passcodeController.dispose();
    _userNameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _triggerZoomBot() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _responseMessage = null;
    });
    final zoomLink = _zoomLinkController.text.trim();
    final meetingId = _meetingIdController.text.trim();
    final passcode = _passcodeController.text.trim();
    final userFullName = _userNameController.text.trim();
    final duration = int.tryParse(_durationController.text.trim()) ?? 3600;
    final url =
        'http://192.168.0.104:5000/trigger-zoom-bot'; // TODO: Replace with your ngrok URL
    final body = jsonEncode({
      if (zoomLink.isNotEmpty) 'zoom_link': zoomLink,
      if (meetingId.isNotEmpty) 'meeting_id': meetingId,
      if (passcode.isNotEmpty) 'passcode': passcode,
      'user_full_name': userFullName,
      'recording_duration': duration,
    });
    try {
      final response = await http.post(
        Uri.parse(url),
        body: body,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        setState(() => _responseMessage = 'Zoom bot triggered successfully!');
      } else {
        setState(() => _responseMessage = 'Error: ${response.body}');
      }
    } catch (e) {
      setState(() => _responseMessage = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Transcription')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Trigger ZoomBot to Join Meeting',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _zoomLinkController,
                decoration: const InputDecoration(
                  labelText: 'Zoom Link (optional)',
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _meetingIdController,
                      decoration: const InputDecoration(
                        labelText: 'Meeting ID (optional)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _passcodeController,
                      decoration: const InputDecoration(
                        labelText: 'Passcode (optional)',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _userNameController,
                decoration: const InputDecoration(labelText: 'Your Full Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Recording Duration (seconds)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _triggerZoomBot,
                      child: const Text('Join Zoom Meeting'),
                    ),
                  ),
              if (_responseMessage != null) ...[
                const SizedBox(height: 16),
                Text(_responseMessage!, style: TextStyle(color: Colors.blue)),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: FloatingNavBar(context: context, currentIndex: 0),
    );
  }
}
