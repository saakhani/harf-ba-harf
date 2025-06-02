import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  User? get user => FirebaseAuth.instance.currentUser;

  bool _isSending = false;
  int _resendCooldown = 60;
  Timer? _cooldownTimer;
  Timer? _autoCheckTimer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
    _startAutoVerificationCheck();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _autoCheckTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendCooldown == 0) {
        timer.cancel();
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  void _startAutoVerificationCheck() {
    _autoCheckTimer = Timer.periodic(Duration(seconds: 5), (_) async {
      await user?.reload();
      if (user != null && user!.emailVerified) {
        _autoCheckTimer?.cancel();

        Fluttertoast.showToast(
          msg: "✅ Email verified! Redirecting...",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green.shade600,
          textColor: Colors.white,
          fontSize: 16,
        );

        await Future.delayed(Duration(seconds: 1));
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  Future<void> _resendVerification() async {
    setState(() => _isSending = true);
    try {
      await user?.sendEmailVerification();
      Fluttertoast.showToast(
        msg: "📧 Verification email sent!",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.blue.shade600,
        textColor: Colors.white,
      );
      setState(() => _resendCooldown = 60);
      _startCooldown();
    } catch (e) {
      Fluttertoast.showToast(
        msg: "❌ Error sending email: $e",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    }
    setState(() => _isSending = false);
  }

  Future<void> _manualCheck() async {
    await user?.reload();
    if (user != null && user!.emailVerified) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Fluttertoast.showToast(
        msg: "🚫 Still not verified. Check your inbox.",
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.red.shade600,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify Your Email")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.mark_email_read_rounded, size: 80, color: Colors.blue),
              SizedBox(height: 20),
              Text(
                "A verification email has been sent to:",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                user?.email ?? "",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _resendCooldown > 0 ? null : _resendVerification,
                child:
                    _isSending
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("Resend Email (${_resendCooldown}s)"),
              ),
              TextButton(
                onPressed: _manualCheck,
                child: Text("I have verified"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
