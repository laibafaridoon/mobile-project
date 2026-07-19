import 'dart:async';

import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/firebase_service.dart';

class ChatProvider with ChangeNotifier {
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _messageSubscription;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Listen to messages for an appointment
  void listenToMessages(String appointmentId) {
    _setLoading(true);
    _messageSubscription?.cancel();

    _messageSubscription = FirebaseService.firestore
        .collection('messages')
        .where('appointmentId', isEqualTo: appointmentId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen(
          (snapshot) {
            _messages = snapshot.docs
                .map((doc) => Message.fromMap(doc.data(), doc.id))
                .toList();
            _setLoading(false);
            notifyListeners();
          },
          onError: (e) {
            _setError('Failed to load messages: $e');
            _setLoading(false);
          },
        );
  }

  // Send message
  Future<bool> sendMessage({
    required String appointmentId,
    required String senderUid,
    required String senderName,
    required String senderRole,
    required String content,
    String messageType = 'text',
    String? mediaUrl,
    Map<String, dynamic>? prescriptionData,
  }) async {
    try {
      _setLoading(true);
      await FirebaseService.addDocument(
        collection: 'messages',
        data: {
          'appointmentId': appointmentId,
          'senderUid': senderUid,
          'senderName': senderName,
          'senderRole': senderRole,
          'content': content,
          'messageType': messageType,
          'mediaUrl': mediaUrl,
          'isSeen': false,
          'prescriptionData': prescriptionData,
        },
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to send message: $e');
      _setLoading(false);
      return false;
    }
  }

  // Mark message as seen
  Future<void> markMessageAsSeen(String messageId) async {
    try {
      await FirebaseService.updateDocument(
        collection: 'messages',
        docId: messageId,
        data: {'isSeen': true},
      );
    } catch (e) {
      print('Failed to mark message as seen: $e');
    }
  }

  // Send prescription
  Future<bool> sendPrescription({
    required String appointmentId,
    required String doctorUid,
    required String doctorName,
    required String content,
    required List<Map<String, dynamic>> medicines,
  }) async {
    try {
      _setLoading(true);
      await FirebaseService.addDocument(
        collection: 'messages',
        data: {
          'appointmentId': appointmentId,
          'senderUid': doctorUid,
          'senderName': doctorName,
          'senderRole': 'doctor',
          'content': content,
          'messageType': 'prescription',
          'isSeen': false,
          'prescriptionData': {
            'medicines': medicines,
            'date': DateTime.now(),
          },
        },
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to send prescription: $e');
      _setLoading(false);
      return false;
    }
  }

  // Stop listening to messages
  void stopListening() {
    _messageSubscription?.cancel();
    _messages = [];
    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _setError(String? err) {
    _error = err;
    notifyListeners();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}
