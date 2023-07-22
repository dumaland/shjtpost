import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future<List<String>> getUserGroups(String userId) async {
    try {
      final userGroups = <String>[];
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('groups')
          .get();

      for (final doc in querySnapshot.docs) {
        userGroups.add(doc.id);
      }

      return userGroups;
    } catch (e) {
      // Handle any potential errors here
      logger.d('Error fetching user groups: $e');
      return [];
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

  Future<void> addGroup(
      String groupName, File? groupAvatar, List<String> groupUsers) async {
    try {
      final DocumentReference groupRef = _firestore.collection('groups').doc();
      final groupId = groupRef.id;

      String? avatarUrl;
      if (groupAvatar != null) {
        final storageRef =
            FirebaseStorage.instance.ref().child('group_avatars/$groupId.jpg');
        await storageRef.putFile(groupAvatar);
        avatarUrl = await storageRef.getDownloadURL();
      }

      await groupRef.set({
        'id': groupId,
        'name': groupName,
        'avatarUrl': avatarUrl,
        'members': groupUsers,
      });

      final userId = FirebaseAuth.instance.currentUser!.uid;

      for (final user in groupUsers) {
        final groupUserRef = _firestore
            .collection('users')
            .doc(user)
            .collection('groups')
            .doc(groupId);

        await groupUserRef.set({});
      }

      // Add the current user to the group users
      final currentUserGroupRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('groups')
          .doc(groupId);

      await currentUserGroupRef.set({});

      // Add the new group to the user's list of groups
      final userGroupsRef =
          _firestore.collection('users').doc(userId).collection('groups');

      await userGroupsRef.doc(groupId).set({});

      logger.d('Group added successfully');
    } catch (e) {
      logger.d('Error adding group: $e');
    }
  }

  Future<Map<String, dynamic>?> getGroupInfo(String groupId) async {
    try {
      final DocumentSnapshot snapshot =
          await _firestore.collection('groups').doc(groupId).get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        return {
          'name': data['name'] as String?,
          'avatarUrl': data['avatarUrl'] as String?,
        };
      }
    } catch (e) {
      logger.d('Error retrieving group info: $e');
    }
    return null;
  }
  Future<List<Map<String, dynamic>>> getAllGroups() async {
  try {
    final QuerySnapshot groupSnapshots =
        await _firestore.collection('groups').get();

    final List<Map<String, dynamic>> groups = [];

    for (final groupDoc in groupSnapshots.docs) {
      final groupId = groupDoc.id;

      final DocumentSnapshot groupSnapshot =
          await _firestore.collection('groups').doc(groupId).get();

      if (groupSnapshot.exists) {
        final groupData = groupSnapshot.data() as Map<String, dynamic>;
        final String groupName = groupData['name'] as String? ?? '';
        final String? groupAvatarUrl = groupData['avatarUrl'] as String?;

        final Map<String, dynamic> groupInfo = {
          'id': groupId,
          'name': groupName,
          'avatarUrl': groupAvatarUrl,
        };
        groups.add(groupInfo);
      }
    }

    return groups;
  } catch (e) {
    logger.d('Error fetching all groups: $e');
    return [];
  }
}

}
