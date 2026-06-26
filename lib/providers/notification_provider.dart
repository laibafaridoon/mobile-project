import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  NotificationProvider() {
    // Listen to real-time notification events
    _notificationService.notificationsStream.listen((updatedNotifications) {
      _notifications = updatedNotifications;
      notifyListeners();
    });
    // Initial load
    loadNotifications();
  }
  Future<void> loadNotifications() async {
    _setLoading(true);
    try {
      _notifications = await _notificationService.getNotifications();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markAsRead(String id) async {
    await _notificationService.markAsRead(id);
    // Local list is updated by the stream callback
  }

  Future<void> markAllAsRead() async {
    await _notificationService.markAllAsRead();
  }

  Future<void> deleteNotification(String id) async {
    await _notificationService.deleteNotification(id);
  }

  Future<void> clearAll() async {
    await _notificationService.clearAll();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
