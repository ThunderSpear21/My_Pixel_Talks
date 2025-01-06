import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_pixel_talks/api/apis.dart';
import 'package:my_pixel_talks/helper/dialogs.dart';
import 'package:my_pixel_talks/helper/my_date_util.dart';
import 'package:my_pixel_talks/main.dart';
import 'package:my_pixel_talks/models/message.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_pixel_talks/screens/full_screen_image_view.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';

// Design a Message Card for a message to be displayed with the given contents in the ChatScreen
class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});
  final Message message;
  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = widget.message.fromId == Apis.user.uid;
    return InkWell(
      onLongPress: () {
        _showBottomScreen(isMe);
      },
      // If Sender is Current User, show Green Message Card, else Blue Message Card
      child: isMe ? _greenMessage() : _blueMessage(),
    );
  }

  Widget _blueMessage() {
    // While building a Recieved Message, if Read Time is empty, update Read Time
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
                        builder: (_) =>
                            FullScreenImageView(imageUrl: widget.message.msg),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * 0.005),
                      child: CachedNetworkImage(
                        imageUrl: widget.message.msg,
                        placeholder: (context, url) => const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
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
                        builder: (_) =>
                            FullScreenImageView(imageUrl: widget.message.msg),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * 0.005),
                      child: CachedNetworkImage(
                        imageUrl: widget.message.msg,
                        placeholder: (context, url) => const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
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

  // Bottom Screen to display more actions associated with a given message, ie, Save, Edit, Delete, Sent Time, Read Time
  void _showBottomScreen(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        builder: (ctx) {
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * 0.01, horizontal: mq.width * 0.4),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),
              widget.message.type == Type.text
                  ? _OptionItem(
                      icon: const Icon(
                        Icons.copy_outlined,
                        color: Colors.blue,
                      ),
                      name: 'Copy Text',
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          if (ctx.mounted) {
                            // ignore: use_build_context_synchronously
                            Navigator.of(ctx).pop();
                            Dialogs.showSnackbar(
                                // ignore: use_build_context_synchronously
                                ctx,
                                'Text Copied to Device Clipboard');
                          }
                        });
                      },
                    )
                  : _OptionItem(
                      icon: const Icon(
                        Icons.file_download,
                        color: Colors.blue,
                      ),
                      name: 'Save Image',
                      onTap: () async {
                        try {
                          await GallerySaver.saveImage(widget.message.msg,
                                  albumName: "Pixel Talks")
                              .then((success) {
                            if (ctx.mounted) {
                              // ignore: use_build_context_synchronously
                              Navigator.of(ctx).pop();
                              if (success != null && success) {
                                Dialogs.showSnackbar(
                                    // ignore: use_build_context_synchronously
                                    ctx,
                                    'Image saved to Device');
                              }
                            }
                          });
                        } catch (e) {
                          log(e.toString());
                        }
                      },
                    ),
              Divider(
                color: Colors.black45,
                endIndent: mq.width * 0.04,
                indent: mq.width * 0.04,
              ),
              if (widget.message.type == Type.text && isMe)
                _OptionItem(
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.amber,
                  ),
                  name: 'Edit Message',
                  onTap: () {
                    if (ctx.mounted) {
                      // ignore: use_build_context_synchronously
                      Navigator.of(ctx).pop();
                    }
                    _showMessageUpdateDialog();
                  },
                ),
              if (isMe)
                _OptionItem(
                  icon: const Icon(
                    Icons.delete_rounded,
                    color: Colors.red,
                  ),
                  name: 'Delete Message',
                  onTap: () async {
                    await Apis.deleteMessage(widget.message).then((value) {
                      // ignore: use_build_context_synchronously
                      Navigator.of(ctx).pop();
                    });
                  },
                ),
              if (isMe)
                Divider(
                  color: Colors.black45,
                  endIndent: mq.width * 0.04,
                  indent: mq.width * 0.04,
                ),
              _OptionItem(
                icon: const Icon(
                  Icons.remove_red_eye,
                  color: Colors.blue,
                ),
                name:
                    'Sent At:  ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
                onTap: () {},
              ),
              _OptionItem(
                icon: const Icon(
                  Icons.remove_red_eye,
                  color: Colors.green,
                ),
                name: (widget.message.read != "")
                    ? 'Read At:  ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}'
                    : 'Read At: Not Seen Yet',
                onTap: () {},
              ),
            ],
          );
        });
  }

  // Show Update Message Dialog which updates given message with the contents of the provided Text Field
  void _showMessageUpdateDialog() {
    String updatedMessage = widget.message.msg;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(
              Icons.message,
              color: Colors.blue,
              size: 24,
            ),
            Text(
              '   Update Message',
              style: TextStyle(fontSize: 20),
            )
          ],
        ),
        contentPadding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
        content: TextFormField(
          initialValue: updatedMessage,
          maxLines: null,
          onChanged: (value) => updatedMessage = value,
          decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
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
            onPressed: () {
              Navigator.of(context).pop();
              Apis.updateMessage(widget.message, updatedMessage);
            },
            child: const Text(
              'Update',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}

// Helper Class to handle the display of the Actions in the Bottom Sheet
class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
            left: mq.width * 0.07,
            top: mq.height * 0.015,
            bottom: mq.height * 0.02),
        child: Row(
          children: [
            icon,
            Text(
              '     $name',
              style: const TextStyle(
                  letterSpacing: 0.5, fontSize: 16, color: Colors.black54),
            )
          ],
        ),
      ),
    );
  }
}
