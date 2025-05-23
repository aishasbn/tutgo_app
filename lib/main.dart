import 'package:flutter/material.dart';
import 'package:tutgo/screens/homepage.dart'; // Make sure this path is correct

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TUTGO',
      debugShowCheckedModeBanner: false, // Removes debug banner
      theme: ThemeData(
        // Set the primary color theme to match your design (pink)
        primaryColor: const Color(0xFFD84F9C),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD84F9C),
          primary: const Color(0xFFD84F9C),
          secondary: const Color(0xFFFFB74D),
        ),
        // Add other theme customizations as needed
        fontFamily: 'Poppins', // If you're using a custom font
        scaffoldBackgroundColor: const Color(0xFFFEE5E5), // Light pink background
      ),
      home: const HomeScreen(), // Show your HomeScreen as the initial screen
    );
  }
}