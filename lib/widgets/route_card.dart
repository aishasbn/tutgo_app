import 'package:flutter/material.dart';
import '../models/kereta_model.dart';

class RouteCard extends StatefulWidget {
  final Kereta kereta;

  const RouteCard({
    super.key,
    required this.kereta,
  });

  @override
  State<RouteCard> createState() => _RouteCardState();
}

class _RouteCardState extends State<RouteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(-1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
    
    // Start scrolling animation
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Train name and code with proper spacing
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Scrolling train name
                      SizedBox(
                        height: 24,
                        child: ClipRect(
                          child: SlideTransition(
                            position: _animation,
                            child: Text(
                              widget.kereta.nama,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8), // Added spacing
                      Text(
                        'Schedule: ${widget.kereta.jadwal}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.kereta.kode,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24), // Increased spacing

            // From station
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.pink[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.train,
                    color: Colors.pink[400],
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.kereta.fromStasiun,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Divider with arrow - improved spacing
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1.5,
                      color: Colors.grey[300],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.pink[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: Colors.pink[400],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1.5,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),

            // To station
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.pink[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: Colors.pink[400],
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'To',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.kereta.toStasiun,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (widget.kereta.arrivalCountdown != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'ETA: ${widget.kereta.arrivalCountdown}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Will Arrive status badge - moved to bottom right
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.blue[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Will Arrive',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
