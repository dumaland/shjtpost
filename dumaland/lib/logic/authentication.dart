import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Logger logger = Logger(
    printer: PrettyPrinter(),
  );

  // Sign in with email and password
  Future<String?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      final User? user = userCredential.user;
      if (user != null) {
        if (user.emailVerified) {
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

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Sign up with email and password
  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;
      if (user != null) {
        await user.sendEmailVerification(); // Send email verification
        return true;
      }
    } catch (e) {
      logger.d('Error: $e');
    }
    return false;
  }

  // Check if email is already taken
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

  // Forgot password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      logger.d('Error: $e');
    }
  }
}
