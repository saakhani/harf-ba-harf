//main.dart

import 'package:flutter/material.dart';
import 'package:harf_ba_harf/models/meeting_model.dart';
import 'package:harf_ba_harf/screens/calander.dart';
import 'package:harf_ba_harf/screens/file_transcription.dart';
import 'package:harf_ba_harf/screens/history.dart';
import 'package:harf_ba_harf/screens/home.dart';
import 'package:harf_ba_harf/screens/live_transcription.dart';
import 'package:harf_ba_harf/screens/login.dart';
import 'package:harf_ba_harf/screens/meeting_detail.dart';
import 'package:harf_ba_harf/screens/profile.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:harf_ba_harf/providers/auth_provider.dart';
import 'firebase_options.dart';

import 'screens/signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CustomAuthProvider())],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Consumer<CustomAuthProvider>(
        builder: (context, auth, child) {
          if (auth.isLoading) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return auth.user != null ? HomePage() : LoginPage();
        },
      ),
      routes: {
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/calendar': (context) => const CalendarPage(),
        '/history': (context) => HistoryPage(),
        '/profile': (context) => const ProfilePage(),
        '/live-transcription': (context) => const LiveTranscriptionPage(),
        '/file-transcription': (context) => const FileTranscriptionPage(),
        '/meeting-detail': (context) {
          final meeting = ModalRoute.of(context)!.settings.arguments as Meeting;
          return MeetingDetailPage(meeting: meeting);
        },
      },
    );
  }
}

// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<CustomAuthProvider>(context);
    
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.active) {
//           final user = snapshot.data;
//           if (user != null) {
//             authProvider.setUser(user);
//             return HomePage();
//           }
//           return SplashScreen();
//         }
//         return Scaffold(body: Center(child: CircularProgressIndicator()));
//       },
//     );
//   }
// }