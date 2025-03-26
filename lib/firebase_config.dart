import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:student_management/firebase_options.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    // Initialize Firebase first with default options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Then connect to emulators if in debug mode
    if (kDebugMode) {
      await _connectToEmulators();
    }
  }

  static Future<void> _connectToEmulators() async {
    // Use 10.0.2.2 for Android emulator to connect to host machine
    // Use localhost for iOS simulator or web
    final String host = defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : 'localhost';
    
    try {
      // Auth emulator
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
      
      // Firestore emulator
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
      
      // Storage emulator
      await FirebaseStorage.instance.useStorageEmulator(host, 9199);
      
      // Configure settings for Firestore
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      
      print('🔥 Connected to Firebase Emulators on $host');
    } catch (e) {
      print('❌ Failed to connect to Firebase Emulators: $e');
      print('Make sure the emulators are running with: firebase emulators:start');
    }
  }
}

