import 'package:uuid/uuid.dart';
import '../models/notification.dart';
import 'firebase_service.dart';

class NotificationService {
  static const uuid = Uuid();
  static List<AppNotification> _cachedNotifications = [];

  Stream<List<AppNotification>> get notificationsStream => const Stream.empty();

  // Add notification to Firestore
  static Future<void> addNotification({
    required String title,
    required String body,
    required String type,
    required String userId,
  }) async {
    try {
      await FirebaseService.addDocument(
        collection: 'notifications',
        data: {
          'userId': userId,
          'title': title,
          'body': body,
          'type': type,
          'isRead': false,
          'timestamp': DateTime.now(),
        },
      );
      print('[NotificationService] ✓ Notification added: $title');
    } catch (e) {
      print('[NotificationService] ✗ Add Error: $e');
    }
  }

  // Get user notifications
  static Future<List<AppNotification>> getUserNotifications(
    String userId,
  ) async {
    try {
      final query = await FirebaseService.firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return query.docs
          .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('[NotificationService] Get Error: $e');
      return [];
    }
  }

  // Mark notification as read
  static Future<bool> markAsRead(String notificationId) async {
    try {
      await FirebaseService.updateDocument(
        collection: 'notifications',
        docId: notificationId,
        data: {'isRead': true},
      );
      return true;
    } catch (e) {
      print('[NotificationService] Mark Read Error: $e');
      return false;
    }
  }

  // Mark all as read
  static Future<bool> markAllAsRead(String userId) async {
    try {
      final query = await FirebaseService.firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in query.docs) {
        await FirebaseService.updateDocument(
          collection: 'notifications',
          docId: doc.id,
          data: {'isRead': true},
        );
      }
      return true;
    } catch (e) {
      print('[NotificationService] Mark All Read Error: $e');
      return false;
    }
  }

  // Delete notification
  static Future<bool> deleteNotification(String notificationId) async {
    try {
      await FirebaseService.deleteDocument(
        collection: 'notifications',
        docId: notificationId,
      );
      return true;
    } catch (e) {
      print('[NotificationService] Delete Error: $e');
      return false;
    }
  }

  // Listen to notifications in real-time
  static Stream<List<AppNotification>> listenToNotifications(String userId) {
    return FirebaseService.firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  // Get unread count
  static Future<int> getUnreadCount(String userId) async {
    try {
      final query = await FirebaseService.firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      return query.docs.length;
    } catch (e) {
      print('[NotificationService] Unread Count Error: $e');
      return 0;
    }
  }

  // Send medicine reminder
  static Future<void> sendMedicineReminder({
    required String userId,
    required String medicineName,
    required String dosage,
    required String time,
  }) async {
    try {
      await addNotification(
        title: 'Medicine Reminder',
        body: 'Take $medicineName ($dosage) at $time',
        type: 'medicine',
        userId: userId,
      );
    } catch (e) {
      print('[NotificationService] Send Reminder Error: $e');
    }
  }

  // Send queue update notification
  static Future<void> sendQueueUpdate({
    required String userId,
    required String doctorName,
    required String status,
    required String? details,
  }) async {
    try {
      String title = 'Queue Update';
      String body = '';

      switch (status) {
        case 'confirmed':
          title = 'Appointment Confirmed';
          body = 'Your appointment with $doctorName is confirmed. $details';
          break;
        case 'token':
          title = 'Token Generated';
          body = 'Token: $details for $doctorName';
          break;
        case 'next':
          title = 'You\'re Next!';
          body = 'You are next in line for $doctorName at $details';
          break;
        case 'progress':
          title = 'Consultation In Progress';
          body = '$doctorName is ready. Please proceed to $details';
          break;
        case 'completed':
          title = 'Consultation Completed';
          body =
              'Thank you for visiting. Chat with $doctorName is now enabled.';
          break;
      }

      await addNotification(
        title: title,
        body: body,
        type: 'queue',
        userId: userId,
      );
    } catch (e) {
      print('[NotificationService] Queue Update Error: $e');
    }
  }

  // Send appointment reminder (called by scheduler)
  static Future<void> sendAppointmentReminder({
    required String userId,
    required String doctorName,
    required String time,
    required String date,
  }) async {
    try {
      await addNotification(
        title: 'Appointment Reminder',
        body:
            'Your appointment with $doctorName is at $time on $date. Please arrive 10 minutes early.',
        type: 'appointment',
        userId: userId,
      );
    } catch (e) {
      print('[NotificationService] Appointment Reminder Error: $e');
    }
  }

  // Broadcast notification to doctor (for new chat message)
  static Future<void> notifyDoctor({
    required String doctorId,
    required String patientName,
    required String message,
  }) async {
    try {
      await addNotification(
        title: 'New Message from Patient',
        body: '$patientName: $message',
        type: 'message',
        userId: doctorId,
      );
    } catch (e) {
      print('[NotificationService] Notify Doctor Error: $e');
    }
  }

  // Broadcast notification to patient (for doctor message/prescription)
  static Future<void> notifyPatient({
    required String patientId,
    required String doctorName,
    required String message,
  }) async {
    try {
      await addNotification(
        title: 'Message from Dr. $doctorName',
        body: message,
        type: 'message',
        userId: patientId,
      );
    } catch (e) {
      print('[NotificationService] Notify Patient Error: $e');
    }
  }

  Future<List<AppNotification>> getNotifications() async {
    try {
      final userId = FirebaseService.auth.currentUser?.uid;
      if (userId == null) return [];
      return await getUserNotifications(userId);
    } catch (e) {
      print('[NotificationService] Get Notifications Error: $e');
      return [];
    }
  }

  Future<void> clearAll() async {
    try {
      final userId = FirebaseService.auth.currentUser?.uid;
      if (userId == null) return;
      final snap = await FirebaseService.firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();
      for (var doc in snap.docs) {
        await FirebaseService.deleteDocument(collection: 'notifications', docId: doc.id);
      }
    } catch (e) {
      print('[NotificationService] Clear All Error: $e');
    }
  }
}
