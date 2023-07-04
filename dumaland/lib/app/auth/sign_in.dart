import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dumaland/firebase/auth.dart';

class SignInPage extends StatelessWidget {
  final Auth auth = Auth();

  @override
  Widget build(BuildContext context) {
    final User? currentUser = auth.checkAuthState();

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Duma Land'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (currentUser == null)
              ElevatedButton(
                onPressed: () async {
                  final User? user = await auth.signInAnonymous();
                  if (user != null) {
                    // Anonymous sign-in successful, handle the user object
                    print('Anonymous sign-in successful: ${user.uid}');
                  } else {
                    // Anonymous sign-in failed
                    print('Anonymous sign-in failed.');
                  }
                },
                child: Text('Continue without signing in'),
              ),
            if (currentUser != null)
              Text('User is signed in: ${currentUser.uid}'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Implement regular sign-in with email and password
                final email = 'example@example.com';
                final password = 'password123';
                final User? user =
                    await auth.signInWithEmailAndPassword(email, password);
                if (user != null) {
                  // Regular sign-in successful, handle the user object
                  print('Regular sign-in successful: ${user.uid}');
                } else {
                  // Regular sign-in failed
                  print('Regular sign-in failed.');
                }
              },
              child: Text('Sign In with Email and Password'),
            ),
          ],
        ),
      ),
    );
  }

  User? checkAuthState() {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    return currentUser;
  }
}
