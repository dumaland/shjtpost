import 'package:dumaland/screens/loading.dart';
import 'package:dumaland/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../logic/authentication.dart';
import 'package:lottie/lottie.dart';
import 'package:dumaland/shared/constant.dart';
import 'package:dumaland/logic/data.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'home.dart';

class Search extends StatefulWidget {
  final User? user;

  const Search({Key? key, this.user}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final AuthenticationService _authenticationService = AuthenticationService();
  final DatabaseService _databaseService = DatabaseService();
  PlatformFile? pickedfile;
  Stream<QuerySnapshot>? groupStream;
  String? userName;
  String? avatarUrl;  
  List<Map<String, dynamic>> groups = [];
  List<Map<String, dynamic>> _chatRooms = [];
  File? selectedImage;
  File? groupAvatar;
  final TextEditingController _nameController = TextEditingController();
  Stream? group;
  bool _isLoading = false;  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUserInfo();
    refreshGroups();
  }

Future<void> refreshGroups() async {
  if (widget.user != null) {
    final userGroups = await _databaseService.getAllGroups();
    setState(() {
      groupStream = FirebaseFirestore.instance
          .collection('groups')
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

void _onSearch() {
  String searchTerm = _searchController.text.toLowerCase();
  if (searchTerm.isEmpty) {
    setState(() {
      _chatRooms.clear();
    });
  } else {
    setState(() {
      _chatRooms = groups
          .where((group) => group['name'].toLowerCase().startsWith(searchTerm))
          .toList();
    });
  }
  if (_chatRooms.isEmpty) {
    const snackBar = SnackBar(
      content: Text('No room with the name provided'),
      duration: Duration(seconds: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}  

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
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
                                    100), 
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
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomePage(user: widget.user)),
              );
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.person),
            title: const Text('Home'),
          ),
          ListTile(
            onTap: () {},
                        selectedColor: Colors.cyan,
            selected: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.search),
            title: const Text('Search'),
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
      body: _isLoading ? const LoadingScreen() : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,

              decoration: InputDecoration(
                labelText: 'Search for chat rooms',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _onSearch,
                ),
              ),
              onSubmitted: (_) => _onSearch(),
            ),
          ),
          Expanded(
            child: _chatRooms.isEmpty
                ? StreamBuilder<QuerySnapshot>(
                    stream: groupStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const LoadingScreen();
                         }

                      final chatRooms = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: chatRooms.length,
                        itemBuilder: (context, index) {
                          final chatRoom = chatRooms[index];
                          return Container(
                            decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                            child: ListTile(
                              title: Text(chatRoom['name']),
                              leading: chatRoom['avatarUrl'] != null
                                  ? CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(chatRoom['avatarUrl']),
                                    )
                                  : const CircleAvatar(
                                      backgroundImage:
                                          AssetImage('assets/imgs/mini-1.png'),
                                    ),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  // Implement the join button logic here...
                                },
                                child: const Text('Join'),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                : SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: ListView.builder(
                      itemCount: _chatRooms.length,
                      itemBuilder: (context, index) {
                        final chatRoom = _chatRooms[index];
                        return Container(
                          decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                          child: ListTile(
                            title: Text(chatRoom['name']),
                            leading: chatRoom['avatarUrl'] != null
                                ? CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(chatRoom['avatarUrl']),
                                  )
                                : const CircleAvatar(
                                    backgroundImage:
                                        AssetImage('assets/imgs/mini-1.png'),
                                  ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                // Implement the join button logic here...
                              },
                              child: const Text('Join'),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );  
  }
    void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }
}
