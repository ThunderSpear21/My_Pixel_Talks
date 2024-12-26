import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_pixel_talks/api/apis.dart';
import 'package:my_pixel_talks/screens/auth/login_screen.dart';
import 'package:my_pixel_talks/screens/home_screen.dart';
import '../../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
      if (Apis.auth.currentUser != null) {
        Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      // appBar: AppBar(
      //   backgroundColor: Colors.lightBlue,
      //   title: const Text("Welcome to Pixel Talk"),
      // ),
      body: Stack(
        children: [
          Positioned(
            top: mq.height * 0.20,
            left: mq.width * 0.25,
            width: mq.width * 0.5,
            child: Image.asset('images/icon.png'),
          ),
          Positioned(
            bottom: mq.height * 0.15,
            width: mq.width * 0.84,
            left: mq.width * 0.08,
            //height: mq.height,
            child: const Text(
              "MADE IN FLUTTER AND DART 💖",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
