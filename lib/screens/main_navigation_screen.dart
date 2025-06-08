import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'train_list_screen.dart';
import 'profile_screen.dart';
import '../widgets/custom_navbar.dart';

class MainNavigationScreen extends StatefulWidget {
const MainNavigationScreen({super.key});

@override
_MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
int _selectedIndex = 0;

final List<Widget> _screens = [
  const HomeScreen(),
  const TrainListScreen(),
  const ProfileScreen(),
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
