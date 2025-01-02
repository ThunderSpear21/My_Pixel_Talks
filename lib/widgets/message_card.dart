import 'package:flutter/material.dart';
import 'package:my_pixel_talks/api/apis.dart';
import 'package:my_pixel_talks/helper/my_date_util.dart';
import 'package:my_pixel_talks/main.dart';
import 'package:my_pixel_talks/models/message.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_pixel_talks/screens/full_screen_image_view.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});
  final Message message;
  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return widget.message.fromId == Apis.user.uid
        ? _greenMessage()
        : _blueMessage();
  }

  Widget _blueMessage() {
    if (widget.message.read.isEmpty) {
      Apis.updateReadTime(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * 0.02
                : mq.width * 0.04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
            decoration: BoxDecoration(
                color: Colors.blue.shade200,
                border: Border.all(color: Colors.blue),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                  )
                : GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenImageView(imageUrl: widget.message.msg),
                    ),
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * 0.005),
                      child: CachedNetworkImage(
                        imageUrl: widget.message.msg,
                        placeholder: (context, url) =>
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                            ),
                        errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(
                            Icons.image,
                            size: 70,
                          ),
                        ),
                      ),
                    ),
                ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * 0.02),
          child: Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 10, color: Colors.black54)),
        ),
      ],
    );
  }

  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(width: mq.width * 0.04),
            if (widget.message.read.isNotEmpty)
              const Icon(
                Icons.done_all_sharp,
                color: Colors.blue,
                size: 18,
              ),
            const SizedBox(width: 2),
            Text(
                MyDateUtil.getFormattedTime(
                    context: context, time: widget.message.sent),
                style: const TextStyle(fontSize: 10, color: Colors.black54)),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * 0.02
                : mq.width * 0.04),
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * 0.04, vertical: mq.height * 0.01),
            decoration: BoxDecoration(
              color: Colors.green.shade200,
              border: Border.all(color: Colors.green),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20)),
            ),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                  )
                : GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenImageView(imageUrl: widget.message.msg),
                    ),
                  ),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * 0.005),
                      child: CachedNetworkImage(
                        imageUrl: widget.message.msg,
                        placeholder: (context, url) =>
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                            ),
                        errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(
                            Icons.image,
                            size: 70,
                          ),
                        ),
                      ),
                    ),
                ),
          ),
        ),
      ],
    );
  }
}
