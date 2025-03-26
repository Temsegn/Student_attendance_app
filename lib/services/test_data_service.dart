import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class TestDataService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates test users and data for development
  Future<void> seedTestData() async {
    if (!kDebugMode) {
      print('Test data seeding is only available in debug mode');
      return;
    }

    try {
      // Create test users
      await _createTestUsers();
      
      // Create test data
      await _createTestClasses();
      
      print('✅ Test data seeded successfully');
    } catch (e) {
      print('❌ Error seeding test data: $e');
    }
  }

  Future<void> _createTestUsers() async {
    // Admin user
    await _createUserWithRole(
      email: 'admin@example.com',
      password: 'password123',
      role: 'admin',
      name: 'Admin User',
    );

    // Teacher user
    final teacherId = await _createUserWithRole(
      email: 'teacher@example.com',
      password: 'password123',
      role: 'teacher',
      name: 'Teacher User',
      additionalData: {
        'subject': 'Mathematics',
        'phone': '555-1234',
      },
    );

    // Student user
    await _createUserWithRole(
      email: 'student@example.com',
      password: 'password123',
      role: 'student',
      name: 'Student User',
      additionalData: {
        'studentId': 'STU001',
        'className': 'Class 10A',
      },
    );
  }

  Future<String> _createUserWithRole({
    required String email,
    required String password,
    required String role,
    required String name,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Create user in Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final uid = userCredential.user!.uid;
      
      // Add user data to Firestore
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'name': name,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        ...?additionalData,
      });
      
      print('Created test user: $email with role: $role');
      return uid;
    } catch (e) {
      // If user already exists, just return
      print('User may already exist: $e');
      
      // Try to get the user ID
      try {
        final existingUser = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return existingUser.user!.uid;
      } catch (signInError) {
        print('Could not sign in as existing user: $signInError');
        rethrow;
      }
    }
  }

  Future<void> _createTestClasses() async {
    // Get teacher ID
    String teacherId = '';
    try {
      final teacherQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: 'teacher@example.com')
          .get();
      
      if (teacherQuery.docs.isNotEmpty) {
        teacherId = teacherQuery.docs.first.id;
      }
    } catch (e) {
      print('Error getting teacher ID: $e');
      return;
    }

    if (teacherId.isEmpty) {
      print('Teacher not found, skipping class creation');
      return;
    }

    // Create a test class
    await _firestore.collection('classes').add({
      'name': 'Mathematics 101',
      'subject': 'Mathematics',
      'teacherId': teacherId,
      'teacherName': 'Teacher User',
      'schedule': 'Mon, Wed, Fri 10:00 AM',
      'description': 'Introduction to Mathematics',
      'enrolledStudents': [],
      'createdAt': FieldValue.serverTimestamp(),
    });

    print('Created test class for teacher');
  }
}

