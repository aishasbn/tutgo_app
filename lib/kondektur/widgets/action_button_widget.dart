// lib/widgets/action_button_widget.dart
import 'package:flutter/material.dart';

class ActionButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // Make nullable to handle disabled state
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;
  final double height;
  final double borderRadius;

  const ActionButtonWidget({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.backgroundColor = const Color(0xFFD75A9E),
    this.textColor = Colors.white,
    this.height = 50.0,
    this.borderRadius = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed != null ? backgroundColor : Colors.grey.shade400,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}