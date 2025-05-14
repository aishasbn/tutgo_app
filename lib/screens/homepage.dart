import 'package:flutter/material.dart';
import 'package:tutgo/widgets/container_homepage.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            ScheduleCard(
              username: "Ndaboi",
              onBookingPressed: () {
                // Aksi saat tombol ditekan
                print("Booking code input clicked!");
              },
            ),

            // Konten lainnya bisa menyusul...
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.train), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
