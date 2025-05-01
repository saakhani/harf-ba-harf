// lib/services/language_detector_service.dart

class LanguageDetectorService {
  /// Checks if the given text contains Urdu script.
  static bool containsUrdu(String text) {
    final urduRegex = RegExp(r'[\u0600-\u06FF]');
    return urduRegex.hasMatch(text);
  }

  /// Returns 'ur' for Urdu, 'en' for English (as default).
  static String detectLanguage(String text) {
    return containsUrdu(text) ? 'ur' : 'en';
  }
}
