import 'package:flutter/material.dart';
import '../models/kereta_model.dart';

class ScheduleCard extends StatelessWidget {
  final Kereta kereta;

  const ScheduleCard({
    super.key,
    required this.kereta,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildScheduleBadge(),
        Spacer(),
        _buildTrainNameBadge(),
      ],
    );
  }

  Widget _buildScheduleBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE91E63), width: 1),
      ),
      child: Text(
        'Schedule ${kereta.jadwal}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFFE91E63),
        ),
      ),
    );
  }

  Widget _buildTrainNameBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE91E63), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildKAILogo(),
          SizedBox(width: 6),
          Text(
            kereta.nama,
            style: TextStyle(
              color: Color(0xFFE91E63),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKAILogo() {
    return Image.asset(
      'assets/images/kai_logo.png', // Path to your KAI logo
      width: 16,
      height: 16,
      errorBuilder: (context, error, stackTrace) {
        // Fallback if image not found
        return Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: Color(0xFFE91E63),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Center(
            child: Text(
              'KAI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 6,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}