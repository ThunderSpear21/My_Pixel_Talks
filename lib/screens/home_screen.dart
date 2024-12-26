import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_pixel_talks/api/apis.dart';
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
              onPressed: () {},
              backgroundColor: Colors.blue.shade300,
              child: const Icon(Icons.add_comment_rounded),
            ),
          ),
          body: StreamBuilder(
              stream: Apis.getAllUsers(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return const Center(child: CircularProgressIndicator());
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
                          itemCount:
                              _isSearching ? _searchList.length : _list.length,
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
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ));
                    }
                }
              }),
        ),
      ),
    );
  }
}
