// lib/widgets/profile_info_item_widget.dart
import 'package:flutter/material.dart';

class ProfileInfoItemWidget extends StatelessWidget {
  final String label;
  final String value;
  final bool isEditable;
  final Function()? onTap;

  const ProfileInfoItemWidget({
    Key? key,
    required this.label,
    required this.value,
    this.isEditable = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Color(0xFFF8D7E6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (isEditable)
                Icon(
                  Icons.edit,
                  size: 18,
                  color: Colors.black54,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}