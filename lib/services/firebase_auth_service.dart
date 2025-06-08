import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // PERBAIKAN: Register dengan handling PigeonUserDetails error yang lebih baik
  Future<User?> registerWithEmailPasswordSafe(
    String name,
    String email,
    String password,
  ) async {
    User? createdUser;
    
    try {
      print('🔄 Starting registration for: $email');
      
      // Validate input
      if (name.trim().isEmpty) {
        throw ArgumentError('Nama tidak boleh kosong');
      }
      if (email.trim().isEmpty) {
        throw ArgumentError('Email tidak boleh kosong');
      }
      if (password.length < 6) {
        throw ArgumentError('Password minimal 6 karakter');
      }

      // Step 1: Create user account dengan try-catch untuk PigeonUserDetails
      UserCredential? result;
      try {
        result = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
      } catch (e) {
        print('❌ Error during createUserWithEmailAndPassword: $e');
        
        // Jika error PigeonUserDetails, cek apakah user sudah dibuat
        if (e.toString().contains('PigeonUserDetails') || e.toString().contains('List<Object?>')) {
          print('⚠️ PigeonUserDetails error detected, checking if user was created...');
          
          // Tunggu sebentar untuk Firebase selesai
          await Future.delayed(const Duration(milliseconds: 1000));
          
          // Cek apakah user sudah dibuat
          final currentUser = _auth.currentUser;
          if (currentUser != null && currentUser.email == email.trim()) {
            print('✅ User was created despite error: ${currentUser.uid}');
            createdUser = currentUser;
          } else {
            // Coba sign in untuk memastikan user ada
            try {
              final signInResult = await _auth.signInWithEmailAndPassword(
                email: email.trim(),
                password: password,
              );
              createdUser = signInResult.user;
              print('✅ User exists, signed in: ${createdUser?.uid}');
            } catch (signInError) {
              print('❌ User was not created, rethrowing original error');
              rethrow;
            }
          }
        } else {
          rethrow;
        }
      }
      
      // Ambil user dari result atau dari currentUser
      User? user = result?.user ?? createdUser;
      if (user == null) {
        throw StateError('Gagal membuat akun user');
      }

      print('✅ User account confirmed: ${user.uid}');

      // Step 2: Buat dokumen Firestore SEGERA
      await _createUserDocumentSafe(user.uid, {
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'userType': 'user',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Step 3: Update display name (dalam try-catch)
      try {
        await user.updateDisplayName(name.trim());
        print('✅ Display name updated');
      } catch (e) {
        print('⚠️ Warning: Failed to update display name: $e');
      }

      // Step 4: Sign out user (mereka harus login manual)
      await _auth.signOut();
      print('✅ User logged out after registration - must login manually');

      return user;
    } catch (e) {
      print('❌ Registration error: $e');
      
      // Jika ada user yang dibuat tapi proses gagal, coba bersihkan
      try {
        final currentUser = _auth.currentUser;
        if (currentUser != null && currentUser.email == email.trim()) {
          print('⚠️ Cleaning up created user due to error');
          
          // Coba buat dokumen Firestore dulu sebelum delete
          try {
            await _createUserDocumentSafe(currentUser.uid, {
              'uid': currentUser.uid,
              'name': name.trim(),
              'email': email.trim(),
              'userType': 'user',
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
            
            // Jika berhasil buat dokumen, jangan delete user
            await _auth.signOut();
            print('✅ User document created, keeping user account');
            return currentUser;
          } catch (firestoreError) {
            print('❌ Failed to create Firestore document, deleting user');
            await currentUser.delete();
          }
        }
      } catch (cleanupError) {
        print('⚠️ Cleanup error: $cleanupError');
      }
      
      rethrow;
    }
  }

  // Helper method untuk membuat dokumen Firestore dengan retry yang agresif
  Future<void> _createUserDocumentSafe(String uid, Map<String, dynamic> data) async {
    const maxRetries = 5;
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print('🔄 Attempting to create Firestore document (attempt $attempt/$maxRetries)');
        
        await _firestore.collection('users').doc(uid).set(data);
        print('✅ User document created in Firestore (attempt $attempt)');
        
        // Verifikasi dokumen benar-benar dibuat
        await Future.delayed(const Duration(milliseconds: 500));
        final doc = await _firestore.collection('users').doc(uid).get();
        if (doc.exists) {
          print('✅ Document verified to exist in Firestore');
          return;
        } else {
          print('⚠️ Document not found after creation, retrying...');
          throw StateError('Document not found after creation');
        }
        
      } catch (e) {
        print('⚠️ Attempt $attempt failed to create Firestore document: $e');
        
        if (attempt == maxRetries) {
          print('❌ All attempts failed to create Firestore document');
          throw StateError('Gagal menyimpan data user ke database setelah $maxRetries percobaan');
        }
        
        // Delay yang semakin lama untuk setiap retry
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }
  }

  // PERBAIKAN: Sign in dengan handling yang lebih baik
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      print('🔄 Starting sign in for: $email');
      
      if (email.trim().isEmpty) {
        throw ArgumentError('Email tidak boleh kosong');
      }
      if (password.isEmpty) {
        throw ArgumentError('Password tidak boleh kosong');
      }

      // Sign in dengan error handling
      UserCredential result;
      try {
        result = await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
      } catch (e) {
        // Handle PigeonUserDetails error
        if (e.toString().contains('PigeonUserDetails') || e.toString().contains('List<Object?>')) {
          print('⚠️ PigeonUserDetails error detected during sign in, checking current user...');
          await Future.delayed(const Duration(milliseconds: 500));
          
          final currentUser = _auth.currentUser;
          if (currentUser != null && currentUser.email == email.trim()) {
            print('✅ User is signed in despite error: ${currentUser.uid}');
            await _ensureUserDocumentExists(currentUser);
            return currentUser;
          }
        }
        rethrow;
      }
      
      User? user = result.user;
      if (user != null) {
        await _ensureUserDocumentExists(user);
        print('✅ Sign in successful: ${user.uid}');
      }
      
      return user;
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException during sign in: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ General error during sign in: $e');
      
      // Check if user is actually signed in despite the error
      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.email == email.trim()) {
        print('✅ User is signed in despite error: ${currentUser.uid}');
        await _ensureUserDocumentExists(currentUser);
        return currentUser;
      }
      
      throw StateError('Terjadi kesalahan saat login: ${e.toString()}');
    }
  }

  // Helper method untuk memastikan dokumen user ada
  Future<void> _ensureUserDocumentExists(User user) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!doc.exists) {
        print('⚠️ User document not found in Firestore, creating...');
        await _createUserDocumentSafe(user.uid, {
          'uid': user.uid,
          'name': user.displayName ?? user.email?.split('@')[0] ?? 'User',
          'email': user.email,
          'userType': user.email?.contains('@staff.tutgo.com') == true ? 'staff' : 'user',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        print('✅ User document exists in Firestore');
      }
    } catch (e) {
      print('⚠️ Warning: Failed to ensure user document exists: $e');
    }
  }

  // Staff login dengan handling yang sama
  Future<User?> signInStaffWithId(String staffId, String password) async {
    try {
      print('🔄 Starting staff sign in for: $staffId');
      
      if (staffId.trim().isEmpty) {
        throw ArgumentError('Staff ID tidak boleh kosong');
      }
      if (password.isEmpty) {
        throw ArgumentError('Password tidak boleh kosong');
      }
      
      String email = '${staffId.trim().toLowerCase()}@staff.tutgo.com';
      print('🔄 Converted staff ID to email: $email');
      
      UserCredential result;
      try {
        result = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        if (e.toString().contains('PigeonUserDetails') || e.toString().contains('List<Object?>')) {
          print('⚠️ PigeonUserDetails error detected for staff, checking current user...');
          await Future.delayed(const Duration(milliseconds: 500));
          
          final currentUser = _auth.currentUser;
          if (currentUser != null && currentUser.email == email) {
            print('✅ Staff is signed in despite error: ${currentUser.uid}');
            await _ensureStaffDocumentExists(currentUser, staffId.trim().toUpperCase());
            return currentUser;
          }
        }
        rethrow;
      }
      
      User? user = result.user;
      if (user != null) {
        await _ensureStaffDocumentExists(user, staffId.trim().toUpperCase());
        print('✅ Staff sign in successful: ${user.uid}');
      }
      
      return user;
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException during staff sign in: ${e.code} - ${e.message}');
      
      if (e.code == 'user-not-found') {
        throw StateError('Staff ID tidak ditemukan. Hubungi administrator untuk membuat akun staff.');
      }
      
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ General error during staff sign in: $e');
      
      final currentUser = _auth.currentUser;
      if (currentUser != null && currentUser.email?.contains('@staff.tutgo.com') == true) {
        print('✅ Staff is signed in despite error: ${currentUser.uid}');
        await _ensureStaffDocumentExists(currentUser, staffId.trim().toUpperCase());
        return currentUser;
      }
      
      throw StateError('Terjadi kesalahan saat login staff: ${e.toString()}');
    }
  }

  // Helper method untuk memastikan dokumen staff ada
  Future<void> _ensureStaffDocumentExists(User user, String staffId) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!doc.exists) {
        print('⚠️ Staff document not found in Firestore, creating...');
        await _createUserDocumentSafe(user.uid, {
          'uid': user.uid,
          'name': user.displayName ?? 'Staff',
          'email': user.email,
          'staffId': staffId,
          'userType': 'staff',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        print('✅ Staff document exists in Firestore');
        final data = doc.data();
        if (data != null && data['staffId'] == null) {
          await _firestore.collection('users').doc(user.uid).update({
            'staffId': staffId,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          print('✅ Staff ID updated in Firestore');
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
      throw StateError('Gagal logout: ${e.toString()}');
    }
  }

  // Check if user is staff
  Future<bool> isStaff() async {
    try {
      final user = currentUser;
      if (user == null) {
        return false;
      }

      try {
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
      } catch (e) {
        print('⚠️ Warning: Failed to check Firestore for staff status: $e');
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
      if (user == null) {
        return null;
      }

      try {
        final doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get()
            .timeout(const Duration(seconds: 5));
            
        if (doc.exists) {
          final data = doc.data();
          if (data != null) {
            print('✅ User data retrieved from Firestore');
            return data;
          }
        } else {
          print('! User document not found in Firestore');
          // Coba buat dokumen jika tidak ada
          await _ensureUserDocumentExists(user);
          
          // Coba ambil lagi
          final retryDoc = await _firestore.collection('users').doc(user.uid).get();
          if (retryDoc.exists) {
            return retryDoc.data();
          }
        }
      } catch (e) {
        print('⚠️ Warning: Failed to get user data from Firestore: $e');
      }
      
      final fallbackData = {
        'uid': user.uid,
        'name': user.displayName ?? user.email?.split('@')[0] ?? 'User',
        'email': user.email,
        'userType': user.email?.contains('@staff.tutgo.com') == true ? 'staff' : 'user',
      };
      print('ℹ️ Returning fallback user data');
      return fallbackData;
    } catch (e) {
      print('❌ Error getting user data: $e');
      return null;
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
        throw StateError('User tidak ditemukan');
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
      throw StateError('Gagal update profile: ${e.toString()}');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      if (email.trim().isEmpty) {
        throw ArgumentError('Email tidak boleh kosong');
      }

      await _auth.sendPasswordResetEmail(email: email.trim());
      print('✅ Password reset email sent');
    } on FirebaseAuthException catch (e) {
      print('❌ FirebaseAuthException during password reset: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ General error during password reset: $e');
      throw StateError('Gagal mengirim email reset password: ${e.toString()}');
    }
  }

  // Handle Firebase Auth exceptions
  StateError _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return StateError('Password terlalu lemah. Minimal 6 karakter dengan kombinasi huruf dan angka.');
      case 'email-already-in-use':
        return StateError('Email sudah digunakan oleh akun lain. Silakan gunakan email yang berbeda.');
      case 'invalid-email':
        return StateError('Format email tidak valid. Periksa kembali email Anda.');
      case 'user-not-found':
        return StateError('Akun tidak ditemukan. Periksa email Anda atau daftar akun baru.');
      case 'wrong-password':
        return StateError('Password salah. Periksa kembali password Anda.');
      case 'user-disabled':
        return StateError('Akun telah dinonaktifkan. Hubungi administrator.');
      case 'too-many-requests':
        return StateError('Terlalu banyak percobaan login. Coba lagi dalam beberapa menit.');
      case 'operation-not-allowed':
        return StateError('Operasi tidak diizinkan. Hubungi administrator.');
      case 'invalid-credential':
        return StateError('Kredensial tidak valid. Periksa email dan password Anda.');
      case 'network-request-failed':
        return StateError('Koneksi internet bermasalah. Periksa koneksi Anda dan coba lagi.');
      case 'requires-recent-login':
        return StateError('Operasi ini memerlukan login ulang. Silakan logout dan login kembali.');
      default:
        return StateError('Terjadi kesalahan: ${e.message ?? 'Unknown error'}');
    }
  }

  // Check Firebase connection
  Future<bool> checkFirebaseConnection() async {
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

  // Get detailed error info for debugging
  String getDetailedErrorInfo(dynamic e) {
    if (e is FirebaseAuthException) {
      return '''
Firebase Auth Error:
- Code: ${e.code}
- Message: ${e.message}
- Plugin: ${e.plugin}
''';
    }
    return 'General Error: ${e.toString()}';
  }
}
