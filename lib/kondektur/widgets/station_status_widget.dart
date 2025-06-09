import 'package:flutter/material.dart';

class StationStatusWidget extends StatelessWidget {
  final String stationName;
  final bool isPassed;
  final bool isCurrent;
  final String? arrivalTime;
  final String? departureTime;
  final DateTime? actualArrivalTime;

  const StationStatusWidget({
    super.key,
    required this.stationName,
    this.isPassed = false,
    this.isCurrent = false,
    this.arrivalTime,
    this.departureTime,
    this.actualArrivalTime,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Status Indicator
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isPassed
                ? Color(0xFF4CAF50)
                : isCurrent
                    ? Color(0xFFD75A9E)
                    : Colors.grey.shade300,
            border: Border.all(
              color: isPassed
                  ? Color(0xFF4CAF50)
                  : isCurrent
                      ? Color(0xFFD75A9E)
                      : Colors.grey.shade400,
              width: 2,
            ),
          ),
          child: isPassed
              ? Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                )
              : isCurrent
                  ? Container(
                      margin: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    )
                  : null,
        ),
        
        const SizedBox(width: 12),
        
        // Station Info
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isPassed
                  ? Color(0xFFE8F5E9)
                  : isCurrent
                      ? Color(0xFFF8D7E6)
                      : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isPassed
                    ? Color(0xFF4CAF50).withOpacity(0.3)
                    : isCurrent
                        ? Color(0xFFD75A9E).withOpacity(0.3)
                        : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        stationName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isPassed
                              ? Color(0xFF4CAF50)
                              : isCurrent
                                  ? Color(0xFFD75A9E)
                                  : Colors.black87,
                        ),
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Color(0xFFD75A9E),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'NEXT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else if (isPassed)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'PASSED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Time Information
                Row(
                  children: [
                    if (arrivalTime != null) ...[
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Arrival: $arrivalTime',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (departureTime != null) ...[
                      Icon(
                        Icons.departure_board,
                        size: 14,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Departure: $departureTime',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ],
                ),
                
                // Actual arrival time if available
                if (actualArrivalTime != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: Color(0xFF4CAF50),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Passed at: ${_formatTime(actualArrivalTime!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
