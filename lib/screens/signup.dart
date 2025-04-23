import 'package:flutter/material.dart';
import 'package:harf_ba_harf/utilities/google_signin.dart';
class SignUpPage extends StatelessWidget {
  final GoogleAuthService _authService = GoogleAuthService();

  SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            const Text(
              "Let's Get Started!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            // Name Field
            TextField(
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Email Field
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Password Field
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Divider
            const Divider(thickness: 1),
            const SizedBox(height: 20),

            // Sign Up Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {},
                child: const Text('Sign Up'),
              ),
            ),
            const SizedBox(height: 30),

            // Or sign up with
            const Center(
              child: Text(
                'Or sign up with',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),

            // Zoom Button
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

            // Already have account
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context); // Goes back to login page
                },
                child: const Text('Already have an account? Log In'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
