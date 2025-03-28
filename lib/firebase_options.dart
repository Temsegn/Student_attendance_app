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
    apiKey: String.fromEnvironment('NEXT_PUBLIC_FIREBASE_API_KEY'),
    appId: String.fromEnvironment('NEXT_PUBLIC_FIREBASE_APP_ID'),
    messagingSenderId: String.fromEnvironment('NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('NEXT_PUBLIC_FIREBASE_PROJECT_ID'),
    authDomain: String.fromEnvironment('NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN'),
    storageBucket: String.fromEnvironment('NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET'),
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: String.fromEnvironment('NEXT_PUBLIC_FIREBASE_API_KEY'),
    appId: String.fromEnvironment('NEXT_PUBLIC_FIREBASE_APP_ID'),
    messagingSenderId: String.fromEnvironment('NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('NEXT_PUBLIC_FIREBASE_PROJECT_ID'),
    storageBucket: String.fromEnvironment('NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET'),
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: String.fromEnvironment('NEXT_PUBLIC_FIREBASE_API_KEY'),
    appId: String.fromEnvironment('NEXT_PUBLIC_FIREBASE_APP_ID'),
    messagingSenderId: String.fromEnvironment('NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('NEXT_PUBLIC_FIREBASE_PROJECT_ID'),
    storageBucket: String.fromEnvironment('NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET'),
    iosBundleId: 'com.example.studentManagement',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: String.fromEnvironment('NEXT_PUBLIC_FIREBASE_API_KEY'),
    appId: String.fromEnvironment('NEXT_PUBLIC_FIREBASE_APP_ID'),
    messagingSenderId: String.fromEnvironment('NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID'),
    projectId: String.fromEnvironment('NEXT_PUBLIC_FIREBASE_PROJECT_ID'),
    storageBucket: String.fromEnvironment('NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET'),
    iosBundleId: 'com.example.studentManagement',
  );
}

