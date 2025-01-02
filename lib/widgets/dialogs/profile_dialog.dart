import 'package:flutter/material.dart';
import 'package:my_pixel_talks/main.dart';
import 'package:my_pixel_talks/models/chat_user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_pixel_talks/screens/view_profile_screen.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.chatUser});
  final ChatUser chatUser;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: mq.width * 0.35,
        height: mq.height * 0.3,
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    chatUser.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -1,
                    ),
                    maxLines: 1, // Restrict to one line
                    overflow:
                        TextOverflow.ellipsis, // Add ellipsis if text overflows
                  ),
                ),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ViewProfileScreen(user: chatUser)));
                    },
                    icon: Icon(
                      Icons.info,
                      size: 32,
                      color: Colors.lightBlue.shade300,
                    ))
              ],
            ),
            Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * 0.55),
                      child: CachedNetworkImage(
                        height: mq.height * 0.22,
                        width: mq.height * 0.22,
                        fit: BoxFit.cover,
                        imageUrl: chatUser.image,
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
