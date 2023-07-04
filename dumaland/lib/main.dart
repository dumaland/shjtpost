import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
