// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAOiJimspOpsunpYt7H9wI4UIVVvBxwXY8',
    appId: '1:771871107063:android:182dd3daa22eff580270f2',
    messagingSenderId: '771871107063',
    projectId: 'my-pixel-talks',
    storageBucket: 'my-pixel-talks.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBFCKzgLOX_nOAgTJJRUd_3mvAtM2fG704',
    appId: '1:771871107063:ios:8e39bca93fc75ef40270f2',
    messagingSenderId: '771871107063',
    projectId: 'my-pixel-talks',
    storageBucket: 'my-pixel-talks.firebasestorage.app',
    androidClientId: '771871107063-n9qnodp28s6a7qpcltaobs1ea6jvhsfe.apps.googleusercontent.com',
    iosClientId: '771871107063-ueqf1hdr346r9bliv6u1d09gngfrut0i.apps.googleusercontent.com',
    iosBundleId: 'com.example.myPixelTalks',
  );

}