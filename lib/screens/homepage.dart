// // lib/screens/homepage.dart
// import 'package:flutter/material.dart';
// import 'package:tutgo/widgets/container_homepage.dart';
// import 'package:tutgo/widgets/custom_navbar.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedIndex = 0;

//   void _onNavItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//       // Add navigation logic here if needed
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFEE5E5),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Your existing content
//             ScheduleCard(
//               username: "Ndaboi",
//               onBookingPressed: () {
//                 print("Booking code input clicked!");
//               },
//             ),
            
//             // Notifications Section
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 16),
//                     const Text(
//                       "Notifications",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     // Empty notifications illustration
//                     Expanded(
//                       child: Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Image.asset(
//                               'assets/images/no_data.png',
//                               width: 200,
//                               height: 200,
//                             ),
//                             const SizedBox(height: 10),
//                             const Text(
//                               "NO DATA",
//                               style: TextStyle(
//                                 color: Color(0xFFD84F9C),
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: CustomNavbar(
//   currentIndex: _selectedIndex,
//   onTap: (index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//     // Tambahkan logika navigasi di sini
//   },
// ),
//     );
//   }
// }