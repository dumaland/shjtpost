import 'package:flutter/material.dart';
import 'authentication_logic.dart';

class HomePage extends StatelessWidget {
  final AuthenticationService _authenticationService = AuthenticationService();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authenticationService.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Adu ma vjp vc?'),
      ),
    );
  }
}
