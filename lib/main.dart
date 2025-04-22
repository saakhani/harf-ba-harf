import 'package:flutter/material.dart';
import 'package:harf_ba_harf/screens/login.dart';
import 'package:harf_ba_harf/screens/signup.dart';
import 'package:harf_ba_harf/screens/splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // Set HomePage as the initial route
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => SignUpPage(),
      },
    );
  }
}