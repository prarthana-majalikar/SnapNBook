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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA0OvDWoIeMnJkt_JaIdKvv90fIuGMki_4',
    appId: '1:497301365327:web:394b8f991d222809a2003a',
    messagingSenderId: '497301365327',
    projectId: 'snapnbook-66909',
    authDomain: 'snapnbook-66909.firebaseapp.com',
    databaseURL: 'https://snapnbook-66909-default-rtdb.firebaseio.com',
    storageBucket: 'snapnbook-66909.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_YnDS-1WabcUyKcK6H8WULpmmwiDwvPc',
    appId: '1:497301365327:android:1668744ecdc19421a2003a',
    messagingSenderId: '497301365327',
    projectId: 'snapnbook-66909',
    databaseURL: 'https://snapnbook-66909-default-rtdb.firebaseio.com',
    storageBucket: 'snapnbook-66909.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAKMmACDgyHwOJUkxdL_O0FVR2x7bLUOxY',
    appId: '1:497301365327:ios:bda8fd4e0d57cd21a2003a',
    messagingSenderId: '497301365327',
    projectId: 'snapnbook-66909',
    databaseURL: 'https://snapnbook-66909-default-rtdb.firebaseio.com',
    storageBucket: 'snapnbook-66909.firebasestorage.app',
    iosBundleId: 'com.example.snapnbook',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAKMmACDgyHwOJUkxdL_O0FVR2x7bLUOxY',
    appId: '1:497301365327:ios:bda8fd4e0d57cd21a2003a',
    messagingSenderId: '497301365327',
    projectId: 'snapnbook-66909',
    databaseURL: 'https://snapnbook-66909-default-rtdb.firebaseio.com',
    storageBucket: 'snapnbook-66909.firebasestorage.app',
    iosBundleId: 'com.example.snapnbook',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA0OvDWoIeMnJkt_JaIdKvv90fIuGMki_4',
    appId: '1:497301365327:web:6c7061bf69c8c75aa2003a',
    messagingSenderId: '497301365327',
    projectId: 'snapnbook-66909',
    authDomain: 'snapnbook-66909.firebaseapp.com',
    databaseURL: 'https://snapnbook-66909-default-rtdb.firebaseio.com',
    storageBucket: 'snapnbook-66909.firebasestorage.app',
  );

}