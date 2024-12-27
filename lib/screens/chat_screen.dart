import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_pixel_talks/main.dart';
import 'package:my_pixel_talks/models/chat_user.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(statusBarColor: Colors.white));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 2,
          automaticallyImplyLeading: false,
          flexibleSpace: _appBar(),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: null,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const Center(child: CircularProgressIndicator());
                    case ConnectionState.active:
                    case ConnectionState.done:
                      // final data = snapshot.data?.docs;
                      // _list = data
                      //         ?.map((e) => ChatUser.fromJson(e.data()))
                      //         .toList() ??
                      //     [];
                      final _list = [];
                      if (_list.isNotEmpty) {
                        return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount:
                                 _list.length,
                            itemBuilder: (context, index) {
                              return Text('Message');
                            });
                      } else {
                        return const Center(
                            child: Text(
                          'Say Hii !! 👋',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ));
                      }
                  }
                }),
            ),
            _chatInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.only(top: 1.0),
        child: Row(
          children: [
            const SizedBox(
              width: 2,
            ),
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.black,
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(mq.height * 0.055),
              child: CachedNetworkImage(
                height: mq.height * 0.05,
                width: mq.height * 0.05,
                imageUrl: widget.user.image,
                errorWidget: (context, url, error) => const CircleAvatar(
                  child: Icon(Icons.person),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.name,
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 2,
                ),
                const Text(
                  'Last Seen Not Found',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w300),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _chatInputBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: mq.width * 0.02, vertical:  mq.height* 0.01),
      child: Row(
        children: [
          const SizedBox(width: 8,),
          Expanded(
            child: Card(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.emoji_emotions,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const Expanded(
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: 6,
                        minLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Type Something ...',
                      hintStyle:
                          TextStyle(color: Colors.blueAccent, fontSize: 16),
                      border: InputBorder.none,
                    ),
                  )),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.image_rounded,
                      color: Colors.blueAccent,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          MaterialButton(
              onPressed: () {},
              minWidth: 0,
              shape: const CircleBorder(),
              padding: const EdgeInsets.only(top: 8, left: 8, bottom: 8, right: 4),
              color: Colors.blueAccent,
              child: Icon(
                Icons.send,
                color: Colors.white,
                size: mq.width * 0.075,
              ))
        ],
      ),
    );
  }
}
