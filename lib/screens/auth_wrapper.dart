import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../utils/route_helper.dart';
import 'auth/account_type_screen.dart';
import 'main_navigation_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
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
                    'Loading...',
                    style: TextStyle(
                      color: Color(0xFFE91E63),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        // If user is logged in, go to main screen
        if (snapshot.hasData && snapshot.data != null) {
          return const MainNavigationScreen();
        }
        
        // If not logged in, go to account type selection
        return const AccountTypeScreen();
      },
    );
  }
}
