import 'package:dumaland/screens/profile.dart';
import 'package:dumaland/screens/search.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../logic/authentication.dart';
import 'package:lottie/lottie.dart';
import 'package:dumaland/shared/constant.dart';
import 'package:dumaland/logic/data.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  final User? user;

  const HomePage({Key? key, this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthenticationService _authenticationService = AuthenticationService();
  final DatabaseService _databaseService = DatabaseService();
  PlatformFile? pickedfile;
  String? userName;
  String? avatarUrl;
  File? selectedImage;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
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
          'Wjbu Verse',
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
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Column(
                          children: [
                            const Text('Click to choose your new avatar'),
                            GestureDetector(
                              onTap: () async {
                                final pickedFile =
                                    await _databaseService.selectPicture();
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
                                          : const AssetImage(
                                                  'assets/imgs/mini-1.png')
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
                                    await _databaseService.updateUser(
                                        uid, name, selectedImage);
                                    _nameController.clear();
                                    selectedImage = null;
                                    await loadUserInfo();
                                    // ignore: use_build_context_synchronously
                                    Navigator.pop(context);
                                  }
                                },
                                child:
                                    const Text('Update User Name and Avatar'),
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                child: const Text('Sign Out'),
                                onPressed: () async {
                                  FirebaseAuth.instance.signOut();
                                  await _authenticationService.signOut();
                                  // ignore: use_build_context_synchronously
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/login',
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(
                                        context); // Close the AlertDialog
                                  },
                                  child: const Text('Close')),
                            )
                          ],
                        );
                      },
                    ),
                  );
                },
              );
            },
            child: avatarUrl != null
                ? CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(avatarUrl!),
                  )
                : Lottie.network(
                    'https://assets9.lottiefiles.com/packages/lf20_fgp8rk11.json',
                    width: 50,
                    height: 50,
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
            userName != "Change ur name and avatar in settings"
                ? 'Welcome ${userName ?? ''}'
                : "Change ur name and avatar in settings",
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
            onTap: () {},
            selectedColor: Colors.cyan,
            selected: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.groups),
            title: const Text('Home'),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Profile(user: widget.user)),
              );
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.groups),
            title: const Text('Profile'),
          ),
          ListTile(
            onTap: () async {
              FirebaseAuth.instance.signOut();
              await _authenticationService.signOut();
              // ignore: use_build_context_synchronously
              Navigator.pushReplacementNamed(
                context,
                '/login',
              );
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
          ),
        ],
      )),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Adu vjp',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
