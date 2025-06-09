// lib/widgets/profile_header_widget.dart
import 'package:flutter/material.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final String name;
  final String role;
  final String? imageUrl;

  const ProfileHeaderWidget({
    super.key,
    required this.name,
    required this.role,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFFFEB3B),
          ),
          child: imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.person,
                      color: Colors.black54,
                      size: 40,
                    ),
                  ),
                )
              : Icon(
                  Icons.person,
                  color: Colors.black54,
                  size: 40,
                ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          role,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}