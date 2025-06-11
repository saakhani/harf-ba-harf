import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:http/http.dart' as http;

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[calendar.CalendarApi.calendarReadonlyScope],
);

class GoogleCalendarService {
  Future<List<calendar.Event>> fetchUpcomingEvents() async {
    // Only sign in if not already signed in
    GoogleSignInAccount? account = _googleSignIn.currentUser;
    if (account == null) {
      account = await _googleSignIn.signInSilently();
    }
    if (account == null) {
      account = await _googleSignIn.signIn();
    }
    if (account == null) return [];

    final authHeaders = await account.authHeaders;
    final client = GoogleAuthClient(authHeaders);

    final calendarApi = calendar.CalendarApi(client);
    final now = DateTime.now().toUtc();
    final events = await calendarApi.events.list(
      "primary",
      timeMin: now,
      maxResults: 10,
      singleEvents: true,
      orderBy: "startTime",
    );
    return events.items ?? [];
  }

  Future<bool> isGoogleCalendarConnected() async {
    return await _googleSignIn.isSignedIn();
  }

  Future<void> connectGoogleCalendar() async {
    await _googleSignIn.signIn();
  }

  Future<void> disconnectGoogleCalendar() async {
    await _googleSignIn.disconnect();
  }

  /// Static method to clear Google Calendar credentials globally
  static Future<void> clearGoogleCalendarCredentials() async {
    await _googleSignIn.disconnect();
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}
