import 'package:flutter/foundation.dart';

/// Environment configuration class to manage environment variables
class EnvConfig {
  // Firebase configuration
  static const String firebaseApiKey = String.fromEnvironment('NEXT_PUBLIC_FIREBASE_API_KEY');
  static const String firebaseAuthDomain = String.fromEnvironment('NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN');
  static const String firebaseProjectId = String.fromEnvironment('NEXT_PUBLIC_FIREBASE_PROJECT_ID');
  static const String firebaseStorageBucket = String.fromEnvironment('NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET');
  static const String firebaseMessagingSenderId = String.fromEnvironment('NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID');
  static const String firebaseAppId = String.fromEnvironment('NEXT_PUBLIC_FIREBASE_APP_ID');

  /// Check if all required Firebase environment variables are set
  static bool get hasFirebaseConfig {
    return firebaseApiKey.isNotEmpty &&
        firebaseProjectId.isNotEmpty &&
        firebaseAppId.isNotEmpty;
  }

  /// Print environment configuration for debugging
  static void printConfig() {
    if (kDebugMode) {
      print('🔧 Environment Configuration:');
      print('Firebase API Key: ${_maskString(firebaseApiKey)}');
      print('Firebase Project ID: $firebaseProjectId');
      print('Firebase App ID: ${_maskString(firebaseAppId)}');
      print('All Firebase config available: ${hasFirebaseConfig ? '✅' : '❌'}');
    }
  }

  /// Mask sensitive strings for logging
  static String _maskString(String value) {
    if (value.isEmpty) return '[EMPTY]';
    if (value.length <= 8) return '****';
    return '${value.substring(0, 4)}****${value.substring(value.length - 4)}';
  }
}

