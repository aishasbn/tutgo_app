import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register new user dengan error handling yang lebih detail
  Future<User?> registerWithEmailPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      print('Attempting to register user: $email'); // Debug log
      
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('User created successfully: ${result.user?.uid}'); // Debug log

      // Update display name
      await result.user?.updateDisplayName(name);
      print('Display name updated'); // Debug log

      // Save user data to Firestore
      await _firestore.collection('users').doc(result.user?.uid).set({
        'name': name,
        'email': email,
        'userType': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('User data saved to Firestore'); // Debug log
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'weak-password':
          print('Error: Password terlalu lemah');
          break;
        case 'email-already-in-use':
          print('Error: Email sudah digunakan');
          break;
        case 'invalid-email':
          print('Error: Format email tidak valid');
          break;
        default:
          print('Error: ${e.message}');
      }
      return null;
    } catch (e) {
      print('General error during registration: $e');
      return null;
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      print('Attempting to sign in user: $email');
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Sign in successful: ${result.user?.uid}');
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during sign in: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      print('General error during sign in: $e');
      return null;
    }
  }

  // Rest of your methods...
  Future<User?> signInStaffWithId(String staffId, String password) async {
    try {
      String email = '$staffId@staff.tutgo.com';
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Staff sign in error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  Future<bool> isStaff() async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        return data?['userType'] == 'staff';
      }
      
      return user.email?.contains('@staff.tutgo.com') ?? false;
    } catch (e) {
      print('Error checking staff status: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }
}