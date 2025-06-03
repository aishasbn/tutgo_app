import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/train_list_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/custom_navbar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Train Tracking App - Home',
      theme: ThemeData(primarySwatch: Colors.pink),
      home: MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    TrainListScreen(),
    ProfileScreen(),
  ];

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomNavBar(
        onItemSelected: _onItemSelected,
        selectedIndex: _selectedIndex,
      ),
    );
  }
}