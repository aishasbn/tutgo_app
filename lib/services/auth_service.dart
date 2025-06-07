import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_auth_service.dart';

class AuthService {
  final FirebaseAuthService _firebaseAuth = FirebaseAuthService();

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges;

  // Sign in with email and password (User)
  Future<User?> signInWithEmailPassword(String email, String password) async {
    return await _firebaseAuth.signInWithEmailPassword(email, password);
  }

  // Sign in with ID and password (Staff)
  Future<User?> signInStaffWithId(String staffId, String password) async {
    return await _firebaseAuth.signInStaffWithId(staffId, password);
  }

  // Register new user
  Future<User?> registerWithEmailPassword(
    String name,
    String email,
    String password,
  ) async {
    return await _firebaseAuth.registerWithEmailPassword(name, email, password);
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Check if user is staff
  Future<bool> isStaff() async {
    return await _firebaseAuth.isStaff();
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    return await _firebaseAuth.getUserData();
  }
}
