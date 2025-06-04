import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:harf_ba_harf/providers/upload_progress_provider.dart';
import 'package:harf_ba_harf/screens/verify_email.dart';
import 'package:harf_ba_harf/services/app_colors.dart';
import 'package:harf_ba_harf/services/text_styles.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import 'models/meeting_model.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';

import 'screens/calendar.dart';
import 'screens/file_transcription.dart';
import 'screens/history.dart';
import 'screens/home.dart';
import 'screens/live_transcription.dart';
import 'screens/login.dart';
import 'screens/meeting_detail.dart';
import 'screens/profile.dart';
import 'screens/signup.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Ensure theme is ready before app launches
  runApp(const MyAppWithProviders());
}

class MyAppWithProviders extends StatelessWidget {
  const MyAppWithProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UploadProgressProvider()),
        ChangeNotifierProvider(create: (_) => CustomAuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Harf Ba Harf',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.mainSageGreen, // your main brand color
        ),
        brightness: Brightness.light,
        fontFamily: GoogleFonts.outfit().fontFamily,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.blackish,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mainSageGreen,
            foregroundColor: AppColors.white,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: AppTextStyles.body1,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.mainSageGreen),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 5,
          margin: EdgeInsets.all(12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      home: const AuthGate(),
      routes: {
        '/home': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/calendar': (context) => const CalendarPage(),
        '/history': (context) => HistoryPage(),
        '/profile': (context) => const ProfilePage(),
        '/live-transcription': (context) => const LiveTranscriptionPage(),
        '/file-transcription': (context) => const FileTranscriptionPage(),
        '/verify-email': (context) => const VerifyEmailPage(),
        '/meeting-detail': (context) {
          final meeting = ModalRoute.of(context)!.settings.arguments as Meeting;
          return MeetingDetailPage(meeting: meeting);
        },
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserIfAuthenticated();
    });
  }

  Future<void> _loadUserIfAuthenticated() async {
    final authProvider = Provider.of<CustomAuthProvider>(
      context,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (authProvider.user != null) {
      await userProvider.loadUser(); // 🔥 Loads Firestore user profile
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<CustomAuthProvider>(context);
    final isAuth = authProvider.user != null;

    if (_isLoading || authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Replace with your actual logo asset path
              SizedBox(
                height: 100,
                child: Image(image: AssetImage('assets/icon/app_icon.png')),
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(),
            ],
          ),
        ),
      );
    }

    if (!isAuth) {
      return const LoginPage();
    } else if (!authProvider.user!.emailVerified) {
      return const VerifyEmailPage();
    } else {
      return HomePage();
    }
  }
}
