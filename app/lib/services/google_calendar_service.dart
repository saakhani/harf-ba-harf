import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:http/http.dart' as http;

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    calendar.CalendarApi.calendarReadonlyScope,
  ],
);

class GoogleCalendarService {
  Future<List<calendar.Event>> fetchUpcomingEvents() async {
    final account = await _googleSignIn.signIn();
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