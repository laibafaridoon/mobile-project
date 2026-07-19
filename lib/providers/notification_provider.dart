import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  StreamSubscription? _streamSubscription;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _streamSubscription?.cancel();
        _streamSubscription = NotificationService.listenToNotifications(user.uid).listen((updatedNotifications) {
          _notifications = updatedNotifications;
          notifyListeners();
        });
      } else {
        _streamSubscription?.cancel();
        _notifications = [];
        notifyListeners();
      }
    });
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
    await NotificationService.markAsRead(id);
    // Local list is updated by the stream callback
  }

  Future<void> markAllAsRead() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await NotificationService.markAllAsRead(userId);
    }
  }

  Future<void> deleteNotification(String id) async {
    await NotificationService.deleteNotification(id);
  }

  Future<void> clearAll() async {
    await _notificationService.clearAll();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
