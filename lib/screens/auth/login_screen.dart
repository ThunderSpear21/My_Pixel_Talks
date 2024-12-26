import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_pixel_talks/api/apis.dart';
import 'package:my_pixel_talks/helper/dialogs.dart';
import 'package:my_pixel_talks/main.dart';
import 'package:my_pixel_talks/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  googleloginbutton() {
    Dialogs.showProgressBar(context);
    signInWithGoogle().then((user) async {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      if (user != null) {
        if (await (Apis.userExists(user))) {
          Navigator.pushReplacement(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()));
        } else {
          await Apis.createUser().then((value) {
            Navigator.pushReplacement(
                // ignore: use_build_context_synchronously
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    // Trigger the authentication flow
    try {
      await InternetAddress.lookup('google.com');
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await Apis.auth.signInWithCredential(credential);
    } catch (e) {
      // ignore: use_build_context_synchronously
      Dialogs.showSnackbar(context, 'Check Internet Connection');
      //log(e.toString());
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text("Welcome to Pixel Talk"),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            top: mq.height * 0.20,
            left: mq.width * 0.25,
            width: mq.width * 0.5,
            duration: const Duration(milliseconds: 800),
            child: Image.asset('images/icon.png'),
          ),
          AnimatedPositioned(
            bottom: mq.height * 0.15,
            left: mq.width * 0.08,
            width: mq.width * 0.84,
            height: mq.height * 0.07,
            duration: const Duration(milliseconds: 800),
            child: ElevatedButton.icon(
              onPressed: () {
                googleloginbutton();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                elevation: 2,
              ),
              label: const Text(
                "Sign in with Google",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: Image.asset(
                'images/google.png',
                height: 24, // Ensure the icon fits well
                width: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
