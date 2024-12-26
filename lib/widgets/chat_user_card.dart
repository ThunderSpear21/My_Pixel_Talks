import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_pixel_talks/models/chat_user.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
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
        onTap: () {},
        splashColor: Colors.blue.shade300,
        highlightColor: Colors.blue.shade300,
        child: ListTile(
          //leading: const CircleAvatar(),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(mq.height*0.055),
            child: CachedNetworkImage(
              height: mq.height*0.055,
              width: mq.height*0.055,
              
              imageUrl: widget.user.image,
              errorWidget: (context, url, error) => const CircleAvatar(
                child: Icon(Icons.person),
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
            widget.user.about,
            maxLines: 1,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          //trailing: const Text('21:12'),
          trailing: Container( height: 10, width: 10, decoration: BoxDecoration(
            color: Colors.greenAccent.shade400,
            borderRadius: BorderRadius.circular(10),
          ),),
        ),
      ),
    );
  }
}