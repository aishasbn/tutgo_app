import 'package:flutter/material.dart';

class CustomNavBar extends StatefulWidget {
  final Function(int) onItemSelected;
  final int selectedIndex;
  
  // Parameters for customization
  final Color baseColor;
  final Color activeIconColor;
  final Color inactiveIconColor;
  final Color centerColor;
  final double height;
  final double centerButtonSize;
  
  // Asset paths
  final String homeIconPath;
  final String trainIconPath;
  final String profileIconPath;
  
  const CustomNavBar({
    Key? key, 
    required this.onItemSelected, 
    this.selectedIndex = 0,
    this.baseColor = const Color(0xFFFFB74D),     // Orange/Yellow background
    this.activeIconColor = const Color(0xFF956D39),  // Darker orange for active icons
    this.inactiveIconColor = const Color(0xFFFEF8EF), // Light orange for inactive icons
    this.centerColor = const Color(0xFFD84F9C),   // Pink color for center button
    this.height = 80.0,
    this.centerButtonSize = 60.0,
    this.homeIconPath = 'assets/images/home_icon.png',
    this.trainIconPath = 'assets/images/train_icon.png',
    this.profileIconPath = 'assets/images/profile_icon.png',
  }) : super(key: key);
  
  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  // Track hover states
  bool _isHomeHovered = false;
  bool _isProfileHovered = false;
  
  @override
  Widget build(BuildContext context) {
    // Calculate center button's position
    final centerButtonPosition = widget.height * 0.15; // How much it sticks out
    
    return Container(
      height: widget.height,
      child: Stack(
        children: [
          // Main rectangular bottom bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: widget.height - centerButtonPosition,
              decoration: BoxDecoration(
                color: widget.baseColor,
              ),
            ),
          ),
          
          // Left item (Home)
          Positioned(
            left: 0,
            bottom: 0,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHomeHovered = true),
              onExit: (_) => setState(() => _isHomeHovered = false),
              child: GestureDetector(
                onTap: () => widget.onItemSelected(0),
                child: Container(
                  width: MediaQuery.of(context).size.width / 3,
                  height: widget.height - centerButtonPosition,
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Use Image.asset if you have icons, or Icons for built-in Flutter icons
                      Image.asset(
                        widget.homeIconPath,
                        width: 24,
                        height: 24,
                        color: (widget.selectedIndex == 0 || _isHomeHovered) 
                            ? widget.activeIconColor 
                            : widget.inactiveIconColor,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Home',
                        style: TextStyle(
                          color: (widget.selectedIndex == 0 || _isHomeHovered) 
                              ? widget.activeIconColor 
                              : widget.inactiveIconColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Right item (Profile)
          Positioned(
            right: 0,
            bottom: 0,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isProfileHovered = true),
              onExit: (_) => setState(() => _isProfileHovered = false),
              child: GestureDetector(
                onTap: () => widget.onItemSelected(2),
                child: Container(
                  width: MediaQuery.of(context).size.width / 3,
                  height: widget.height - centerButtonPosition,
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        widget.profileIconPath,
                        width: 24,
                        height: 24,
                        color: (widget.selectedIndex == 2 || _isProfileHovered) 
                            ? widget.activeIconColor 
                            : widget.inactiveIconColor,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Profile',
                        style: TextStyle(
                          color: (widget.selectedIndex == 2 || _isProfileHovered) 
                              ? widget.activeIconColor 
                              : widget.inactiveIconColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Center protruding circular button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => widget.onItemSelected(1),
                child: Container(
                  width: widget.centerButtonSize,
                  height: widget.centerButtonSize,
                  decoration: BoxDecoration(
                    color: widget.centerColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.asset(
                      widget.trainIconPath,
                      width: 30,
                      height: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}