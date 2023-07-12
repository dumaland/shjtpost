import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:logger/logger.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger logger = Logger(
    printer: PrettyPrinter(),
  );

  Future<void> initializeSharedPreferences() async {}

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

  Future<String?> getUserName(String uid) async {
    try {
      final DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(uid).get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        return data['name'] as String?;
      }
    } catch (e) {
      logger.d('Error retrieving user name: $e');
    }
    return null;
  }

  Future<String?> getUserAvatar(String uid) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('avatars/$uid.jpg');
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      logger.d('Error getting user avatar: $e');
      return null;
    }
  }

  Future<File?> selectPicture() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      final pickedFile = File(result.files.single.path!);
      return pickedFile;
    }
    return null;
  }

  Future<void> updateUser(String uid, String name, File? picture) async {
    try {
      await _firestore.collection('users').doc(uid).update({'name': name});

      if (picture != null) {
        final storageRef =
            FirebaseStorage.instance.ref().child('avatars/$uid.jpg');
        await storageRef.putFile(picture);
        final avatarUrl = await storageRef.getDownloadURL();
        await _firestore
            .collection('users')
            .doc(uid)
            .update({'avatarUrl': avatarUrl});
      }
    } catch (e) {
      logger.d('Error updating user: $e');
    }
  }
}
