// profile_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:harf_ba_harf/services/app_colors.dart';
import 'package:harf_ba_harf/services/text_styles.dart';
import 'package:harf_ba_harf/widgets/navbar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _handleChangePassword(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final providers = user.providerData;
    final isGoogle = providers.any((p) => p.providerId == 'google.com');
    if (isGoogle) {
      Fluttertoast.showToast(
        msg: 'Password change is not available for Google accounts.',
        backgroundColor: Colors.orange.shade700,
        textColor: Colors.white,
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
      Fluttertoast.showToast(
        msg: 'Password reset email sent! Check your inbox.',
        backgroundColor: Colors.blue.shade700,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: $e',
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final providers = user.providerData;
    final isGoogle = providers.any((p) => p.providerId == 'google.com');
    if (isGoogle) {
      // Google user: reauthenticate with Google
      try {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return; // Cancelled
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await user.reauthenticateWithCredential(credential);
        await user.delete();
        // Mark user as deleted in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'deleted': true});
        Fluttertoast.showToast(
          msg: 'Account deleted successfully.',
          backgroundColor: Colors.green.shade700,
          textColor: Colors.white,
        );
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'Error: $e',
          backgroundColor: Colors.red.shade700,
          textColor: Colors.white,
        );
      }
      return;
    }
    String? password = await showDialog<String>(
      context: context,
      builder: (context) {
        final TextEditingController pwController = TextEditingController();
        bool obscure = true;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Confirm Account Deletion'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Enter your password to delete your account:'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pwController,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => obscure = !obscure),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, pwController.text),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
    );
    if (password == null || password.isEmpty) return;
    try {
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(cred);
      // ✅ Mark user as deleted in Firestore first
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'deleted': true},
      );

      // ✅ Then delete the user from Firebase Auth
      await user.delete();

      // ✅ Sign out
      Fluttertoast.showToast(
        msg: 'Account deleted successfully.',
        backgroundColor: Colors.green.shade700,
        textColor: Colors.white,
      );
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: $e',
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: Center(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // <-- left align heading
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 4.0),
              child: Text(
                "Calendar",
                style: AppTextStyles.pageTitle.copyWith(
                  color: AppColors.blackish,
                ),
                textAlign: TextAlign.left, // ensure left alignment
              ),
            ),
            // force
            const SizedBox(height: 24),
            if (user != null)
              FutureBuilder<List<UserInfo>>(
                future: Future.value(user.providerData),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final isGoogle = snapshot.data!.any(
                    (p) => p.providerId == 'google.com',
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed:
                            isGoogle
                                ? null
                                : () => _handleChangePassword(context),
                        child: const Text('Change Password'),
                      ),
                      if (isGoogle)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Password change is not available for Google accounts.',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => _handleDeleteAccount(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Delete Account'),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: FloatingNavBar(
        context: context,
        currentIndex: 4, // Calendar is index 1
      ),
    );
  }
}
