import 'package:flutter/material.dart';
import '../models/kereta_model.dart';

class StatusBadge extends StatelessWidget {
  final Kereta kereta;

  const StatusBadge({
    super.key,
    required this.kereta,
  });

  @override
  Widget build(BuildContext context) {
    String text;
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    switch (kereta.status) {
      case KeretaStatus.willArrive:
        text = kereta.arrivalCountdown != null 
            ? 'Will Arrive in - ${kereta.arrivalCountdown}' 
            : 'Will Arrive';
        backgroundColor = Color(0xFFFFF3E0);
        textColor = Color(0xFFFF8F00);
        borderColor = Color(0xFFFF8F00);
        break;
      case KeretaStatus.onRoute:
        text = 'On Route';
        backgroundColor = Color(0xFFFCE4EC);
        textColor = Color(0xFFE91E63);
        borderColor = Color(0xFFE91E63);
        break;
      case KeretaStatus.finished:
        text = 'Finished';
        backgroundColor = Color(0xFFE8F5E8);
        textColor = Color(0xFF4CAF50);
        borderColor = Color(0xFF4CAF50);
        break;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}