import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dumaland/screens/search.dart';
import 'package:dumaland/shared/constant.dart';
import 'package:lottie/lottie.dart';
import 'package:dumaland/logic/data.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../logic/authentication.dart';
import 'home.dart';

class Profile extends StatefulWidget {
  final User? user;

  const Profile({Key? key, this.user}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final AuthenticationService _authenticationService = AuthenticationService();
  final DatabaseService _databaseService = DatabaseService();
  PlatformFile? pickedfile;
  String? userName;
  String? avatarUrl;
  File? selectedImage;
  final TextEditingController _nameController = TextEditingController();

  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    if (widget.user != null) {
      final uid = widget.user!.uid;
      final name = await _databaseService.getUserName(uid);
      String? userAvatarUrl = await _databaseService.getUserAvatar(uid);
      setState(() {
        userName = name;
        avatarUrl = userAvatarUrl;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _openDrawer(context),
            );
          },
        ),
        backgroundColor: Colors.blue[200],
        title: const Text(
          'Profile',
          style: TextStyle(fontSize: 24),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Search()),
              );
            },
            icon: const Icon(
              Icons.search,
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 0),
          children: <Widget>[
            Lottie.network(
                'https://lottie.host/9b8518cb-417e-4f50-bef7-e8109642573d/dnrWvzAvij.json'),
            Text(
              userName != "Change your name and avatar in settings"
                  ? 'Welcome ${userName ?? ''}'
                  : "Change your name and avatar in settings",
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(
              height: 30,
            ),
            const Divider(
              height: 2,
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomePage(user: widget.user)),
                );
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.groups),
              title: const Text('Home'),
            ),
            ListTile(
              onTap: () {},
              selectedColor: Colors.cyan,
              selected: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.groups),
              title: const Text('Profile'),
            ),
            ListTile(
              onTap: () async {
                FirebaseAuth.instance.signOut();
                await _authenticationService.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Logout'),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Display User Name and Avatar
            CircleAvatar(
              radius: 100,
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl!)
                  : const AssetImage('assets/imgs/mini-1.png')
                      as ImageProvider<Object>,
            ),
            const SizedBox(height: 16.0),
            Text(
              userName ?? '',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),

            const Divider(height: 2),
            const SizedBox(height: 16.0),

            // "Change user name and avatar" Text
            const Text(
              'Change user name and avatar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16.0),

            // Rest of the Widgets
            GestureDetector(
              onTap: () async {
                final pickedFile = await _databaseService.selectPicture();
                if (pickedFile != null) {
                  setState(() {
                    selectedImage = pickedFile;
                  });
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                    100), // Adjust the value to your desired roundness
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                      image: selectedImage != null
                          ? FileImage(selectedImage!)
                          : const AssetImage('assets/imgs/mini-1.png')
                              as ImageProvider<Object>,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              decoration: textinputdecorations.copyWith(
                labelText: 'Your name',
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_nameController.text.isNotEmpty) {
                    final uid = widget.user!.uid;
                    final name = _nameController.text;
                    await _databaseService.updateUser(uid, name, selectedImage);
                    _nameController.clear();
                    selectedImage = null;
                    await loadUserInfo();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Success'),
                          content: const Text('User name and avatar updated.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: const Text('Update Name and Avatar'),
              ),
            ),
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  FirebaseAuth.instance.signOut();
                  await _authenticationService.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text('Sign Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
