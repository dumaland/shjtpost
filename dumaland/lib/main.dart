import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login.dart';
import 'screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      appId: 'DUMA',
      apiKey: 'AIzaSyBzV3sHDtq1odoXkhLM7oDedXj1AJTs0bk',
      projectId: 'duma-commie',
      messagingSenderId: '54310924554',
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Duma Land',
      initialRoute: isLoggedIn ? '/home' : '/login',
      routes: {
        '/': (context) => const LoginPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
