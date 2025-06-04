import 'package:flutter/material.dart';

class CustomNavBar extends StatefulWidget {
  final Function(int) onItemSelected;
  final int selectedIndex;
  final Color baseColor;
  final Color activeIconColor;
  final Color inactiveIconColor;
  final Color centerColor;
  final double height;
  final double centerButtonSize;
  
  const CustomNavBar({
    super.key, 
    required this.onItemSelected, 
    this.selectedIndex = 0,
    this.baseColor = const Color(0xFFFFB74D),
    this.activeIconColor = const Color(0xFF956D39),
    this.inactiveIconColor = const Color(0xFFFEF8EF),
    this.centerColor = const Color(0xFFD84F9C),
    this.height = 80.0,
    this.centerButtonSize = 60.0,
  });
  
  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  bool _isHomeHovered = false;
  bool _isProfileHovered = false;
  
  @override
  Widget build(BuildContext context) {
    final centerButtonPosition = widget.height * 0.15;
    
    return SizedBox(
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
                      Icon(
                        Icons.home,
                        size: 24,
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
                      Icon(
                        Icons.person,
                        size: 24,
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
                    child: Icon(
                      Icons.train,
                      size: 30,
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