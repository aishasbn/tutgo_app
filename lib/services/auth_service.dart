import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_auth_service.dart';

class AuthService {
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();

  // Get current user
  User? get currentUser => _firebaseAuthService.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _firebaseAuthService.authStateChanges;

  // Register with email and password
  Future<User?> registerWithEmailPassword(
    String name,
    String email,
    String password,
  ) async {
    return await _firebaseAuthService.registerWithEmailPasswordSafe(
      name,
      email,
      password,
    );
  }

  // Sign in with email and password
  Future<User?> signInWithEmailPassword(String email, String password) async {
    return await _firebaseAuthService.signInWithEmailPassword(email, password);
  }

  // Sign in staff with ID
  Future<User?> signInStaffWithId(String staffId, String password) async {
    return await _firebaseAuthService.signInStaffWithId(staffId, password);
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuthService.signOut();
  }

  // Check if user is staff
  Future<bool> isStaff() async {
    return await _firebaseAuthService.isStaff();
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    return await _firebaseAuthService.getUserData();
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? name,
    Map<String, dynamic>? additionalData,
  }) async {
    await _firebaseAuthService.updateUserProfile(
      name: name,
      additionalData: additionalData,
    );
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _firebaseAuthService.resetPassword(email);
  }

  // Check connection
  Future<bool> checkConnection() async {
    return await _firebaseAuthService.checkFirebaseConnection();
  }

  // Get detailed error info
  String getDetailedErrorInfo(dynamic e) {
    return _firebaseAuthService.getDetailedErrorInfo(e);
  }
}
