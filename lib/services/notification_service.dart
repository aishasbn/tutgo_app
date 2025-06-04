import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  void initialize() {
    print('Notification service initialized');
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
}