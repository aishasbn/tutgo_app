// lib/widgets/avatar_widget.dart
import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final Color backgroundColor;

  const AvatarWidget({
    Key? key,
    this.imageUrl,
    this.size = 60.0,
    this.backgroundColor = const Color(0xFFFFBB54),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(size / 2),
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.person,
                  color: Colors.white,
                  size: size * 0.5,
                ),
              ),
            )
          : Icon(
              Icons.person,
              color: Colors.white,
              size: size * 0.5,
            ),
    );
  }
}