import 'dart:async';
import 'package:flutter/material.dart';
import '../kondektur/services/enhanced_route_service.dart';
import '../kondektur/models/route_models.dart';
import 'train_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final List<Map<String, dynamic>> _notifications = [];
  final StreamController<List<Map<String, dynamic>>> _notificationController = 
      StreamController<List<Map<String, dynamic>>>.broadcast();

  Stream<List<Map<String, dynamic>>> get notificationStream => 
      _notificationController.stream;

  void initialize() {
    // Listen to conductor station detection events
    EnhancedRouteService.stationDetectionStream.listen((stationEvent) {
      _handleStationEvent(stationEvent);
    });

    // Listen to route updates
    EnhancedRouteService.routeUpdateStream.listen((routeUpdate) {
      _handleRouteUpdate(routeUpdate);
    });
  }

  void _handleStationEvent(StationDetectionEvent event) {
    String message;
    String title;
    Color backgroundColor = Colors.blue;

    switch (event.eventType) {
      case StationEventType.approaching:
        title = 'Mendekati Stasiun';
        message = 'Kereta sedang mendekati ${event.stationName}';
        backgroundColor = Colors.orange;
        break;
      case StationEventType.arrived:
        title = 'Tiba di Stasiun';
        message = 'Kereta telah tiba di ${event.stationName}';
        backgroundColor = Colors.green;
        break;
      case StationEventType.departed:
        title = 'Berangkat dari Stasiun';
        message = 'Kereta telah berangkat dari ${event.stationName}';
        backgroundColor = Colors.blue;
        break;
      case StationEventType.routeCompleted:
        title = 'Perjalanan Selesai';
        message = 'Kereta telah sampai di tujuan akhir: ${event.stationName}';
        backgroundColor = Colors.purple;
        break;
    }

    // Add to notifications list
    _addNotification(title, message);

    // Show simple print notification (replace with actual toast if needed)
    print('📱 Notification: $title - $message');
  }

  void _handleRouteUpdate(RouteUpdate update) {
    // You can add logic here for position-based notifications
    // For example, notify when train is X minutes away from next station
  }

  void _addNotification(String title, String message) {
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'message': message,
      'time': _formatTime(DateTime.now()),
      'timestamp': DateTime.now(),
      'isRead': false,
    };

    _notifications.insert(0, notification); // Add to beginning
    
    // Keep only last 50 notifications
    if (_notifications.length > 50) {
      _notifications.removeRange(50, _notifications.length);
    }

    _notificationController.add(_notifications);
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    return _notifications;
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n['id'] == notificationId);
    if (index != -1) {
      _notifications[index]['isRead'] = true;
      _notificationController.add(_notifications);
    }
  }

  void clearAllNotifications() {
    _notifications.clear();
    _notificationController.add(_notifications);
  }

  // Add manual notification (for testing)
  void addTestNotification(String title, String message) {
    _addNotification(title, message);
  }

  void scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) {
    print('Scheduled notification $id: $title at $scheduledTime');
  }

  void showInstantNotification({
    required String title,
    required String body,
    required BuildContext context,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.notifications, color: Color(0xFFE91E63), size: 24),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(color: Color(0xFFE91E63)),
              ),
            ),
          ],
        );
      },
    );
  }

  void dispose() {
    _notificationController.close();
  }
}
