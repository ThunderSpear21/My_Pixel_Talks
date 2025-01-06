import 'package:flutter/material.dart';

class Dialogs {

  // Helper Fucntion to display  a Snackbar at the bottom with the given content
  static void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.blueAccent,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    ));
  }
  static void showProgressBar(BuildContext context)
  {
    showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()));
  }
}
