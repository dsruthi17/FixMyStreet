import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBi0shl9cHdLbHOvdL5FQE-Dt7MNApLx5s',
    appId: '1:945611318137:web:6b83885d8d62268d9585a8',
    messagingSenderId: '945611318137',
    projectId: 'fixmystreet-c72b7',
    authDomain: 'fixmystreet-c72b7.firebaseapp.com',
    storageBucket: 'fixmystreet-c72b7.firebasestorage.app',
  );

  // Use same config for Android/iOS for now
  // Replace with platform-specific config after running flutterfire configure
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBi0shl9cHdLbHOvdL5FQE-Dt7MNApLx5s',
    appId: '1:945611318137:web:6b83885d8d62268d9585a8',
    messagingSenderId: '945611318137',
    projectId: 'fixmystreet-c72b7',
    storageBucket: 'fixmystreet-c72b7.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBi0shl9cHdLbHOvdL5FQE-Dt7MNApLx5s',
    appId: '1:945611318137:web:6b83885d8d62268d9585a8',
    messagingSenderId: '945611318137',
    projectId: 'fixmystreet-c72b7',
    storageBucket: 'fixmystreet-c72b7.firebasestorage.app',
  );
}
