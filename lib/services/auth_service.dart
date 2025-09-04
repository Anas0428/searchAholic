import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/imports.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Auth state stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  static Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        // Create user profile in Firestore
        await _createUserProfile(user, fullName);
        
        // Update local user file for compatibility
        await _updateLocalUserFile(email, password);
      }

      return result;
    } catch (e) {
      debugPrint('Sign up error: $e');
      return null;
    }
  }

  // Sign in with email and password
  static Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update local user file for compatibility
      await _updateLocalUserFile(email, password);

      return result;
    } catch (e) {
      debugPrint('Sign in error: $e');
      return null;
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      // Clear local user file
      await _clearLocalUserFile();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  // Reset password
  static Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      debugPrint('Password reset error: $e');
      return false;
    }
  }

  // Update user profile
  static Future<bool> updateUserProfile({
    String? fullName,
    String? email,
  }) async {
    try {
      User? user = currentUser;
      if (user == null) return false;

      Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (fullName != null) {
        updateData['fullName'] = fullName;
        await user.updateDisplayName(fullName);
      }

      if (email != null) {
        updateData['email'] = email;
        await user.verifyBeforeUpdateEmail(email);
      }

      await _firestore.collection('users').doc(user.uid).update(updateData);
      return true;
    } catch (e) {
      debugPrint('Update profile error: $e');
      return false;
    }
  }

  // Delete user account
  static Future<bool> deleteAccount() async {
    try {
      User? user = currentUser;
      if (user == null) return false;

      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();
      
      // Delete products collection
      await _deleteUserProducts(user.uid);

      // Delete user account
      await user.delete();
      
      // Clear local user file
      await _clearLocalUserFile();

      return true;
    } catch (e) {
      debugPrint('Delete account error: $e');
      return false;
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      User? user = currentUser;
      if (user == null) return null;

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('Get user profile error: $e');
      return null;
    }
  }

  // Private helper methods

  static Future<void> _createUserProfile(User user, String fullName) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'fullName': fullName,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Create user profile error: $e');
    }
  }

  static Future<void> _updateLocalUserFile(String email, String password) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/ShopWise/user.json');
      
      final userData = {
        'email': email,
        'password': password,
        'lastLogin': DateTime.now().toIso8601String(),
      };

      await file.writeAsString(jsonEncode(userData));
    } catch (e) {
      debugPrint('Update local user file error: $e');
    }
  }

  static Future<void> _clearLocalUserFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/ShopWise/user.json');
      
      if (file.existsSync()) {
        await file.writeAsString('{}');
      }
    } catch (e) {
      debugPrint('Clear local user file error: $e');
    }
  }

  static Future<void> _deleteUserProducts(String userId) async {
    try {
      QuerySnapshot products = await _firestore
          .collection('Products')
          .doc(userId)
          .collection('products')
          .get();

      for (QueryDocumentSnapshot doc in products.docs) {
        await doc.reference.delete();
      }

      await _firestore.collection('Products').doc(userId).delete();
    } catch (e) {
      debugPrint('Delete user products error: $e');
    }
  }

  // Compatibility method for existing code
  static Future<bool> checkLogin(String email, String password) async {
    try {
      UserCredential? result = await signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result != null;
    } catch (e) {
      debugPrint('Check login error: $e');
      return false;
    }
  }
}
