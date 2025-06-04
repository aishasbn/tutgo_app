import 'package:flutter/material.dart';

class CarriageInformation extends StatefulWidget {
  final Map<String, int> carriageOccupancy;
  final String? userCarriage;
  final int? userSeatNumber;
  final bool hasConfirmedSeat;
  final VoidCallback onConfirmSeat;
  final Function(String, int) onOccupancyChanged;

  const CarriageInformation({
    super.key,
    required this.carriageOccupancy,
    this.userCarriage,
    this.userSeatNumber,
    required this.hasConfirmedSeat,
    required this.onConfirmSeat,
    required this.onOccupancyChanged,
  });

  @override
  _CarriageInformationState createState() => _CarriageInformationState();
}

class _CarriageInformationState extends State<CarriageInformation> {
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
          if (widget.userCarriage != null && widget.userSeatNumber != null)
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
                    'Your Seat: ${widget.userCarriage} - ${widget.userSeatNumber.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE91E63),
                    ),
                  ),
                  Spacer(),
                  if (!widget.hasConfirmedSeat)
                    ElevatedButton(
                      onPressed: widget.onConfirmSeat,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE91E63),
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      ),
                      child: Text(
                        'Confirm',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  if (widget.hasConfirmedSeat)
                    Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                ],
              ),
            ),
          
          // Carriage grid - bentuk kotak dengan fitur tap untuk melihat seat
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: widget.carriageOccupancy.entries.map((entry) {
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
                    'Please be polite and patient while waiting. Prioritize passengers such as pregnant women and the elderly. The CA carriage is the head of the train. M refers to the cafeteria carriage. Carriages with code A (AA, AB, AC) are executive class. Tap on carriage to view seat layout.',
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
    bool isUserCarriage = code == widget.userCarriage;
    
    return GestureDetector(
      onTap: () => _showCarriageDetail(code, occupancy, 30),
      child: Column(
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
      ),
    );
  }

  void _showCarriageDetail(String code, int occupied, int total) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Carriage $code',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Occupied: $occupied/$total seats',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: code == 'M' 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant,
                          size: 64,
                          color: Color(0xFF4CAF50),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Cafeteria Carriage',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Food and beverages available',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildSeatGrid(code, occupied, total),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatGrid(String code, int occupied, int total) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seat Layout - View Only',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You can only view seat occupancy status',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: total,
              itemBuilder: (context, index) {
                bool isOccupied = index < occupied;
                bool isUserSeat = code == widget.userCarriage && (index + 1) == widget.userSeatNumber;
                
                return Container(
                  decoration: BoxDecoration(
                    color: isUserSeat 
                        ? Color(0xFFFF8F00)
                        : isOccupied 
                            ? Color(0xFFE91E63)
                            : Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(Color(0xFF4CAF50), 'Available'),
              _buildLegendItem(Color(0xFFE91E63), 'Occupied'),
              _buildLegendItem(Color(0xFFFF8F00), 'Your Seat'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}