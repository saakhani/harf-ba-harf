// providers/upload_progress_provider.dart
import 'package:flutter/foundation.dart';

class UploadProgressProvider with ChangeNotifier {
  final Map<String, double> _progressMap = {};

  double? getProgress(String meetingId) => _progressMap[meetingId];

  void setProgress(String meetingId, double progress) {
    _progressMap[meetingId] = progress;
    notifyListeners();
  }

  void clearProgress(String meetingId) {
    _progressMap.remove(meetingId);
    notifyListeners();
  }
}
