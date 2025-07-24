// ignore_for_file: prefer_const_constructors

import 'utils/imports.dart';
import 'package:flutter/foundation.dart';
import 'package:firedart/firedart.dart';

const apiKey = "AIzaSyCjZK5ojHcJQh8Sr0sdMG0Nlnga4D94FME";
const projectId = "searchaholic-86248";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firestore only on non-web platforms
  if (!kIsWeb) {
    try {
      Firestore.initialize(projectId);
    } catch (e) {
      debugPrint('Error initializing Firestore: $e');
    }
    
    // Create necessary files and folders
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
      home: Login(),
    );
  }
}

/// Creates necessary application files and folders in the documents directory
void createFilesAndFolders() async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String path = directory.path;
  final Directory appFolder = Directory('$path/SeachAHolic');

  // Create app folder if it doesn't exist
  if (!appFolder.existsSync()) {
    await appFolder.create();
  }

  // Create required files if they don't exist
  final List<String> requiredFiles = [
    'products.csv',
    'user.json', 
    'logs.txt'
  ];
  
  for (String fileName in requiredFiles) {
    final File file = File('$path/SeachAHolic/$fileName');
    if (!file.existsSync()) {
      await file.create();
    }
  }
}
