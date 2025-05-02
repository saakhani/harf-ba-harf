import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:harf_ba_harf/models/meeting_model.dart';

class AddMeetingForm extends StatefulWidget {
  final Meeting? meeting; // Optional Meeting object for editing

  const AddMeetingForm({super.key, this.meeting});

  @override
  State<AddMeetingForm> createState() => _AddMeetingFormState();
}

class _AddMeetingFormState extends State<AddMeetingForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    if (widget.meeting != null) {
      // Pre-fill the form fields if editing
      _titleController.text = widget.meeting!.title;
      _notesController.text = widget.meeting!.notes;
      _selectedDate = widget.meeting!.date;
      _startTime = TimeOfDay.fromDateTime(widget.meeting!.date);
      _endTime = TimeOfDay.fromDateTime(
        widget.meeting!.date.add(widget.meeting!.duration),
      );
    }
  }

  Future<void> _saveMeeting() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _startTime != null &&
        _endTime != null) {
      final startDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );
      final endDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      if (endDateTime.isBefore(startDateTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be after start time'),
          ),
        );
        return;
      }

      final newMeeting = Meeting(
        id: widget.meeting?.id ?? '', // Use existing ID if editing
        title: _titleController.text,
        date: startDateTime,
        duration: endDateTime.difference(startDateTime),
        audioUrl: widget.meeting?.audioUrl ?? '',
        tags: widget.meeting?.tags ?? [],
        transcript: widget.meeting?.transcript ?? [],
        notes: _notesController.text,
        summary: widget.meeting?.summary ?? '',
      );

      if (widget.meeting == null) {
        // Create a new meeting
        await newMeeting.saveToFirestore();
      } else {
        // Update the existing meeting
        await FirebaseFirestore.instance
            .collection('meetings')
            .doc(newMeeting.id)
            .update({
          'title': newMeeting.title,
          'date': Timestamp.fromDate(newMeeting.date),
          'duration_seconds': newMeeting.duration.inSeconds,
          'audio_url': newMeeting.audioUrl,
          'tags': newMeeting.tags,
          'transcript': newMeeting.transcript.map((e) => e.toMap()).toList(),
          'notes': newMeeting.notes,
          'summary': newMeeting.summary,
        });
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meeting == null ? 'Add New Meeting' : 'Edit Meeting'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Meeting Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    _selectedDate == null
                        ? 'Select Date'
                        : 'Date: ${_selectedDate!.toLocal()}'.split(' ')[0],
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _selectedDate = pickedDate;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    _startTime == null
                        ? 'Select Start Time'
                        : 'Start Time: ${_startTime!.format(context)}',
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: _startTime ?? const TimeOfDay(hour: 9, minute: 0),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _startTime = pickedTime;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    _endTime == null
                        ? 'Select End Time'
                        : 'End Time: ${_endTime!.format(context)}',
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: _endTime ?? const TimeOfDay(hour: 10, minute: 0),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _endTime = pickedTime;
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveMeeting,
                  child: Text(widget.meeting == null ? 'Save Meeting' : 'Update Meeting'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}