import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/container_homepage.dart';
import '../services/auth_service.dart';
import '../utils/route_helper.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final User? currentUser = authService.currentUser;
    
    // Get username from Firebase Auth or default
    String username = currentUser?.displayName ?? 
                     currentUser?.email?.split('@')[0] ?? 
                     "User";

    return Scaffold(
      backgroundColor: const Color(0xFFFEE5E5),
      body: SafeArea(
        child: Column(
          children: [
            ScheduleCard(
              username: username,
              onBookingPressed: () {
                print("Booking code input clicked!");
                // Navigate ke train code screen
                RouteHelper.navigateToTrainCode(context);
              },
            ),
            
            // Notifications Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Notifications",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Logout button (opsional)
                        IconButton(
                          onPressed: () async {
                            await authService.signOut();
                            // AuthWrapper akan otomatis redirect ke login
                            RouteHelper.navigateAndClearStack(context, RouteHelper.authWrapper);
                          },
                          icon: const Icon(
                            Icons.logout,
                            color: Color(0xFFE91E63),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Empty notifications illustration
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.notifications_off,
                                size: 80,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "NO DATA",
                              style: TextStyle(
                                color: Color(0xFFD84F9C),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Welcome, $username!",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
