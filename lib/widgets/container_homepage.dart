import 'package:flutter/material.dart';
import '../models/kereta_model.dart';

class ScheduleCard extends StatelessWidget {
  final String username;
  final Kereta? activeTrip;
  final VoidCallback onBookingPressed;

  const ScheduleCard({
    super.key,
    required this.username,
    this.activeTrip,
    required this.onBookingPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE91E63),
            Color(0xFFAD1457),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Row
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFB74D),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Welcome, ',
                          style: TextStyle(
                            color: Color(0xFFFFB74D),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: '$username!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Where are we going today?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 20),

            // Card Jadwal
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title dan Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "TUTGO",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE91E63),
                          fontSize: 20,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: activeTrip != null 
                              ? const Color(0xFFE8F5E8)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: activeTrip != null
                                ? Colors.green.shade200
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          activeTrip != null ? 'Active Trip' : 'No Schedule',
                          style: TextStyle(
                            color: activeTrip != null 
                                ? Colors.green.shade700
                                : Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // From Stasiun
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE91E63),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "From Stasiun",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activeTrip?.fromStasiun ?? "Unfilled",
                              style: TextStyle(
                                color: activeTrip != null 
                                    ? Colors.black54
                                    : Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Divider Line
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    height: 1,
                    color: Colors.grey.shade300,
                  ),
                  
                  // To Stasiun
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: activeTrip != null 
                              ? const Color(0xFFE91E63)
                              : Colors.grey.shade400,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "To Stasiun",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activeTrip?.toStasiun ?? "Unfilled",
                              style: TextStyle(
                                color: activeTrip != null 
                                    ? Colors.black54
                                    : Colors.grey.shade500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Tombol
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: activeTrip == null ? onBookingPressed : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: activeTrip == null 
                            ? const Color(0xFFE91E63)
                            : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        activeTrip == null 
                            ? "Input Code Booking"
                            : "Trip Active",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
