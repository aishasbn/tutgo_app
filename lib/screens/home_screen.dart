import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/container_homepage.dart';
import '../services/auth_service.dart';
import '../utils/route_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  String _username = "User";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data setiap kali widget di-build ulang
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final User? currentUser = _authService.currentUser;
      
      if (currentUser != null) {
        // Coba ambil data dari Firestore dulu
        final userData = await _authService.getUserData();
        
        if (userData != null && userData['name'] != null) {
          // Gunakan nama dari Firestore
          setState(() {
            _username = userData['name'];
            _isLoading = false;
          });
        } else {
          // Fallback ke Firebase Auth
          setState(() {
            _username = currentUser.displayName ?? 
                      currentUser.email?.split('@')[0] ?? 
                      "User";
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _username = "User";
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      // Fallback jika ada error
      final User? currentUser = _authService.currentUser;
      setState(() {
        _username = currentUser?.displayName ?? 
                   currentUser?.email?.split('@')[0] ?? 
                   "User";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Column(
          children: [
            ScheduleCard(
              username: _isLoading ? "Loading..." : _username,
              onBookingPressed: () {
                print("Booking code input clicked!");
                RouteHelper.navigateToTrainCode(context);
              },
            ),
            
            // Notifications Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Notifications",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // // Testing info section
                    // Container(
                    //   width: double.infinity,
                    //   padding: const EdgeInsets.all(16),
                    //   margin: const EdgeInsets.only(bottom: 20),
                    //   decoration: BoxDecoration(
                    //     color: Colors.pink[50],
                    //     borderRadius: BorderRadius.circular(12),
                    //     border: Border.all(
                    //       color: Colors.pink[200]!,
                    //     ),
                    //   ),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Row(
                    //         children: [
                    //           Icon(
                    //             Icons.info_outline,
                    //             color: Colors.pink[400],
                    //             size: 20,
                    //           ),
                    //           const SizedBox(width: 8),
                    //           Text(
                    //             'Kode Kereta untuk Testing:',
                    //             style: TextStyle(
                    //               fontWeight: FontWeight.bold,
                    //               color: Colors.pink[400],
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //       const SizedBox(height: 12),
                    //       _buildTrainCodeItem('SBY-JKT-001', 'Surabaya → Jakarta', 'Sedang Berjalan'),
                    //       _buildTrainCodeItem('JKT-SBY-001', 'Jakarta → Surabaya', 'Akan Tiba'),
                    //       _buildTrainCodeItem('MLG-JKT-001', 'Malang → Jakarta', 'Selesai'),
                    //       const SizedBox(height: 8),
                    //       const Text(
                    //         'Tap "Input Code Booking" untuk mencoba!',
                    //         style: TextStyle(
                    //           fontSize: 12,
                    //           color: Colors.grey,
                    //           fontStyle: FontStyle.italic,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    
                    // User info and notifications
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 200,
                              height: 200,
                              
                              child: Image.asset(
                              'assets/images/no_data.png',
                              width: 120, // atau sesuaikan
                              height: 120, 
                            ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "NO DATA",
                              style: TextStyle(
                                color: Color(0xFFD84F9C),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainCodeItem(String code, String route, String status) {
    Color statusColor;
    switch (status) {
      case 'Sedang Berjalan':
        statusColor = Colors.green;
        break;
      case 'Akan Tiba':
        statusColor = Colors.orange;
        break;
      case 'Selesai':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.blue;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.pink[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              code,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.pink[600],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              route,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 10,
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

