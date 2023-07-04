import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      appId: 'DUMA',
      apiKey: 'AIzaSyBzV3sHDtq1odoXkhLM7oDedXj1AJTs0bk',
      projectId: 'duma-commie',
      messagingSenderId: '54310924554',
      // ...other options
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
