import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Logger logger = Logger(
    printer: PrettyPrinter(),
  );
  //Auth state
  AuthenticationService() {
    _firebaseAuth.setPersistence(Persistence.LOCAL);
  }
  // Sign in with Google
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          return user.uid;
        }
      }
    } catch (e) {
      logger.d('Error: $e');
    }
    return null;
  }

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
      logger.d('Error: $e');
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
      logger.d('Error: $e');
    }
    return true;
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
