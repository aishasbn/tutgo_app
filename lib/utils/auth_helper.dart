import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthHelper {
  static final AuthService _authService = AuthService();

  // Check if current user is staff
  static Future<bool> isCurrentUserStaff() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return false;

      return await _authService.isStaff();
    } catch (e) {
      print('❌ Error checking if user is staff: $e');
      return false;
    }
  }

  // Get current user data
  static Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      return await _authService.getUserData();
    } catch (e) {
      print('❌ Error getting current user data: $e');
      return null;
    }
  }

  // Check if user is authenticated
  static bool isAuthenticated() {
    return _authService.currentUser != null;
  }

  // Get current user
  static User? getCurrentUser() {
    return _authService.currentUser;
  }

  // Sign out
  static Future<void> signOut() async {
    await _authService.signOut();
  }
}
