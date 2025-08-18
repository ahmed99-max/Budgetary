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

  static const FirebaseOptions web = FirebaseOptions(
      apiKey: "AIzaSyDkOu-mz4sf3OJzA-441F6QU1yNNvBJEKw",
      authDomain: "expensewise-app-51036.firebaseapp.com",
      projectId: "expensewise-app-51036",
      storageBucket: "expensewise-app-51036.firebasestorage.app",
      messagingSenderId: "877358190612",
      appId: "1:877358190612:web:4e0e5c83fdd2c816249701",
      measurementId: "G-44318Q6QR0");

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyABHOjyG7eP7lydcHRCon6s_dFOVfw53s4',
    appId: '1:877358190612:android:f5399100e865b102249701',
    messagingSenderId: '877358190612',
    projectId: 'expensewise-app-51036',
    storageBucket: 'expensewise-app-51036.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyABHOjyG7eP7lydcHRCon6s_dFOVfw53s4',
    appId: '1:877358190612:ios:f5399100e865b102249701',
    messagingSenderId: '877358190612',
    projectId: 'expensewise-app-51036',
    storageBucket: 'expensewise-app-51036.firebasestorage.app',
    iosBundleId: 'com.example.budgetary',
  );
}
