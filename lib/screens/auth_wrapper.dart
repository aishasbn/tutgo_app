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
            future: authService.isStaff(),
            builder: (context, staffSnapshot) {
              if (staffSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Color(0xFFF8F4F4),
                  body: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFE91E63),
                    ),
                  ),
                );
              }
              
              final isStaff = staffSnapshot.data ?? false;
              print('ℹ️ User role: ${isStaff ? 'Staff' : 'User'}');
              
              if (isStaff) {
                // Navigate to conductor screens
                return const ConductorHomeScreen();
              } else {
                // Navigate to passenger screens
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
}
