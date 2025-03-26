import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:app/config/env_config.dart';
import 'package:app/firebase_config.dart';
import 'package:app/firebase_options.dart';
 import 'package:app/models/todo_model.dart';
import 'package:app/services/notification_service.dart';
import 'package:app/view_models/teacher_view_model.dart';
import 'package:app/view_models/student_view_model.dart';
import 'package:app/view_models/todo_view_model.dart';
import 'package:app/views/splash_screen.dart';
import 'package:app/utils/theme.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:app/services/test_data_service.dart';
import 'package:flutter/foundation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Print environment configuration in debug mode
  if (kDebugMode) {
    EnvConfig.printConfig();
  }

  // Initialize Firebase with real credentials or use emulators
  if (EnvConfig.hasFirebaseConfig) {
    // Use real Firebase credentials
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    if (kDebugMode) {
      print('🔥 Firebase initialized with real credentials');
    }
  } else {
    // Fall back to emulator setup if no real credentials are available
    await FirebaseConfig.initialize();
    
    // Seed test data in debug mode when using emulators
    if (kDebugMode) {
      await TestDataService().seedTestData();
      print('🧪 Test data seeded in emulator');
    }
  }

  // Initialize timezone
  tz_data.initializeTimeZones();

  // Initialize Hive for local storage
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(TodoPriorityAdapter());
  Hive.registerAdapter(TodoModelAdapter());
  await Hive.openBox<UserModel>('userBox');
  await Hive.openBox<TodoModel>('todoBox');
  await Hive.openBox('settingsBox');

  // Initialize notification service
  await NotificationService().initNotification();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => AdminViewModel()),
        ChangeNotifierProvider(create: (_) => TeacherViewModel()),
        ChangeNotifierProvider(create: (_) => StudentViewModel()),
        ChangeNotifierProvider(create: (_) => TodoViewModel()),
      ],
      child: MaterialApp(
        title: 'Student Management System',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}

