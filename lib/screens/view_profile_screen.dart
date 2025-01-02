import 'package:flutter/material.dart';
import 'package:my_pixel_talks/helper/my_date_util.dart';
import 'package:my_pixel_talks/models/chat_user.dart';
import 'package:my_pixel_talks/main.dart';
import 'package:my_pixel_talks/widgets/profile_image.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.user.name),
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Joined On : ',
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
              Text(
                MyDateUtil.getLastMessageTime(
                    context: context,
                    time: widget.user.createdAt,
                    showYear: true),
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              )
            ],
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: mq.height * 0.03,
                    width: mq.width,
                  ),
                  ProfileImage(
                    size: mq.height * .25,
                    url: widget.user.image,
                  ),
                  SizedBox(
                    height: mq.height * 0.02,
                    width: mq.width,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.user.email,
                        style: const TextStyle(
                            fontSize: 15, color: Colors.black54),
                      )
                    ],
                  ),
                  SizedBox(
                    height: mq.height * 0.03,
                    width: mq.width,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'About : ',
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        widget.user.about,
                        style: const TextStyle(
                            fontSize: 15, color: Colors.black54),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
