import 'package:flutter/material.dart';
import 'package:tutgo/widgets/container_homepage.dart';
import 'package:tutgo/widgets/navbar_homepage.dart';
import 'package:tutgo/screens/train_code_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Here you would typically navigate to different screens
      // For now, we'll just update the index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFEE5E5), // Light pink background matching the image
      body: SafeArea(
        child: Column(
          children: [
            // Schedule Card
            ScheduleCard(
              username: "Ndaboi",
              onBookingPressed: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => const TrainCodeScreen(), 
                    ), 
                );
                // Aksi saat tombol ditekan
                //  print("Booking code input clicked!");
                // You could navigate to a booking screen or show a dialog here
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
                            Image.asset(
                              'assets/images/no_data.png', // Make sure this asset exists
                              width: 200,
                              height: 200,
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
 // Custom Navigation Bar with assets
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onNavItemTapped,
        baseColor: const Color(0xFFFFB74D), // Orange color for the nav bar
        activeIconColor: const Color(0xFF956D39), // Darker orange for active icons
        inactiveIconColor: const Color(0xFFFEF8EF), // Lighter orange for inactive icons
        centerColor: const Color(0xFFD84F9C), // Pink color for the center button
        homeIconPath: 'assets/images/home_icon.png',
        trainIconPath: 'assets/images/train_icon.png',
        profileIconPath: 'assets/images/profile_icon.png',
      ),
    );
  }
}
