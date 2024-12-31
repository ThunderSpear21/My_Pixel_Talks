import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_pixel_talks/models/chat_user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_pixel_talks/models/message.dart';

class Apis {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static User get user => auth.currentUser!;
  static late ChatUser me;
  static Future<bool> userExists(UserCredential user) async {
    return (await firestore
            .collection('users')
            .doc(auth.currentUser!.uid)
            .get())
        .exists;
  }

  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
      } else {
        await createUser().then((value) {
          getSelfInfo();
        });
      }
    });
  }

  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatuser = ChatUser(
      id: user.uid,
      email: user.email.toString(),
      name: user.displayName.toString(),
      about: 'Hey I\'m using Pixel Chat',
      image: user.photoURL.toString(),
      createdAt: time,
      lastActive: time,
      isOnline: false,
      pushToken: '',
    );
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatuser.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update(
      {'name': me.name, 'about': me.about},
    );
  }

  static Future<void> updateProfilePicture(File file) async {
    try {
      // Getting the upload preset and Cloudinary details from environment variables
      final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
      final uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

      // Construct the Cloudinary upload URL
      final uploadUrl =
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

      // Create a multipart request
      final request = http.MultipartRequest('POST', uploadUrl);

      // Add the file and upload preset to the request
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      request.fields['upload_preset'] = uploadPreset!;

      // Send the request to Cloudinary
      final response = await request.send();

      if (response.statusCode == 200) {
        // Parse the response
        final responseBody = await response.stream.bytesToString();
        final responseData = jsonDecode(responseBody);

        // Get the secure URL of the uploaded image
        final imageUrl = responseData['secure_url'];
        log('Uploaded Image URL: $imageUrl');

        // Update the user's profile picture URL
        me.image = imageUrl;
        await firestore
            .collection('users')
            .doc(user.uid)
            .update({'image': me.image});
      } else {
        log('Cloudinary upload failed with status code: ${response.statusCode}');
        throw Exception('Failed to upload image to Cloudinary');
      }
    } catch (e) {
      log('Error in updateProfilePicture: $e');
      rethrow;
    }
  }

  static String getConversationID(String id) {
    return (user.uid.hashCode <= id.hashCode)
        ? '${user.uid}_$id'
        : '${id}_${user.uid}';
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .snapshots();
  }

  static Future<void> sendMessage(ChatUser touser, String msg) async {
    final ref =
        firestore.collection('chats/${getConversationID(touser.id)}/messages/');
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final Message data = Message(
        toId: touser.id,
        msg: msg,
        read: '',
        type: Type.text,
        fromId: user.uid,
        sent: time);
    await ref.doc(time).set(data.toJson());
  }

  static Future<void> updateReadTime(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/').orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }
}
