import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthHelper {
  static final AuthService _authService = AuthService();

  // Check if current user is authenticated
  static bool get isAuthenticated => _authService.currentUser != null;

  // Get current user ID
  static String? get currentUserId => _authService.currentUser?.uid;

  // Get current user email
  static String? get currentUserEmail => _authService.currentUser?.email;

  // Check if current user is staff
  static Future<bool> isCurrentUserStaff() async {
    try {
      return await _authService.isStaff();
    } catch (e) {
      print('Error checking staff status: $e');
      return false;
    }
  }

  // Get user display name with fallback
  static Future<String> getUserDisplayName() async {
    try {
      final userData = await _authService.getUserData();
      if (userData != null && userData['name'] != null) {
        return userData['name'];
      }
      
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        return currentUser.displayName ?? 
               currentUser.email?.split('@')[0] ?? 
               'User';
      }
      
      return 'User';
    } catch (e) {
      print('Error getting user display name: $e');
      return 'User';
    }
  }

  // Safe logout with error handling
  static Future<bool> safeLogout(BuildContext context) async {
    try {
      await _authService.signOut();
      return true;
    } catch (e) {
      print('Error during logout: $e');
      
      // Show error dialog
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Logout Error'),
            content: Text('Gagal logout: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      
      return false;
    }
  }

  // Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate staff ID format
  static bool isValidStaffId(String staffId) {
    return RegExp(r'^STAFF\d{3}$').hasMatch(staffId.toUpperCase());
  }

  // Format staff email from ID
  static String formatStaffEmail(String staffId) {
    return '${staffId.toLowerCase()}@staff.tutgo.com';
  }

  // Check if email is staff email
  static bool isStaffEmail(String email) {
    return email.endsWith('@staff.tutgo.com');
  }

  // Get user type string
  static Future<String> getUserType() async {
    try {
      final isStaff = await _authService.isStaff();
      return isStaff ? 'Staff' : 'User';
    } catch (e) {
      print('Error getting user type: $e');
      return 'User';
    }
  }

  // Refresh user data
  static Future<void> refreshUserData() async {
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        await currentUser.reload();
      }
    } catch (e) {
      print('Error refreshing user data: $e');
    }
  }
}
