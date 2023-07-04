// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAqrizXCTTZzBgU789CPsiMMmIpg_FpqDM',
    appId: '1:54310924554:web:823f9381534ea6576c4af3',
    messagingSenderId: '54310924554',
    projectId: 'duma-commie',
    authDomain: 'duma-commie.firebaseapp.com',
    storageBucket: 'duma-commie.appspot.com',
    measurementId: 'G-TRMSDERWY2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBzV3sHDtq1odoXkhLM7oDedXj1AJTs0bk',
    appId: '1:54310924554:android:8c8e8c09b4cddb446c4af3',
    messagingSenderId: '54310924554',
    projectId: 'duma-commie',
    storageBucket: 'duma-commie.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyClfFVsDVvaoxLbDU2e2S5O3i_kqKK5f78',
    appId: '1:54310924554:ios:5058f0461890c36a6c4af3',
    messagingSenderId: '54310924554',
    projectId: 'duma-commie',
    storageBucket: 'duma-commie.appspot.com',
    androidClientId: '54310924554-rgak7jf0592cbok2hufe7mq9k4e89uha.apps.googleusercontent.com',
    iosClientId: '54310924554-vfamioq995ucu6ma2on9kacd4oo4u602.apps.googleusercontent.com',
    iosBundleId: 'com.example.dumaland',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyClfFVsDVvaoxLbDU2e2S5O3i_kqKK5f78',
    appId: '1:54310924554:ios:5e5cd96f6e365c266c4af3',
    messagingSenderId: '54310924554',
    projectId: 'duma-commie',
    storageBucket: 'duma-commie.appspot.com',
    androidClientId: '54310924554-rgak7jf0592cbok2hufe7mq9k4e89uha.apps.googleusercontent.com',
    iosClientId: '54310924554-r6mf7oo27rvdhai1uk451h9p4glos46h.apps.googleusercontent.com',
    iosBundleId: 'com.example.dumaland.RunnerTests',
  );
}
