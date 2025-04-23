import 'package:flutter/material.dart';
import 'package:harf_ba_harf/screens/signup.dart';
import 'package:harf_ba_harf/utilities/google_signin.dart';

class LoginPage extends StatelessWidget {
  final GoogleAuthService _authService = GoogleAuthService();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          // ... (keep all your existing UI)
          children: [
            // ... (other widgets)
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final user =
                      await _authService.signInWithGoogle(); // 1. Sign in
                  if (user != null) {
                    Navigator.pushReplacementNamed(
                      context,
                      '/home',
                    ); // 2. Navigate only
                  }
                },
                child: Text("Sign in with Google"),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage()),
                  );
                },
                child: const Text("Don't have an account? Sign Up"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
