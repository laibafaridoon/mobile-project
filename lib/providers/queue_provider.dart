import 'package:flutter/material.dart';
import 'dart:async';
import '../models/appointment.dart';
import '../services/queue_service.dart';

class QueueProvider with ChangeNotifier {
  final QueueService _queueService = QueueService();

  // Global live list of all active appointments from Firestore
  List<Appointment> _activeQueue = [];
  bool _isLoading = false;

  List<Appointment> get activeQueue => _activeQueue;
  bool get isLoading => _isLoading;

  StreamSubscription<List<Appointment>>? _queueSubscription;

  QueueProvider() {
    _startGlobalQueueListener();
  }

  // -------------------------------------------------------
  // Firestore real-time global queue listener
  // -------------------------------------------------------
  void _startGlobalQueueListener() {
    _queueSubscription?.cancel();
    _queueSubscription =
        _queueService.getAllActiveQueueStream().listen((updatedQueue) {
      _activeQueue = updatedQueue;
      notifyListeners();
    }, onError: (e) {
      debugPrint('[QueueProvider] Stream error: $e');
    });
  }

  // -------------------------------------------------------
  // Real-time stream for a single appointment (Firestore doc)
  // -------------------------------------------------------
  Stream<Appointment?> getAppointmentLiveStream(String appointmentId) {
    return _queueService.getAppointmentLiveStream(appointmentId);
  }

  // -------------------------------------------------------
  // Real-time stream for a doctor's active queue
  // -------------------------------------------------------
  Stream<List<Appointment>> getDoctorQueueStream(String doctorId) {
    return _queueService.getDoctorActiveQueueStream(doctorId);
  }

  // -------------------------------------------------------
  // Queue stats computed from in-memory active list
  // -------------------------------------------------------
  Map<String, dynamic> getDoctorQueueStats(String doctorId) {
    return _queueService.getDoctorQueueStats(_activeQueue, doctorId);
  }

  // -------------------------------------------------------
  // Advance queue (doctor calls next patient)
  // -------------------------------------------------------
  Future<void> advanceQueue(String doctorId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _queueService.advanceQueue(doctorId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _queueSubscription?.cancel();
    super.dispose();
  }
}
