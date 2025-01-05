import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_pixel_talks/api/apis.dart';
import 'package:my_pixel_talks/helper/dialogs.dart';
import 'package:my_pixel_talks/models/chat_user.dart';
import 'package:my_pixel_talks/screens/profile_screen.dart';
import 'package:my_pixel_talks/widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    Apis.getSelfInfo();
    Apis.updateActiveStatus(true);
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (Apis.auth.currentUser != null) {
        if (message.toString().contains('paused') ||
            message.toString().contains('inactive')) {
          Apis.updateActiveStatus(false);
        }
        if (message.toString().contains('resume')) {
          Apis.updateActiveStatus(true);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: PopScope(
        canPop: !_isSearching,
        onPopInvokedWithResult: (didPop, result) {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: const Icon(CupertinoIcons.home),
            title: _isSearching
                ? TextField(
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Username, Email, ....'),
                    autofocus: true,
                    style: const TextStyle(fontSize: 16, letterSpacing: 0.5),
                    onChanged: (value) {
                      _searchList.clear();
                      for (var i in _list) {
                        if (i.name
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            i.email
                                .toLowerCase()
                                .contains(value.toLowerCase())) {
                          _searchList.add(i);
                          setState(() {
                            _searchList;
                          });
                        }
                      }
                    },
                  )
                : const Text("Pixel Talk"),
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon:
                      Icon(_isSearching ? Icons.close_rounded : Icons.search)),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(
                                  user: Apis.me,
                                )));
                  },
                  icon: const Icon(Icons.more_vert))
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(right: 5, bottom: 15),
            child: FloatingActionButton(
              onPressed: () {
                _showChatUserDialog();
              },
              backgroundColor: Colors.blue.shade300,
              child: const Icon(Icons.add_comment_rounded),
            ),
          ),
          body: StreamBuilder(
              stream: Apis.getMyUsersId(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(child: CircularProgressIndicator());
                  case ConnectionState.active:
                  case ConnectionState.done:
                    return StreamBuilder(
                        stream: Apis.getAllUsers(
                            snapshot.data?.docs.map((e) => e.id).toList() ??
                                []),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                            case ConnectionState.none:
                              return const Center(
                                  child: CircularProgressIndicator());
                            case ConnectionState.active:
                            case ConnectionState.done:
                              final data = snapshot.data?.docs;
                              _list = data
                                      ?.map((e) => ChatUser.fromJson(e.data()))
                                      .toList() ??
                                  [];
                              if (_list.isNotEmpty) {
                                return ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: _isSearching
                                        ? _searchList.length
                                        : _list.length,
                                    itemBuilder: (context, index) {
                                      //return Text('Name : ${list[index]}');
                                      return ChatUserCard(
                                          user: _isSearching
                                              ? _searchList[index]
                                              : _list[index]);
                                    });
                              } else {
                                return const Center(
                                    child: Text(
                                  'No Connections Found',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                ));
                              }
                          }
                        });
                }
              }),
        ),
      ),
    );
  }

  void _showChatUserDialog() {
    String email = "";
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(
              Icons.person_add_alt_rounded,
              color: Colors.blue,
              size: 26,
            ),
            Text(
              '   Add User',
              style: TextStyle(fontSize: 20),
            )
          ],
        ),
        contentPadding:
            const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
        content: TextFormField(
          initialValue: email,
          maxLines: null,
          onChanged: (value) => email = value,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              hintText: "E-Mail",
              prefixIcon: const Icon(
                Icons.email,
                color: Colors.blue,
              )),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
          MaterialButton(
            onPressed: () async {
              if (email.isNotEmpty) {
                await Apis.addChatUser(email).then((value) {
                  if (!value) {
                    // ignore: use_build_context_synchronously
                    Dialogs.showSnackbar(context, "User does not exist !");
                  }
                });
              }
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
            },
            child: const Text(
              'Add',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}
