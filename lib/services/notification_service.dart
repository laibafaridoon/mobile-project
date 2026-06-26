import 'dart:async';
import '../models/notification.dart';

class NotificationService {
  static final List<AppNotification> _notifications = [
    AppNotification(
      id: 'notif_1',
      title: 'Welcome to Smart Hospital!',
      body:
          'Thank you for registering. You can now book appointments, track queues in real-time, and set medicine reminders.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      type: 'general',
      isRead: true,
    ),
    AppNotification(
      id: 'notif_2',
      title: 'Reminder: Evening Medicine',
      body: 'It is time to take Paracetamol (500mg) after food.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      type: 'medicine',
      isRead: false,
    ),
  ];
  static final StreamController<List<AppNotification>> _notifStreamController =
      StreamController<List<AppNotification>>.broadcast();
  Stream<List<AppNotification>> get notificationsStream =>
      _notifStreamController.stream;
  Future<List<AppNotification>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_notifications);
  }

  static void addNotification({
    required String title,
    required String body,
    required String type,
  }) {
    final notif = AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: type,
      isRead: false,
    );
    _notifications.insert(0, notif); // Insert at beginning (newest first)
    _notifStreamController.add(List.from(_notifications));
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _notifStreamController.add(List.from(_notifications));
    }
  }

  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _notifStreamController.add(List.from(_notifications));
  }

  Future<void> deleteNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    _notifStreamController.add(List.from(_notifications));
  }

  Future<void> clearAll() async {
    _notifications.clear();
    _notifStreamController.add(List.from(_notifications));
  }

  // Get active unread count
  int getUnreadCount() {
    return _notifications.where((n) => !n.isRead).length;
  }
}
