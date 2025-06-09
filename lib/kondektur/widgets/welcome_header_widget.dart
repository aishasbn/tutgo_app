// lib/widgets/welcome_header_widget.dart
import 'package:flutter/material.dart';
import 'avatar_widget.dart';

class WelcomeHeaderWidget extends StatelessWidget {
  final String name;
  final String? imageUrl;

  const WelcomeHeaderWidget({
    Key? key,
    required this.name,
    this.imageUrl,
  }) : super(key: key);

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