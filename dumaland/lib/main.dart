import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login.dart';
import 'screens/home.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  late User? currentUser;
  @override
  void initState() {
    super.initState();
    initializeFirebase();
    checkLoggedInStatus();
  }

  // Initialize Firebase
  void initializeFirebase() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        appId: 'DUMA',
        apiKey: 'AIzaSyBzV3sHDtq1odoXkhLM7oDedXj1AJTs0bk',
        projectId: 'duma-commie',
        messagingSenderId: '54310924554',
      ),
    );
  }

  // Check if user is logged in
  void checkLoggedInStatus() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          isLoggedIn = true;
          currentUser = user;
        });
      } else {
        setState(() {
          isLoggedIn = false;
          currentUser = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Duma Land',
      initialRoute: isLoggedIn ? '/home' : '/login',
      routes: {
        '/': (context) => const LoginPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) =>
            HomePage(user: currentUser), // Pass the current user to HomePage
      },
    );
  }
}
