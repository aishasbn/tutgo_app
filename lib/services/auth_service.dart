import 'package:firebase_auth/firebase_auth.dart';
import 'enhanced_auth_service.dart';

class AuthService {
  final EnhancedAuthService _enhancedAuthService = EnhancedAuthService();

  // Get current user
  User? get currentUser => _enhancedAuthService.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _enhancedAuthService.authStateChanges;

  // Register with email and password
  Future<User?> registerWithEmailPassword(
    String name,
    String email,
    String password,
  ) async {
    return await _enhancedAuthService.registerWithEmailPasswordSafe(
      name,
      email,
      password,
    );
  }

  // Sign in with email and password
  Future<User?> signInWithEmailPassword(String email, String password) async {
    return await _enhancedAuthService.signInWithEmailPassword(email, password);
  }

  // Sign in staff with ID
  Future<User?> signInStaffWithId(String staffId, String password) async {
    return await _enhancedAuthService.signInStaffWithId(staffId, password);
  }

  // Sign out
  Future<void> signOut() async {
    await _enhancedAuthService.signOut();
  }

  // Check if user is staff
  Future<bool> isStaff() async {
    return await _enhancedAuthService.isStaff();
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    return await _enhancedAuthService.getUserData();
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? name,
    Map<String, dynamic>? additionalData,
  }) async {
    await _enhancedAuthService.updateUserProfile(
      name: name,
      additionalData: additionalData,
    );
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _enhancedAuthService.resetPassword(email);
  }

  // Check connection
  Future<bool> checkConnection() async {
    return await _enhancedAuthService.checkFirebaseConnection();
  }

  // Get detailed error info
  String getDetailedErrorInfo(dynamic e) {
    return _enhancedAuthService.getDetailedErrorInfo(e);
  }
}
