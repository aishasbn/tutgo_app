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
          print('✅ User authenticated: ${snapshot.data!.uid}');
          
          return FutureBuilder<bool>(
            future: _checkStaffRoleWithRetry(authService),
            builder: (context, staffSnapshot) {
              // Show loading while checking role
              if (staffSnapshot.connectionState == ConnectionState.waiting) {
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
              if (staffSnapshot.hasError) {
                print('❌ Role check error: ${staffSnapshot.error}');
                // Default to user if role check fails
                return const MainNavigationScreen();
              }
              
              final isStaff = staffSnapshot.data ?? false;
              print('ℹ️ User role determined: ${isStaff ? 'Staff/Kondektur' : 'User'}');
              
              if (isStaff) {
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

  // Helper method to check staff role with retry mechanism
  Future<bool> _checkStaffRoleWithRetry(AuthService authService) async {
    int maxRetries = 3;
    int currentRetry = 0;
    
    while (currentRetry < maxRetries) {
      try {
        print('🔍 Checking staff role (attempt ${currentRetry + 1}/$maxRetries)');
        
        // Add small delay to ensure Firebase is ready
        if (currentRetry > 0) {
          await Future.delayed(Duration(milliseconds: 500 * currentRetry));
        }
        
        final isStaff = await authService.isStaff();
        print('✅ Staff role check result: $isStaff');
        return isStaff;
        
      } catch (e) {
        currentRetry++;
        print('❌ Staff role check failed (attempt $currentRetry): $e');
        
        if (currentRetry >= maxRetries) {
          print('❌ Max retries reached, defaulting to user role');
          return false;
        }
      }
    }
    
    return false;
  }
}
