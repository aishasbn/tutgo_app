import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Register user with improved error handling
  Future<User?> registerWithEmailPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      print('🔄 Starting registration for: $email');
      
      // Validate input
      if (name.trim().isEmpty) {
        throw Exception('Nama tidak boleh kosong');
      }
      if (email.trim().isEmpty) {
        throw Exception('Email tidak boleh kosong');
      }
      if (password.length < 6) {
        throw Exception('Password minimal 6 karakter');
      }

      // Create user account
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      User? user = result.user;
      if (user == null) {
        throw Exception('Gagal membuat akun user');
      }

      print('✅ User account created: ${user.uid}');

      // Create Firestore document
      await _createUserDocument(user.uid, {
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'userType': 'user',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update display name
      await user.updateDisplayName(name.trim());
      print('✅ Display name updated');

      // Sign out user (they must login manually)
      await _auth.signOut();
      print('✅ User logged out after registration');

      return user;
    } catch (e) {
      print('❌ Registration error: $e');
      rethrow;
    }
  }

  // Create user document with retry logic
  Future<void> _createUserDocument(String uid, Map<String, dynamic> data) async {
    const maxRetries = 3;
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print('🔄 Creating Firestore document (attempt $attempt/$maxRetries)');
        
        await _firestore.collection('users').doc(uid).set(data);
        print('✅ User document created in Firestore');
        
        // Verify document exists
        final doc = await _firestore.collection('users').doc(uid).get();
        if (doc.exists) {
          print('✅ Document verified');
          return;
        } else {
          throw Exception('Document not found after creation');
        }
        
      } catch (e) {
        print('⚠️ Attempt $attempt failed: $e');
        
        if (attempt == maxRetries) {
          throw Exception('Gagal menyimpan data user setelah $maxRetries percobaan');
        }
        
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      print('🔄 Starting sign in for: $email');
      
      if (email.trim().isEmpty) {
        throw Exception('Email tidak boleh kosong');
      }
      if (password.isEmpty) {
        throw Exception('Password tidak boleh kosong');
      }

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      User? user = result.user;
      if (user != null) {
        await _ensureUserDocumentExists(user);
        print('✅ Sign in successful: ${user.uid}');
      }
      
      return user;
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException: ${e.code} - ${e.message}');
      throw Exception(_handleAuthException(e));
    } catch (e) {
      print('❌ Sign in error: $e');
      rethrow;
    }
  }

  // Staff login with ID
  Future<User?> signInStaffWithId(String staffId, String password) async {
    try {
      print('🔄 Starting staff sign in for: $staffId');
      
      if (staffId.trim().isEmpty) {
        throw Exception('Staff ID tidak boleh kosong');
      }
      if (password.isEmpty) {
        throw Exception('Password tidak boleh kosong');
      }
      
      String email = '${staffId.trim().toLowerCase()}@staff.tutgo.com';
      print('🔄 Converted staff ID to email: $email');
      
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      if (user != null) {
        await _ensureStaffDocumentExists(user, staffId.trim().toUpperCase());
        print('✅ Staff sign in successful: ${user.uid}');
      }
      
      return user;
    } on FirebaseAuthException catch (e) {
      print('❌ Staff sign in error: ${e.code} - ${e.message}');
      
      if (e.code == 'user-not-found') {
        throw Exception('Staff ID tidak ditemukan. Hubungi administrator.');
      }
      
      throw Exception(_handleAuthException(e));
    } catch (e) {
      print('❌ Staff sign in error: $e');
      rethrow;
    }
  }

  // Ensure user document exists
  Future<void> _ensureUserDocumentExists(User user) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!doc.exists) {
        print('⚠️ User document not found, creating...');
        await _createUserDocument(user.uid, {
          'uid': user.uid,
          'name': user.displayName ?? user.email?.split('@')[0] ?? 'User',
          'email': user.email,
          'userType': user.email?.contains('@staff.tutgo.com') == true ? 'staff' : 'user',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('⚠️ Warning: Failed to ensure user document exists: $e');
    }
  }

  // Ensure staff document exists
  Future<void> _ensureStaffDocumentExists(User user, String staffId) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!doc.exists) {
        print('⚠️ Staff document not found, creating...');
        await _createUserDocument(user.uid, {
          'uid': user.uid,
          'name': user.displayName ?? 'Staff',
          'email': user.email,
          'staffId': staffId,
          'userType': 'staff',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        final data = doc.data();
        if (data != null && data['staffId'] == null) {
          await _firestore.collection('users').doc(user.uid).update({
            'staffId': staffId,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      print('⚠️ Warning: Failed to ensure staff document exists: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      print('🔄 Signing out user...');
      await _auth.signOut();
      print('✅ User signed out successfully');
    } catch (e) {
      print('❌ Sign out error: $e');
      throw Exception('Gagal logout: $e');
    }
  }

  // Check if user is staff
  Future<bool> isStaff() async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 5));
          
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          return data['userType'] == 'staff';
        }
      }
      
      return user.email?.contains('@staff.tutgo.com') ?? false;
    } catch (e) {
      print('❌ Error checking staff status: $e');
      return false;
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(const Duration(seconds: 5));
          
      if (doc.exists) {
        return doc.data();
      }
      
      // Return fallback data
      return {
        'uid': user.uid,
        'name': user.displayName ?? user.email?.split('@')[0] ?? 'User',
        'email': user.email,
        'userType': user.email?.contains('@staff.tutgo.com') == true ? 'staff' : 'user',
      };
    } catch (e) {
      print('❌ Error getting user data: $e');
      return null;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      if (email.trim().isEmpty) {
        throw Exception('Email tidak boleh kosong');
      }

      await _auth.sendPasswordResetEmail(email: email.trim());
      print('✅ Password reset email sent');
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception('Gagal mengirim email reset password: $e');
    }
  }

  // Check connection
  Future<bool> checkConnection() async {
    try {
      await _firestore
          .collection('_test')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 5));
      return true;
    } catch (e) {
      print('❌ Firebase connection failed: $e');
      return false;
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password terlalu lemah. Minimal 6 karakter.';
      case 'email-already-in-use':
        return 'Email sudah digunakan oleh akun lain.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-not-found':
        return 'Akun tidak ditemukan.';
      case 'wrong-password':
        return 'Password salah.';
      case 'user-disabled':
        return 'Akun telah dinonaktifkan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'invalid-credential':
        return 'Kredensial tidak valid.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah.';
      default:
        return e.message ?? 'Terjadi kesalahan yang tidak diketahui.';
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? name,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('User tidak ditemukan');
      }

    Map<String, dynamic> updateData = {
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (name != null && name.trim().isNotEmpty) {
      updateData['name'] = name.trim();
      
      try {
        await user.updateDisplayName(name.trim());
      } catch (e) {
        print('⚠️ Warning: Failed to update display name in Auth: $e');
      }
    }

    if (additionalData != null) {
      updateData.addAll(additionalData);
    }

    await _firestore.collection('users').doc(user.uid).update(updateData);
    print('✅ User profile updated in Firestore');
  } catch (e) {
    print('❌ Error updating user profile: $e');
    throw Exception('Gagal update profile: $e');
  }
}
}
