import 'package:flutter/material.dart';
import '../widgets/container_homepage.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/train_service.dart';
import '../models/kereta_model.dart';
import '../utils/route_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  late final TrainService _trainService;
  
  String _username = 'User';
  List<Map<String, dynamic>> _notifications = [];
  Kereta? _activeTrip;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _trainService = TrainService.instance; // Use singleton
    _initializeServices();
    _loadUserData();
    _loadActiveTrip();
    _loadNotifications();
  }

  void _initializeServices() {
    _notificationService.initialize();
    _trainService.startListeningToConductorUpdates();
    
    _notificationService.notificationStream.listen((notifications) {
      if (mounted) {
        setState(() {
          _notifications = notifications;
        });
      }
    });

    // Listen for active trip changes
    _trainService.activeTripStream.listen((trip) {
      if (mounted) {
        setState(() {
          _activeTrip = trip;
        });
      }
    });
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getUserData();
      if (userData != null && mounted) {
        setState(() {
          _username = userData['name'] ?? 'User';
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadActiveTrip() async {
    try {
      final trip = await _trainService.getActiveTrip();
      if (mounted) {
        setState(() {
          _activeTrip = trip;
        });
      }
    } catch (e) {
      print('Error loading active trip: $e');
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications = await _notificationService.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = notifications;
        });
      }
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  void _navigateToTrainCode() {
    RouteHelper.navigateToTrainCode(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F4F4),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFD84F9C),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F4),
      body: SafeArea(
        child: Column(
          children: [
            // Schedule Card dengan data aktif atau kosong
            ScheduleCard(
              username: _username,
              activeTrip: _activeTrip,
              onBookingPressed: _navigateToTrainCode,
            ),
            
            // Notifications Section
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 100), // Bottom padding untuk navbar
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (_notifications.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              _notificationService.clearAllNotifications();
                            },
                            child: const Text(
                              'Clear All',
                              style: TextStyle(
                                color: Color(0xFFD84F9C),
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Notifications List or Empty State
                    Expanded(
                      child: _notifications.isNotEmpty
                          ? ListView.separated(
                              itemCount: _notifications.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final notification = _notifications[index];
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: notification['isRead'] 
                                        ? Colors.white
                                        : const Color(0xFFFFF3F8),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: notification['isRead']
                                          ? Colors.grey.shade200
                                          : const Color(0xFFE91E63).withOpacity(0.2),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: notification['isRead']
                                              ? Colors.grey.shade400
                                              : const Color(0xFFE91E63),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              notification['title'] ?? '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: notification['isRead']
                                                    ? Colors.grey.shade700
                                                    : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              notification['message'] ?? '',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: notification['isRead']
                                                    ? Colors.grey.shade600
                                                    : Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        notification['time'] ?? '',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.notifications_off_outlined,
                                          size: 80,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'NO DATA',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'NO DATA',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE91E63),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Belum ada notifikasi perjalanan',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
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

  @override
  void dispose() {
    // Don't dispose the singleton service here
    _notificationService.dispose();
    super.dispose();
  }
}
