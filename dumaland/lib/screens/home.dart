import 'package:dumaland/screens/loading.dart';
import 'package:dumaland/screens/profile.dart';
import 'package:dumaland/screens/search.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../logic/authentication.dart';
import 'package:lottie/lottie.dart';
import 'package:dumaland/shared/constant.dart';
import 'package:dumaland/logic/data.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  Stream<QuerySnapshot>? groupStream;
  String? userName;
  String? avatarUrl;
  List<String> groups = [];
  File? selectedImage;
  File? groupAvatar;
  final TextEditingController _nameController = TextEditingController();
  Stream? group;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
    getUserGroups();
    refreshGroups();
  }

  Future<void> refreshGroups() async {
    if (widget.user != null) {
      final uid = widget.user!.uid;
      final userGroups = await _databaseService.getUserGroups(uid);
      setState(() {
        groupStream = FirebaseFirestore.instance
            .collection('groups')
            .where('members', arrayContains: uid)
            .snapshots();
        groups = userGroups;
      });
    }
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

  Future<void> getUserGroups() async {
    if (widget.user != null) {
      final uid = widget.user!.uid;
      final userGroups = await _databaseService.getUserGroups(uid);
      setState(() {
        groups = userGroups;
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
          'Chat rooms',
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
          Lottie.asset('assets/imgs/nyancat.json'),
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
      body: _isLoading ? const LoadingScreen() : groupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialog(context);
        },
        elevation: 0,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  Widget groupList() {
    return StreamBuilder<QuerySnapshot>(
      stream: groupStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }

        final List<Widget> groupTiles = [];

        for (var document in snapshot.data!.docs) {
          final groupId = document.id;

          final tile = FutureBuilder<Map<String, dynamic>?>(
            future: _databaseService.getGroupInfo(groupId),
            builder: (BuildContext context,
                AsyncSnapshot<Map<String, dynamic>?> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingScreen();
              }

              if (snapshot.hasData) {
                final groupName = snapshot.data?['name'] as String?;
                final avatarUrl = snapshot.data?['avatarUrl'] as String?;

                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(avatarUrl ?? ''),
                    ),
                    title: Text(
                      groupName ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                    onTap: () {
                      // Handle group tile onTap action using the groupId, groupName, and avatarUrl
                    },
                  ),
                );
              } else {
                return const Text('Error');
              }
            },
          );

          groupTiles.add(tile);
        }

        return ListView(
          padding: const EdgeInsets.all(8),
          children: groupTiles,
        );
      },
    );
  }

  void popUpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController groupNameController =
            TextEditingController();
        File? selectedImage;

        return _isLoading
            ? const LoadingScreen()
            : AlertDialog(
                title: const Text('Add Group'),
                content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: groupNameController,
                          decoration:
                              const InputDecoration(labelText: 'Group Name'),
                        ),
                        const SizedBox(height: 16.0),
                        GestureDetector(
                          onTap: () async {
                            final pickedFile =
                                await _databaseService.selectPicture();
                            if (pickedFile != null) {
                              setState(() {
                                selectedImage = File(pickedFile.path);
                              });
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
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
                      ],
                    );
                  },
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      _toggleLoading();
                      final groupName = groupNameController.text;
                      if (groupName.isNotEmpty) {
                        final userId = FirebaseAuth.instance.currentUser!.uid;
                        final groupUsers = [userId];
                        await DatabaseService()
                            .addGroup(groupName, selectedImage, groupUsers);
                        Navigator.of(context).pop();
                        refreshGroups();
                        _toggleLoading();
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
      },
    );
  }

  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }
}
