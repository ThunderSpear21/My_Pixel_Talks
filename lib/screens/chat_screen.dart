import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_pixel_talks/api/apis.dart';
import 'package:my_pixel_talks/helper/my_date_util.dart';
import 'package:my_pixel_talks/main.dart';
import 'package:my_pixel_talks/models/chat_user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_pixel_talks/models/message.dart';
import 'package:my_pixel_talks/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];
  final TextEditingController _textController = TextEditingController();
  bool _showEmoji = false;
  bool _isUploading = false;
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: PopScope(
          canPop: !_showEmoji,
          onPopInvokedWithResult: (didPop, result) {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
            }
          },
          child: Scaffold(
            appBar: AppBar(
              elevation: 2,
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            backgroundColor: Colors.lightBlue.shade100,
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                      stream: Apis.getAllMessages(widget.user),
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
                                    ?.map((e) => Message.fromJson(e.data()))
                                    .toList() ??
                                [];
                            if (_list.isNotEmpty) {
                              return ListView.builder(
                                  reverse: true,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: _list.length,
                                  itemBuilder: (context, index) {
                                    return MessageCard(message: _list[index]);
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
                if (_isUploading)
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                _chatInputBar(),
                if (_showEmoji)
                  EmojiPicker(
                    textEditingController: _textController,
                    config: Config(
                        height: mq.height * 0.35,
                        emojiViewConfig: EmojiViewConfig(
                          backgroundColor: Colors.lightBlue.shade100,
                          emojiSizeMax: 28 * (Platform.isIOS ? 1.20 : 1.0),
                        ),
                        bottomActionBarConfig: const BottomActionBarConfig(
                          showSearchViewButton: false,
                        )),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.only(top: 1.0),
        child: StreamBuilder(
            stream: Apis.getUserInfo(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

              return Row(
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
                      imageUrl:
                          list.isNotEmpty ? list[0].image : widget.user.image,
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
                        list.isNotEmpty ? list[0].name : widget.user.name,
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        list.isNotEmpty
                            ? (list[0].isOnline == true
                                ? 'Online'
                                : MyDateUtil.getLastActiveTime(
                                    context: context,
                                    lastActive: list[0].lastActive))
                            : MyDateUtil.getLastActiveTime(
                                context: context,
                                lastActive: widget.user.lastActive),
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.w300),
                      )
                    ],
                  )
                ],
              );
            }),
      ),
    );
  }

  Widget _chatInputBar() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: mq.width * 0.02, vertical: mq.height * 0.01),
      child: Row(
        children: [
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        FocusScope.of(context).unfocus();
                        _showEmoji = !_showEmoji;
                      });
                    },
                    icon: const Icon(
                      Icons.emoji_emotions,
                      color: Colors.blueAccent,
                    ),
                  ),
                  Expanded(
                      child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 6,
                    minLines: 1,
                    onTap: () {
                      if (_showEmoji) {
                        setState(() {
                          _showEmoji = !_showEmoji;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      hintText: 'Type Something ...',
                      hintStyle:
                          TextStyle(color: Colors.blueAccent, fontSize: 16),
                      border: InputBorder.none,
                    ),
                  )),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final List<XFile> images =
                          await picker.pickMultiImage(imageQuality: 70);
                      if (images.isNotEmpty) {
                        for (var image in images) {
                          setState(() {
                            _isUploading = true;
                          });
                          await Apis.sendChatImage(
                              widget.user, File(image.path));
                        }
                        setState(() {
                          _isUploading = false;
                        });
                      }
                    },
                    icon: const Icon(
                      Icons.image_rounded,
                      color: Colors.blueAccent,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 70);
                      if (image != null) {
                        setState(() {
                          _isUploading = true;
                        });
                        await Apis.sendChatImage(widget.user, File(image.path));
                        setState(() {
                          _isUploading = false;
                        });
                      }
                    },
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
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  Apis.sendMessage(
                      widget.user, _textController.text, Type.text);
                  _textController.clear();
                }
              },
              minWidth: 0,
              shape: const CircleBorder(),
              padding:
                  const EdgeInsets.only(top: 8, left: 8, bottom: 8, right: 4),
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
