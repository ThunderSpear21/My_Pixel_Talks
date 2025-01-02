import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_pixel_talks/api/apis.dart';
import 'package:my_pixel_talks/helper/my_date_util.dart';
import 'package:my_pixel_talks/models/chat_user.dart';
import 'package:my_pixel_talks/models/message.dart';
import 'package:my_pixel_talks/screens/chat_screen.dart';
import 'package:my_pixel_talks/widgets/dialogs/profile_dialog.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      margin: const EdgeInsets.symmetric(vertical: 0.8, horizontal: 0),
      color: Colors.blue.shade100,
      elevation: 0.8,
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(user: widget.user)));
          },
          splashColor: Colors.blue.shade300,
          highlightColor: Colors.blue.shade300,
          child: StreamBuilder(
              stream: Apis.getLastMessage(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list =
                    data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
                if (list.isNotEmpty) {
                  _message = list[0];
                }
                return ListTile(
                    //leading: const CircleAvatar(),
                    leading: InkWell(
                      onTap: (){
                        showDialog(context: context, builder: (_) => ProfileDialog(chatUser: widget.user));
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * 0.055),
                        child: CachedNetworkImage(
                          height: mq.height * 0.055,
                          width: mq.height * 0.055,
                          imageUrl: widget.user.image,
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      widget.user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      (_message != null) ? (_message!.type == Type.text ? _message!.msg : 'Image') : widget.user.about,
                      maxLines: 1,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    //trailing: const Text('21:12'),
                    trailing: _message == null
                        ? null
                        : _message!.read.isEmpty && _message!.fromId!= Apis.user.uid
                            ? Container(
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent.shade400,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              )
                            : Text(
                                MyDateUtil.getLastMessageTime(context: context, time: _message!.sent),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black54),
                              ));
              })),
    );
  }
}
