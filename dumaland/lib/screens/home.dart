import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../logic/authentication.dart';

class HomePage extends StatelessWidget {
  final User? user;
  final AuthenticationService _authenticationService = AuthenticationService();
  HomePage({Key? key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the user object to display user-specific content
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome ${user?.displayName ?? ''}',
          style: TextStyle(fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Perform sign-out when the button is pressed
              FirebaseAuth.instance.signOut();
              await _authenticationService.signOut();
              // ignore: use_build_context_synchronously
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Adu vjp',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
