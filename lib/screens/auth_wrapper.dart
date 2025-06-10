import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'auth/account_type_screen.dart';
import '../kondektur/screens/home_screen.dart';
import '../screens/main_navigation_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8F4F4),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFFE91E63),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading TutGo...',
                    style: TextStyle(
                      color: Color(0xFFE91E63),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Handle errors in auth state
        if (snapshot.hasError) {
          print('❌ Auth state error: ${snapshot.error}');
          return const AccountTypeScreen();
        }

        // If user is logged in, determine their role and navigate accordingly
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          print('✅ User authenticated: ${user.uid}');
          print('📧 User email: ${user.email}');
          
          return FutureBuilder<Map<String, dynamic>?>(
            future: _getUserRoleWithRetry(authService, user),
            builder: (context, roleSnapshot) {
              // Show loading while checking role
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Color(0xFFF8F4F4),
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFFE91E63),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Checking user role...',
                          style: TextStyle(
                            color: Color(0xFFE91E63),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              // Handle role check error
              if (roleSnapshot.hasError) {
                print('❌ Role check error: ${roleSnapshot.error}');
                // Default to user if role check fails
                return const MainNavigationScreen();
              }
              
              final userData = roleSnapshot.data;
              final isStaff = userData?['isStaff'] ?? false;
              final userRole = userData?['role'] ?? 'user';
              
              print('ℹ️ User role determined: $userRole (isStaff: $isStaff)');
              print('ℹ️ User data: $userData');
              
              // Check multiple conditions for staff with more robust checks
              final bool shouldRouteToStaff = isStaff || 
                  userRole == 'staff' || 
                  userRole == 'conductor' || 
                  userRole == 'kondektur' ||
                  (user.email?.contains('@staff.tutgo.com') ?? false);

              print('🚂 Role determination: isStaff=$isStaff, userRole=$userRole, email=${user.email}');
              print('🚂 Should route to staff: $shouldRouteToStaff');

              if (shouldRouteToStaff) {
                print('🚂 Navigating to ConductorHomeScreen');
                return const ConductorHomeScreen();
              } else {
                print('👤 Navigating to MainNavigationScreen');
                return const MainNavigationScreen();
              }
            },
          );
        }
        
        // If not logged in, go to account type selection
        print('ℹ️ No authenticated user, showing account type screen');
        return const AccountTypeScreen();
      },
    );
  }

  // Helper method to get user role with retry mechanism
  Future<Map<String, dynamic>?> _getUserRoleWithRetry(AuthService authService, User user) async {
    int maxRetries = 3;
    int currentRetry = 0;
    
    while (currentRetry < maxRetries) {
      try {
        print('🔍 Getting user role (attempt ${currentRetry + 1}/$maxRetries)');
        
        // Add small delay to ensure Firebase is ready
        if (currentRetry > 0) {
          await Future.delayed(Duration(milliseconds: 500 * currentRetry));
        }
        
        // Get user data from Firestore
        final userData = await authService.getUserData();
        print('📄 User data from Firestore: $userData');
        
        if (userData != null) {
          return userData;
        }
        
        // If no user data in Firestore, check if email indicates staff
        final email = user.email ?? '';
        print('📧 Checking email for staff indication: $email');

        // Check if email contains staff indicators or matches staff pattern
        if (email.contains('staff') || 
            email.contains('conductor') || 
            email.contains('kondektur') ||
            email.contains('@staff.tutgo.com') ||
            RegExp(r'^\d+@staff\.tutgo\.com$').hasMatch(email)) {
          print('✅ Email indicates staff role');
          return {
            'isStaff': true,
            'role': 'staff',
            'email': email,
            'name': user.displayName ?? 'Staff User',
          };
        }

        // Additional check for staff ID pattern in email
        if (email.contains('@') && 
            email.split('@')[0].length >= 6 && 
            int.tryParse(email.split('@')[0]) != null) {
          print('✅ Email format matches staff ID pattern');
          return {
            'isStaff': true,
            'role': 'staff',
            'email': email,
            'name': user.displayName ?? 'Staff User',
          };
        }
        
        // Default to user role
        return {
          'isStaff': false,
          'role': 'user',
          'email': email,
          'name': user.displayName ?? 'User',
        };
        
      } catch (e) {
        currentRetry++;
        print('❌ User role check failed (attempt $currentRetry): $e');
        
        if (currentRetry >= maxRetries) {
          print('❌ Max retries reached, defaulting to user role');
          return {
            'isStaff': false,
            'role': 'user',
            'email': user.email ?? '',
            'name': user.displayName ?? 'User',
          };
        }
      }
    }
    
    return null;
  }
}
