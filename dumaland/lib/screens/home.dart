import 'package:dumaland/screens/loading.dart';
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
  bool _isLoading = false;
  String? userName;
  String? avatarUrl;
  File? selectedImage;
  final TextEditingController _nameController = TextEditingController();

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
        leading: Lottie.network(
          'https://assets6.lottiefiles.com/packages/lf20_jpxsQh.json',
        ),
        backgroundColor: Colors.blue[200],
        title: Text(
          userName != "Change ur name and avatar in settings"
              ? 'Welcome ${userName ?? ''}'
              : "Change ur name and avatar in settings",
          style: const TextStyle(fontSize: 24),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return _isLoading
                      ? const LoadingScreen()
                      : AlertDialog(
                          content: StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return Column(
                                children: [
                                  const Text('Click to choose your new avatar'),
                                  GestureDetector(
                                    onTap: () async {
                                      _toggleLoading();
                                      final pickedFile = await _databaseService
                                          .selectPicture();
                                      if (pickedFile != null) {
                                        setState(() {
                                          selectedImage = pickedFile;
                                        });
                                      }
                                      _toggleLoading();
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
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (_nameController.text.isNotEmpty) {
                                        _toggleLoading();
                                        final uid = widget.user!.uid;
                                        final name = _nameController.text;
                                        await _databaseService.updateUser(
                                            uid, name, selectedImage);
                                        _nameController.clear();
                                        selectedImage = null;
                                        await loadUserInfo();
                                        _toggleLoading();
                                        // ignore: use_build_context_synchronously
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: const Text(
                                        'Update User Name and Avatar'),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
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
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context); // Close the AlertDialog
                                      },
                                      child: const Text('Close'))
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
          const Drawer(),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Adu vjp',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }
}
