import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger logger = Logger(
    printer: PrettyPrinter(),
  );

  Future<void> addUser(
      String uid, String email, String password, String name) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'password': password,
        'name': name,
      });
    } catch (e) {
      logger.d('Error adding user to Firestore: $e');
    }
  }
}
