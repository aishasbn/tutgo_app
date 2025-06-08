import 'package:flutter/material.dart';
import '../models/kereta_model.dart';

class StatusBadge extends StatelessWidget {
  final KeretaStatus status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _getStatusColor(),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _getStatusText(),
            style: TextStyle(
              color: _getStatusColor(),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case KeretaStatus.willArrive:
        return Colors.orange;
      case KeretaStatus.onRoute:
        return Colors.green;
      case KeretaStatus.finished:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (status) {
      case KeretaStatus.willArrive:
        return 'Akan Tiba';
      case KeretaStatus.onRoute:
        return 'Berjalan';
      case KeretaStatus.finished:
        return 'Selesai';
    }
  }
}
