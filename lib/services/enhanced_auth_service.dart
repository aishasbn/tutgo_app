import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EnhancedAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Enhanced register with PigeonUserDetails workaround
  Future<User?> registerWithEmailPasswordSafe(
    String name,
    String email,
    String password,
  ) async {
    try {
      print('🔄 Starting enhanced user registration for: $email');
      
      // Validate input
      if (name.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
        throw Exception('Semua field harus diisi');
      }
      
      if (password.length < 6) {
        throw Exception('Password minimal 6 karakter');
      }

      if (!_isValidEmail(email)) {
        throw Exception('Format email tidak valid');
      }

      // Check if email already exists
      final existingUser = await _checkEmailExists(email);
      if (existingUser) {
        throw Exception('Email sudah digunakan. Silakan gunakan email lain.');
      }

      // Try to create user with PigeonUserDetails error handling
      User? user = await _createUserWithWorkaround(email.trim(), password);
      
      if (user == null) {
        throw Exception('Gagal membuat akun');
      }

      // Create user document in Firestore
      await _createUserDocument(user, name.trim());

      // Update display name
      try {
        await user.updateDisplayName(name.trim());
      } catch (e) {
        print('⚠️ Warning: Failed to update display name: $e');
      }

      // Sign out user after registration (they need to login manually)
      await _auth.signOut();

      print('✅ User registration successful');
      return user;
    } catch (e) {
      print('❌ Enhanced registration error: $e');
      throw _enhanceError(e);
    }
  }

  // Enhanced sign in with PigeonUserDetails workaround
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      print('🔄 Starting enhanced user login for: $email');
      
      // Validate input
      if (email.trim().isEmpty || password.isEmpty) {
        throw Exception('Email dan password harus diisi');
      }

      // Try to sign in with PigeonUserDetails error handling
      User? user = await _signInWithWorkaround(email.trim(), password);
      
      if (user == null) {
        throw Exception('Login gagal');
      }

      // Ensure user document exists and is a user (not staff)
      await _verifyUserSession(user);

      print('✅ Enhanced login successful: ${user.uid}');
      return user;
    } catch (e) {
      print('❌ Enhanced login error: $e');
      throw _enhanceError(e);
    }
  }

  // Enhanced staff sign in
  Future<User?> signInStaffWithId(String staffId, String password) async {
    try {
      print('🔄 Starting enhanced staff login for: $staffId');
      
      // Validate input
      if (staffId.trim().isEmpty || password.isEmpty) {
        throw Exception('Staff ID dan password harus diisi');
      }

      // Find staff by staffId
      final staffQuery = await _firestore
          .collection('users')
          .where('staffId', isEqualTo: staffId.trim().toUpperCase())
          .where('userType', isEqualTo: 'staff')
          .limit(1)
          .get();

      if (staffQuery.docs.isEmpty) {
        throw Exception('Staff ID tidak ditemukan. Hubungi administrator.');
      }

      final staffData = staffQuery.docs.first.data();
      final email = staffData['email'];
      final isActive = staffData['isActive'] ?? true;

      // Check if staff account is active
      if (!isActive) {
        throw Exception('Akun staff tidak aktif. Hubungi administrator.');
      }

      // Try to sign in with PigeonUserDetails error handling
      User? user = await _signInWithWorkaround(email, password);
      
      if (user == null) {
        throw Exception('Login staff gagal');
      }

      // Verify staff session
      await _verifyStaffSession(user, staffId.trim().toUpperCase());

      print('✅ Enhanced staff login successful: ${user.uid}');
      return user;
    } catch (e) {
      print('❌ Enhanced staff login error: $e');
      throw _enhanceError(e);
    }
  }

  // Workaround method for createUserWithEmailAndPassword
  Future<User?> _createUserWithWorkaround(String email, String password) async {
    try {
      // Try normal creation first
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('⚠️ Create user error: $e');
      
      // Check if it's the PigeonUserDetails error
      if (e.toString().contains('PigeonUserDetails') || 
          e.toString().contains('List<Object?>')) {
        print('🔄 PigeonUserDetails error detected, checking if user was created...');
        
        // Wait a moment for Firebase to process
        await Future.delayed(const Duration(milliseconds: 1500));
        
        // Check if user is now signed in
        final currentUser = _auth.currentUser;
        if (currentUser != null && currentUser.email == email) {
          print('✅ User was created despite error: ${currentUser.uid}');
          return currentUser;
        }
        
        // Try to sign in to see if user exists
        try {
          final signInResult = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          print('✅ User exists, signed in: ${signInResult.user?.uid}');
          return signInResult.user;
        } catch (signInError) {
          print('❌ User was not created, original error: $e');
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  // Workaround method for signInWithEmailAndPassword
  Future<User?> _signInWithWorkaround(String email, String password) async {
    try {
      // Try normal sign in first
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('⚠️ Sign in error: $e');
      
      // Check if it's the PigeonUserDetails error
      if (e.toString().contains('PigeonUserDetails') || 
          e.toString().contains('List<Object?>')) {
        print('🔄 PigeonUserDetails error detected during sign in, checking current user...');
        
        // Wait a moment for Firebase to process
        await Future.delayed(const Duration(milliseconds: 1500));
        
        // Check if user is now signed in
        final currentUser = _auth.currentUser;
        if (currentUser != null && currentUser.email == email) {
          print('✅ User is signed in despite error: ${currentUser.uid}');
          return currentUser;
        } else {
          print('❌ User not signed in, rethrowing error');
          throw Exception('Login gagal. Periksa email dan password Anda.');
        }
      } else {
        // Handle other Firebase Auth errors
        if (e is FirebaseAuthException) {
          throw Exception(_handleAuthError(e));
        } else {
          rethrow;
        }
      }
    }
  }

  // Verify user session
  Future<void> _verifyUserSession(User user) async {
    try {
      // Reload user to get latest data
      await user.reload();
      
      // Get user data from Firestore
      final userData = await _getUserData(user.uid);
      
      if (userData == null) {
        print('⚠️ User document not found, creating...');
        await _createUserDocument(user, user.displayName ?? 'User');
      } else if (userData['userType'] == 'staff') {
        await _auth.signOut();
        throw Exception('Akun ini adalah akun staff. Silakan login melalui Staff Login.');
      }
      
      print('✅ User session verified');
    } catch (e) {
      print('❌ User session verification failed: $e');
      if (e.toString().contains('staff')) {
        rethrow;
      }
      // Continue even if verification fails
    }
  }

  // Verify staff session
  Future<void> _verifyStaffSession(User user, String staffId) async {
    try {
      // Reload user to get latest data
      await user.reload();
      
      // Get user data from Firestore
      final userData = await _getUserData(user.uid);
      
      if (userData == null || userData['userType'] != 'staff') {
        print('⚠️ Staff document not found or invalid, creating...');
        await _createStaffDocument(user, staffId);
      }
      
      print('✅ Staff session verified');
    } catch (e) {
      print('⚠️ Warning: Staff session verification failed: $e');
      // Continue even if verification fails
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('✅ User signed out successfully');
    } catch (e) {
      print('❌ Sign out error: $e');
      throw Exception('Gagal logout: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      if (email.trim().isEmpty) {
        throw Exception('Email harus diisi');
      }

      await _auth.sendPasswordResetEmail(email: email.trim());
      print('✅ Password reset email sent');
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    } catch (e) {
      rethrow;
    }
  }

  // Check if user is staff
  Future<bool> isStaff() async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final userData = await _getUserData(user.uid);
      return userData?['userType'] == 'staff';
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

      final userData = await _getUserData(user.uid);
      
      if (userData != null && userData is Map<String, dynamic>) {
        return userData;
      } else {
        print('⚠️ User data format is not as expected: $userData');
        return {};
      }
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
      if (user == null) throw Exception('User tidak ditemukan');

      // Update display name if provided
      if (name != null && name.trim().isNotEmpty) {
        try {
          await user.updateDisplayName(name.trim());
        } catch (e) {
          print('⚠️ Warning: Failed to update display name: $e');
        }
      }

      // Update Firestore document
      Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null && name.trim().isNotEmpty) {
        updateData['name'] = name.trim();
      }

      if (additionalData != null) {
        updateData.addAll(additionalData);
      }

      await _firestore.collection('users').doc(user.uid).update(updateData);
      print('✅ User profile updated successfully');
    } catch (e) {
      print('❌ Error updating user profile: $e');
      rethrow;
    }
  }

  // Check Firebase connection
  Future<bool> checkFirebaseConnection() async {
    try {
      // Check internet connectivity first
      final hasInternet = await _checkInternetConnection();
      if (!hasInternet) {
        print('❌ No internet connection');
        return false;
      }

      // Try to read from Firestore to check connection
      await _firestore.collection('connection_test').limit(1).get()
          .timeout(const Duration(seconds: 5));
      return true;
    } catch (e) {
      print('❌ Firebase connection check failed: $e');
      return false;
    }
  }

  // Check internet connection
  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      print('❌ Internet connection check failed: $e');
      return false;
    }
  }

  // Private helper methods
  Future<Map<String, dynamic>?> _getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get()
          .timeout(const Duration(seconds: 10));
      
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data is Map<String, dynamic>) {
          return data;
        } else {
          print('⚠️ Firestore document data is not Map<String, dynamic>: $data');
          return {};
        }
      }
      return null;
    } catch (e) {
      print('❌ Error getting user data from Firestore: $e');
      return null;
    }
  }

  // Helper method to create user document with retry
  Future<void> _createUserDocument(User user, String name) async {
    const maxRetries = 3;
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': user.email,
          'userType': 'user',
          'role': 'passenger',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // Verify document was created
        await Future.delayed(const Duration(milliseconds: 500));
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          print('✅ User document created successfully');
          return;
        }
      } catch (e) {
        print('⚠️ Attempt $attempt failed to create user document: $e');
        if (attempt == maxRetries) {
          throw Exception('Gagal menyimpan data user');
        }
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }
  }

  // Helper method to create staff document with retry
  Future<void> _createStaffDocument(User user, String staffId) async {
    const maxRetries = 3;
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': user.displayName ?? 'Staff',
          'email': user.email,
          'staffId': staffId,
          'userType': 'staff',
          'role': 'conductor',
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // Verify document was created
        await Future.delayed(const Duration(milliseconds: 500));
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          print('✅ Staff document created successfully');
          return;
        }
      } catch (e) {
        print('⚠️ Attempt $attempt failed to create staff document: $e');
        if (attempt == maxRetries) {
          throw Exception('Gagal menyimpan data staff');
        }
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }
  }

  Future<bool> _checkEmailExists(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan kombinasi huruf, angka, dan simbol.';
      case 'email-already-in-use':
        return 'Email sudah digunakan oleh akun lain.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-not-found':
        return 'Akun tidak ditemukan. Periksa email Anda.';
      case 'wrong-password':
        return 'Password salah. Silakan coba lagi.';
      case 'user-disabled':
        return 'Akun telah dinonaktifkan. Hubungi administrator.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi dalam beberapa menit.';
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah. Periksa koneksi Anda.';
      default:
        return e.message ?? 'Terjadi kesalahan yang tidak diketahui.';
    }
  }

  // Enhanced error handling
  Exception _enhanceError(dynamic error) {
    if (error is Exception) {
      return error;
    }
    
    if (error is ArgumentError) {
      return Exception(error.message);
    }
    
    String errorMessage = error.toString();
    
    // Handle PigeonUserDetails error specifically
    if (errorMessage.contains('PigeonUserDetails') || 
        errorMessage.contains('List<Object?>')) {
      return Exception('Terjadi kesalahan teknis saat autentikasi. Silakan coba lagi dalam beberapa saat.');
    }
    
    // Handle network errors
    if (errorMessage.contains('network') || 
        errorMessage.contains('connection') ||
        errorMessage.contains('timeout')) {
      return Exception('Koneksi internet bermasalah. Periksa koneksi Anda dan coba lagi.');
    }
    
    // Handle Firebase errors
    if (errorMessage.contains('firebase') || 
        errorMessage.contains('auth')) {
      return Exception('Terjadi kesalahan pada sistem autentikasi. Silakan coba lagi.');
    }
    
    return Exception('Terjadi kesalahan: $errorMessage');
  }

  // Get detailed error info
  String getDetailedErrorInfo(dynamic e) {
    if (e is FirebaseAuthException) {
      return 'Firebase Auth Error: ${e.code} - ${e.message}';
    } else if (e is FirebaseException) {
      return 'Firebase Error: ${e.code} - ${e.message}';
    } else {
      return 'Error: $e';
    }
  }

  // Debug method
  Future<void> debugAuthState() async {
    try {
      final user = currentUser;
      print('=== AUTH DEBUG INFO ===');
      print('Current User: ${user?.uid}');
      print('Email: ${user?.email}');
      print('Display Name: ${user?.displayName}');
      print('Email Verified: ${user?.emailVerified}');
      
      if (user != null) {
        final userData = await getUserData();
        print('User Data: $userData');
        print('Is Staff: ${await isStaff()}');
      }
      
      final hasConnection = await checkFirebaseConnection();
      print('Firebase Connection: $hasConnection');
      print('=====================');
    } catch (e) {
      print('❌ Debug auth state error: $e');
    }
  }
}
