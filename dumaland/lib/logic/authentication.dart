import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

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
          await _firebaseAuth.signOut(); // Sign out the user
          throw 'Email not verified. Please check your email and verify your account.';
        }
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Sign up with email and password
  Future<String?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;
      if (user != null) {
        await user.sendEmailVerification(); // Send email verification
        return user.uid;
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  // Check if email is already taken
  Future<bool> checkIfEmailTaken(String email) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: 'temp_password',
      );
      await userCredential.user?.delete();
      return false;
    } catch (e) {
      print('Error: $e');
    }
    return true; // Email is already taken
  }
  //forgot password
}
