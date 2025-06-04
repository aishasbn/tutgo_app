import 'package:flutter/material.dart';
import '../widgets/container_homepage.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEE5E5),
      body: SafeArea(
        child: Column(
          children: [
            ScheduleCard(
              username: "Ndaboi",
              onBookingPressed: () {
                print("Booking code input clicked!");
                // Bisa navigasi ke screen input booking code
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
                    const Text(
                      "Notifications",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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