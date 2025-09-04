// ignore_for_file: prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'utils/imports.dart';
import 'package:flutter/foundation.dart';
import 'widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase only (remove firedart initialization)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('Firebase SDK initialized for ShopeWise integration');

  // Create necessary files and folders for backward compatibility
  if (!kIsWeb) {
    try {
      createFilesAndFolders();
    } catch (e) {
      debugPrint('Error creating files and folders: $e');
    }
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
    );
  }
}

/// Creates necessary application files and folders in the documents directory
void createFilesAndFolders() async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String path = directory.path;
  final Directory appFolder = Directory('$path/ShopWise');

  // Create app folder if it doesn't exist
  if (!appFolder.existsSync()) {
    await appFolder.create();
  }

  // Create required files if they don't exist
  final List<String> requiredFiles = ['products.csv', 'user.json', 'logs.txt'];

  for (String fileName in requiredFiles) {
    final File file = File('$path/ShopWise/$fileName');
    if (!file.existsSync()) {
      await file.create();
    }
  }
}
