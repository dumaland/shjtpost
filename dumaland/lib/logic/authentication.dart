import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';
import 'package:dumaland/logic/data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final DatabaseService _databaseService = DatabaseService();
  final Logger logger = Logger(
    printer: PrettyPrinter(),
  );
  late SharedPreferences _prefs;

  Future<void> initialize() async {
    await Firebase.initializeApp();
    await initializeSharedPreferences();
  }

  Future<void> initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool getLoginStatus() {
    return _prefs.getBool('isLoggedIn') ?? false;
  }

  Future<void> saveLoginStatus(bool isLoggedIn) async {
    await _prefs.setBool('isLoggedIn', isLoggedIn);
  }

  Future<String?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      await initializeSharedPreferences();
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      final User? user = userCredential.user;
      if (user != null) {
        if (user.emailVerified) {
          await saveLoginStatus(true);
          return user.uid;
        } else {
          await _firebaseAuth.signOut();
        }
      }
    } catch (e) {
      logger.d('Error: $e');
    }
    return null;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await initializeSharedPreferences(); // Initialize SharedPreferences
    await saveLoginStatus(false);
  }

  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;
      if (user != null) {
        await user.sendEmailVerification();
        const String name = 'Change your name and avatar in settings';
        await _databaseService.addUser(user.uid, email, password, name);
        return true;
      }
    } catch (e) {
      logger.d('Error: $e');
    }
    return false;
  }

  Future<bool> checkIfEmailTaken(String email) async {
    try {
      final List<String> signInMethods =
          await _firebaseAuth.fetchSignInMethodsForEmail(email);
      return signInMethods.isEmpty;
    } catch (e) {
      logger.d('Error: $e');
      return true;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      logger.d('Error: $e');
    }
  }
}
