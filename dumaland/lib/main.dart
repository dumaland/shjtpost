import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'logic/authentication.dart';
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
  User? currentUser;
  late AuthenticationService authService;

  @override
  void initState() {
    super.initState();
    authService = AuthenticationService();
    authService.initialize().then((_) {
      setState(() {
        isLoggedIn = authService.getLoginStatus();
      });
    });
    checkLoggedInStatus();
  }

  void checkLoggedInStatus() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          isLoggedIn = true;
          currentUser = user;
          authService
              .saveLoginStatus(true); // Store login status in SharedPreferences
        });
      } else {
        setState(() {
          isLoggedIn = false;
          currentUser = null;
          authService.saveLoginStatus(
              false); // Store login status in SharedPreferences
        });
      }
    });
  }

  bool getLoginStatus() {
    return authService.getLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Duma Land',
      initialRoute: getLoginStatus() ? '/home' : '/login',
      routes: {
        '/': (context) => const LoginPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => HomePage(user: currentUser),
      },
    );
  }
}
