import 'dart:io';
import 'package:dumaland/screens/home.dart';
import 'package:dumaland/screens/loading.dart';
import 'package:dumaland/screens/profile.dart';
import 'package:dumaland/screens/search.dart';
import 'package:dumaland/shared/constant.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:logger/logger.dart';
import 'package:lottie/lottie.dart';
import 'package:dumaland/logic/data.dart';
import 'package:dumaland/logic/authentication.dart';
import 'package:intl/intl.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';


class ChatRoom extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String groupAvatarUrl;
  final User? user;

  const ChatRoom({Key? key, required this.groupId, required this.groupName, required this.groupAvatarUrl, this.user})
      : super(key: key);

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final Logger logger = Logger(
    printer: PrettyPrinter(),
  );
  
  final DatabaseService _databaseService = DatabaseService();
  final AuthenticationService _authenticationService = AuthenticationService();
  PlatformFile? pickedfile;
  String? userName;
  String? avatarUrl;
  File? selectedImage;
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() {
    final message = _messageController.text.trim();
    final name = userName ?? '';
    if (message.isNotEmpty) {
      _databaseService.sendMessage(widget.groupId, message, widget.user!.uid, name);
      _messageController.clear();
    }
  }

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
        title: Padding(
          padding: const EdgeInsets.only(left: 0),
          child: Transform.translate(
             offset: const Offset(-20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(widget.groupAvatarUrl),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.groupName,
                  style: const TextStyle(fontSize: 24),
                ),
              ],
            ),
          ),
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
            onTap: () {Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(user: widget.user)),
              );},
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.person),
            title: const Text('Home'),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Search(user: widget.user)),
              );
            },
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
          Expanded(
            child: StreamBuilder<List<Message>>(
  stream: _databaseService.getMessagesStream(widget.groupId),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final messages = snapshot.data;
      return ListView.builder(
        reverse: true,
        itemCount: messages?.length ?? 0,
        itemBuilder: (context, index) {
          final message = messages![index];
          final isCurrentUser = message.senderId == widget.user?.uid; // The identity check you've provided
          return FutureBuilder<String?>(
            future: _databaseService.getUserName(message.senderId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final senderName = snapshot.data!;
                return ChatBubble(
                  clipper: ChatBubbleClipper4(type: isCurrentUser ? BubbleType.sendBubble : BubbleType.receiverBubble),
                  alignment: isCurrentUser ? Alignment.topRight : Alignment.topLeft,
                  margin: const EdgeInsets.only(top: 20),
                  backGroundColor: isCurrentUser ? const Color(0xff2b9ed4) : const Color.fromARGB(0, 92, 89, 89),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(message.message, style: const TextStyle(color: Colors.white, fontSize: 22)),
                        const SizedBox(height: 4.0),
                        Text(senderName, style: const TextStyle(color: Colors.black, fontSize: 10.0)),
                        const SizedBox(height: 2.0),
                        Text(DateFormat('MMM d, yyyy - HH:mm').format(message.timestamp.toLocal()), style: const TextStyle(color: Colors.black, fontSize: 10.0)),
                      ],
                    ),
                  ),
                );
              } else {
                return const ListTile(
                  title: Text('Unknown Sender'),
                  subtitle: Text('Loading...'),
                  trailing: CircularProgressIndicator(),
                );
              }
            },
          );
        },
      );
    } else {
      return const LoadingScreen();
    }
  },
)
          ),          
          Padding(
   padding: const EdgeInsets.all(8.0),
  child: Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey), 
      color: Colors.grey[100], 
    ),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              hintText: 'Type your message...',
              border: InputBorder.none, 
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        ),
        IconButton(
          onPressed: _sendMessage,
          icon: const Icon(Icons.send),
        ),
      ],
    ),
  ),
),

        ],
      ),
    );
  }
}
