import 'package:flutter/material.dart';
import 'avatar_widget.dart';

class WelcomeHeaderWidget extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final String? conductorId; // Added conductorId parameter

  const WelcomeHeaderWidget({
    super.key,
    required this.name,
    this.imageUrl,
    this.conductorId, // Optional parameter
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AvatarWidget(imageUrl: imageUrl),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Welcome, ',
                    style: TextStyle(
                      color: Color(0xFFFFBB54),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: name,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Show conductor ID if available
            if (conductorId != null)
              Text(
                'ID: $conductorId',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              )
            else
              Text(
                'Where are you going today?',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
