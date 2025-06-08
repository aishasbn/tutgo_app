import 'package:flutter/material.dart';

class CarriageGrid extends StatelessWidget {
  final Map<String, int> carriageOccupancy;
  final String? userCarriage;
  final int? userSeatNumber;
  final bool hasConfirmedSeat;
  final VoidCallback onConfirmSeat;
  final Function(String, int) onOccupancyChanged;

  const CarriageGrid({
    super.key,
    required this.carriageOccupancy,
    required this.userCarriage,
    required this.userSeatNumber,
    required this.hasConfirmedSeat,
    required this.onConfirmSeat,
    required this.onOccupancyChanged,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Carriage Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16),
          
          // User seat info
          if (userCarriage != null && userSeatNumber != null)
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Color(0xFFFCE4EC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFFE91E63), width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.event_seat, color: Color(0xFFE91E63)),
                  SizedBox(width: 8),
                  Text(
                    'Your Seat: $userCarriage - ${userSeatNumber.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE91E63),
                    ),
                  ),
                  Spacer(),
                  if (!hasConfirmedSeat)
                    ElevatedButton(
                      onPressed: onConfirmSeat,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE91E63),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      ),
                      child: Text(
                        'Confirm',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  if (hasConfirmedSeat)
                    Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                ],
              ),
            ),
          
          // Carriage grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: carriageOccupancy.entries.map((entry) {
              return _buildCarriageItem(entry.key, entry.value);
            }).toList(),
          ),
          
          SizedBox(height: 16),
          
          // Information text
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Please be polite and patient while waiting. Prioritize passengers such as pregnant women and the elderly. The CA carriage is the head of the train. M refers to the cafeteria carriage. Carriages with code A (AA, AB, AC) are executive class.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[700],
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarriageItem(String code, int occupancy) {
    Color color = code == 'M' ? Color(0xFF4CAF50) : Color(0xFFE91E63);
    bool isUserCarriage = code == userCarriage;
    
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isUserCarriage ? color : color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: isUserCarriage ? 2 : 1),
          ),
          child: Center(
            child: Text(
              code,
              style: TextStyle(
                color: isUserCarriage ? Colors.white : color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(
          '$occupancy/30',
          style: TextStyle(
            fontSize: 8,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
} 
