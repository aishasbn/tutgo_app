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

  // Check if user is staff with better error handling and multiple checks
  Future<bool> isStaff() async {
    try {
      print('🔍 AuthService: Checking if user is staff...');
      
      // First check with enhanced service
      final result = await _enhancedAuthService.isStaff();
      print('✅ AuthService: Staff check result from enhanced service: $result');
      
      if (result) {
        return true;
      }
      
      // If that fails, check email pattern directly
      final user = currentUser;
      if (user != null) {
        final email = user.email ?? '';
        
        // Check email patterns that indicate staff
        if (email.contains('@staff.tutgo.com') || 
            email.contains('staff') || 
            email.contains('conductor') || 
            email.contains('kondektur')) {
          print('✅ AuthService: Email pattern indicates staff: $email');
          return true;
        }
        
        // Check if email starts with numeric ID (likely staff ID)
        if (email.contains('@') && 
            email.split('@')[0].length >= 6 && 
            int.tryParse(email.split('@')[0]) != null) {
          print('✅ AuthService: Email format matches staff ID pattern: $email');
          return true;
        }
        
        // Get user data as final check
        try {
          final userData = await getUserData();
          if (userData != null) {
            final userType = userData['userType'] ?? '';
            final role = userData['role'] ?? '';
            
            if (userType == 'staff' || role == 'staff' || 
                role == 'conductor' || role == 'kondektur') {
              print('✅ AuthService: User data indicates staff role: $userType/$role');
              return true;
            }
          }
        } catch (e) {
          print('⚠️ AuthService: Error checking user data for staff role: $e');
        }
      }
      
      return false;
    } catch (e) {
      print('❌ AuthService: Error checking staff status: $e');
      
      // Last resort check - if error but email pattern matches staff
      try {
        final user = currentUser;
        if (user != null && (user.email?.contains('@staff.tutgo.com') ?? false)) {
          print('✅ AuthService: Despite error, email indicates staff');
          return true;
        }
      } catch (_) {}
      
      // Return false as default if all checks fail
      return false;
    }
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
