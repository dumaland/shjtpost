import 'package:flutter/material.dart';
import 'authentication.dart';

class HomePage extends StatelessWidget {
  final AuthenticationService _authenticationService = AuthenticationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authenticationService.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Adu ma vjp vc?'),
      ),
    );
  }
}
