import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/material.dart'; 
import 'package:harf_ba_harf/utilities/google_signin.dart'; 

// Define a stateless widget for the HomeScreen
class HomePage extends StatelessWidget {
    
  // Firebase User object to hold user details
  final User user; 
  HomePage(
      {super.key,
      
      // Constructor to initialize the user object
      required this.user}); 

  // Instance of GoogleAuthService for authentication
  final GoogleAuthService _authService = GoogleAuthService(); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            
            // Display user's name in the app bar
            "Welcome ${user.displayName}"), 
      ),
      body: Center(
        child: Column(
          mainAxisAlignment:MainAxisAlignment.center, 
          crossAxisAlignment:CrossAxisAlignment.center,
          children: [
            CircleAvatar(
                
              // Display user's profile picture
              backgroundImage: NetworkImage(user.photoURL ?? ""), 
              
              // Set the radius of the avatar
              radius: 40, 
            ),
            
            // Display user's email
            Text("Email: ${user.email}"),
            
            // Add spacing between elements
            SizedBox(height: 20), 
            ElevatedButton(
              onPressed: () async {
                
                // Sign out from Google and Firebase
                _authService.signOut();
                
                // Navigate back to the sign-in screen
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red.shade900,
              ),
              child: Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }
}
