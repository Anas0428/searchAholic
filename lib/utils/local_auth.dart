import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class LocalAuth {
  static Future<bool> checkLocalLogin(String email, String password) async {
    try {
      debugPrint('Checking local login for: $email');
      
      // Read the data.json file
      final file = File('D:\\temp\\lib\\utils\\data.json');
      if (!await file.exists()) {
        debugPrint('data.json file not found');
        return false;
      }
      
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString);
      
      // Check if users section exists
      if (!jsonData.containsKey('users')) {
        debugPrint('No users section found in data.json');
        return false;
      }
      
      final users = jsonData['users'] as Map<String, dynamic>;
      
      // Check if user exists
      if (!users.containsKey(email)) {
        debugPrint('User $email not found in local data');
        return false;
      }
      
      final userData = users[email] as Map<String, dynamic>;
      final storedPassword = userData['password'] as String;
      
      debugPrint('Local auth - Email match: ${userData['email'] == email}');
      debugPrint('Local auth - Password match: ${storedPassword == password}');
      
      // Verify credentials
      if (userData['email'] == email && storedPassword == password) {
        debugPrint('Local authentication successful');
        return true;
      } else {
        debugPrint('Local authentication failed - credentials mismatch');
        return false;
      }
      
    } catch (e) {
      debugPrint('Local authentication error: $e');
      return false;
    }
  }
  
  static Future<Map<String, String>?> getUserData(String email) async {
    try {
      final file = File('D:\\temp\\lib\\utils\\data.json');
      if (!await file.exists()) {
        return null;
      }
      
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString);
      
      if (!jsonData.containsKey('users')) {
        return null;
      }
      
      final users = jsonData['users'] as Map<String, dynamic>;
      
      if (!users.containsKey(email)) {
        return null;
      }
      
      final userData = users[email] as Map<String, dynamic>;
      return {
        'name': userData['name'] as String? ?? 'Admin User',
        'email': userData['email'] as String? ?? email,
        'phone': userData['phone'] as String? ?? '123456789',
        'address': userData['address'] as String? ?? '123 Admin St, Admin City',
        'storeName': userData['storeName'] as String? ?? 'Admin Store',
      };
      
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }
}
