import 'package:flutter/material.dart';
import '../models/kereta_model.dart';

class RouteCard extends StatelessWidget {
  final Kereta kereta;

  const RouteCard({
    super.key,
    required this.kereta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE91E63), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRouteIndicator(),
          SizedBox(width: 16),
          Expanded(
            child: _buildStationInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteIndicator() {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Color(0xFFFF8F00),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 2,
          height: 60,
          color: Colors.grey[300],
          margin: EdgeInsets.symmetric(vertical: 8),
        ),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Color(0xFFE91E63),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildStationInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStationItem(
          'From Stasiun',
          kereta.fromStasiun,
          Color(0xFFFF8F00),
        ),
        SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 1,
          color: Colors.grey[300],
        ),
        SizedBox(height: 12),
        _buildStationItem(
          'To Stasiun',
          kereta.toStasiun,
          Color(0xFFE91E63),
        ),
      ],
    );
  }

  Widget _buildStationItem(String label, String station, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 4),
        Text(
          station,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}