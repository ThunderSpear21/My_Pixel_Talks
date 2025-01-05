import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_pixel_talks/api/notification_access_token.dart';
import 'package:my_pixel_talks/models/chat_user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_pixel_talks/models/message.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:crypto/crypto.dart';

class Apis {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static User get user => auth.currentUser!;
  static late ChatUser me;
  static FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> getFirebaseMessagingToken() async {
    await firebaseMessaging.requestPermission();
    await firebaseMessaging.getToken().then((value) {
      if (value != null) {
        me.pushToken = value;
        log('push token : $value');
      }
    });
  }

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
        await getFirebaseMessagingToken().then((value) {
          Apis.updateActiveStatus(true);
        });
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

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    return firestore
        .collection('users')
        .where('id', whereIn: userIds.isEmpty ? [''] : userIds)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  static Future<void> sendFirstMessage(
      ChatUser touser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(touser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) {
      sendMessage(touser, msg, type);
    });
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
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(
      ChatUser touser, String msg, Type type) async {
    final ref =
        firestore.collection('chats/${getConversationID(touser.id)}/messages/');
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final Message data = Message(
        toId: touser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time);
    await ref.doc(time).set(data.toJson()).then((value) =>
        sendPushNotification(touser, type == Type.text ? msg : 'Image'));
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
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    try {
      // Getting the Cloudinary details from environment variables
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
        log('Uploaded Chat Image Public Id: $responseData');

        // Send the message with the image URL
        await sendMessage(chatUser, imageUrl, Type.image);
      } else {
        log('Cloudinary upload failed with status code: ${response.statusCode}');
        throw Exception('Failed to upload chat image to Cloudinary');
      }
    } catch (e) {
      log('Error in sendChatImage: $e');
      rethrow;
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "message": {
          "token": chatUser.pushToken,
          "notification": {
            "title": me.name, //our name should be send
            "body": msg,
          },
          "android": {
            "notification": {
              "channel_id": "chats", // Your Android channel ID
            }
          }
        }
      };

      // Firebase Project > Project Settings > General Tab > Project ID
      const projectID = 'my-pixel-talks';

      // get firebase admin token
      final bearerToken = await NotificationAccessToken.getToken;

      log('bearerToken: $bearerToken');

      // handle null token
      if (bearerToken == null) return;

      var res = await http.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/$projectID/messages:send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $bearerToken'
        },
        body: jsonEncode(body),
      );

      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }

  static Future<void> deleteMessage(Message message) async {
    try {
      // If the message type is an image, delete it from Cloudinary
      if (message.type == Type.image) {
        // Extract Cloudinary details from environment variables
        final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
        final apiKey = dotenv.env['CLOUDINARY_API_KEY'];
        final apiSecret = dotenv.env['CLOUDINARY_API_SECRET'];

        if (cloudName == null || apiKey == null || apiSecret == null) {
          throw Exception("Cloudinary credentials are not set in .env");
        }

        // Extract the public ID from the URL
        final String url = message.msg;
        final uri = Uri.parse(url);

        // Extract the public ID by removing the directory structure and versioning
        final publicIdWithExtension =
            uri.pathSegments.last; // e.g., "scaled_xxx.jpg"
        final publicId =
            publicIdWithExtension.split('.').first; // Removes ".jpg"

        // Create the Cloudinary delete URL
        final deleteUrl = Uri.parse(
          'https://api.cloudinary.com/v1_1/$cloudName/image/destroy',
        );

        // Construct the API request
        final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final signatureData =
            'public_id=$publicId&timestamp=$timestamp$apiSecret';
        final signature = sha1.convert(utf8.encode(signatureData)).toString();

        final response = await http.post(
          deleteUrl,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
          },
          body: {
            'public_id': publicId,
            'api_key': apiKey,
            'timestamp': timestamp.toString(),
            'signature': signature,
          },
        );

        if (response.statusCode == 200) {
          log('Image deleted successfully from Cloudinary: $publicId');
        } else {
          log('Failed to delete image from Cloudinary: ${response.body}');
          throw Exception('Cloudinary delete error: ${response.body}');
        }
      }

      // Delete the message from Firestore
      await firestore
          .collection('chats/${getConversationID(message.toId)}/messages/')
          .doc(message.sent)
          .delete();
      log('Message deleted successfully from Firestore');
    } catch (e) {
      log('Error deleting message or image: $e');
    }
  }

  static Future<void> updateMessage(
      Message message, String updatedMessage) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMessage});
  }

  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      return false;
    }
  }
}
