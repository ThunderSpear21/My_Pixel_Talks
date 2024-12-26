import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_pixel_talks/api/apis.dart';
import 'package:my_pixel_talks/helper/dialogs.dart';
import 'package:my_pixel_talks/models/chat_user.dart';
import 'package:my_pixel_talks/main.dart';
import 'package:my_pixel_talks/screens/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("Pixel Talk"),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            Dialogs.showProgressBar(context);
            await Apis.auth.signOut().then((value) async {
              await GoogleSignIn().signOut().then((value) {
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              });
            });
          },
          icon: const Icon(
            Icons.logout,
            color: Colors.white,
          ),
          label: const Text(
            'Log Out',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
            child: Column(
              children: [
                SizedBox(
                  height: mq.height * 0.03,
                  width: mq.width,
                ),
                Stack(children: [
                  (_image !=null) ? ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * 0.55),
                    child: Image.file(
                      File(_image!),
                      height: mq.height * 0.22,
                      width: mq.height * 0.22,
                      fit: BoxFit.cover,
                    ),
                  ): ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * 0.55),
                    child: CachedNetworkImage(
                      height: mq.height * 0.22,
                      width: mq.height * 0.22,
                      fit: BoxFit.cover,
                      imageUrl: widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: -10,
                    child: MaterialButton(
                      onPressed: () {
                        _showBottomScreen();
                      },
                      elevation: 2,
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ]),
                SizedBox(
                  height: mq.height * 0.03,
                  width: mq.width,
                ),
                Text(
                  widget.user.email,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  height: mq.height * 0.05,
                  width: mq.width,
                ),
                TextFormField(
                  onSaved: (val) => Apis.me.name = val ?? '',
                  validator: (val) => (val != null && val.isNotEmpty)
                      ? null
                      : 'Cannot be empty',
                  initialValue: widget.user.name,
                  autocorrect: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.blue.shade700,
                    ),
                    hintText: 'eg. ThunderSpear',
                    label: const Text('Username'),
                  ),
                ),
                SizedBox(
                  height: mq.height * 0.03,
                  width: mq.width,
                ),
                TextFormField(
                  onSaved: (val) => Apis.me.about = val ?? '',
                  validator: (val) => (val != null && val.isNotEmpty)
                      ? null
                      : 'Cannot be empty',
                  initialValue: widget.user.about,
                  autocorrect: false,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    prefixIcon: Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                    ),
                    hintText: 'eg. I\'m feeling lucky',
                    label: const Text('About'),
                  ),
                ),
                SizedBox(
                  height: mq.height * 0.05,
                  width: mq.width,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      Apis.updateUserInfo().then((value) {
                        Dialogs.showSnackbar(
                            // ignore: use_build_context_synchronously
                            context,
                            'Profile Updated Successfully !');
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(mq.width * 0.4, mq.height * 0.055)),
                  label: const Text(
                    'Update',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 26,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomScreen() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        builder: (_) {
          return Padding(
            padding: EdgeInsets.only(
                top: mq.height * 0.03, bottom: mq.height * 0.03),
            child: ListView(
              shrinkWrap: true,
              children: [
                const Text(
                  'Pick Profile Picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: mq.height * 0.02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //SizedBox(width: mq.width*0.03,),
                    ElevatedButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                        if(image!=null)
                        {
                          setState(() {
                            _image = image.path;
                          });
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(mq.width * 0.35, mq.width * 0.35),
                        shape: const CircleBorder(),
                        elevation: 4,
                      ),
                      child: Image.asset('images/gallery.png'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(source: ImageSource.camera);
                        if(image!=null)
                        {
                          setState(() {
                            _image = image.path;
                          });
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(mq.width * 0.35, mq.width * 0.35),
                        shape: const CircleBorder(),
                        elevation: 4,
                      ),
                      child: Image.asset('images/camera.png'),
                    )
                  ],
                )
              ],
            ),
          );
        });
  }
}
