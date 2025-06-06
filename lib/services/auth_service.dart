import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password (User)
  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      print('Sign in error: $e');
      return null;
    }
  }

  // Sign in with ID and password (Staff)
  Future<UserCredential?> signInStaffWithId(String staffId, String password) async {
    try {
      // Convert staff ID to email format for Firebase Auth
      String email = '$staffId@staff.tutgo.com';
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      print('Staff sign in error: $e');
      return null;
    }
  }

  // Register new user
  Future<UserCredential?> registerWithEmailPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user data to Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'name': name,
        'email': email,
        'userType': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update display name
      await result.user!.updateDisplayName(name);

      return result;
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  // Check if user is staff
  Future<bool> isStaff() async {
    if (currentUser == null) return false;
    
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['userType'] == 'staff';
      }
      
      // Check if email contains staff domain
      return currentUser!.email?.contains('@staff.tutgo.com') ?? false;
    } catch (e) {
      print('Error checking staff status: $e');
      return false;
    }
  }
}
