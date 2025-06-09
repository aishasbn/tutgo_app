import 'package:flutter/material.dart';
import '../widgets/profile_header_widget.dart';
import '../widgets/profile_info_item_widget.dart';
import '../widgets/bottom_navigation_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 1; // Profile tab is selected

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    if (index == 0) {
      // Navigate back to Home
      Navigator.pushNamedAndRemoveUntil(
        context, 
        '/home', 
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF5EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                ProfileHeaderWidget(
                  name: 'Aisha Sabina',
                  role: 'Kondektur 1',
                ),
                const SizedBox(height: 16),
                ProfileInfoItemWidget(
                  label: 'Email Address',
                  value: 'aishasabina@gmail.com',
                ),
                ProfileInfoItemWidget(
                  label: 'Username',
                  value: 'Aisha Sabina',
                ),
                ProfileInfoItemWidget(
                  label: 'ID Kondektur',
                  value: '250510',
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}
