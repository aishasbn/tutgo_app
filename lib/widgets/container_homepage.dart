import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {
  final String username;
  final VoidCallback onBookingPressed;

  const ScheduleCard({
    super.key,
    required this.username,
    required this.onBookingPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink[400],
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Row
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.orange[200],
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 10),
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Welcome, ',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: '$username!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Where are we going today?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 16),

          // Card Jadwal
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0D9),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title dan logo
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "TUTGO",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.pink,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "No Schedule",
                      style: TextStyle(
                        color: Colors.pink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // From Stasiun
                const Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.pink),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("From Stasiun",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("Unfilled", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                // To Stasiun
                const Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: Colors.pink),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("To Stasiun",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("Unfilled", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Tombol
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onBookingPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[400],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Input Code Booking",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
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
}
