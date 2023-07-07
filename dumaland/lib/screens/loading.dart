import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(), // A circular progress indicator to indicate loading
            SizedBox(height: 16), // Adding some spacing below the indicator
            Text(
              'Loading...', // A text to indicate that the app is loading
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
