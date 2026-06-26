import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/queue_service.dart';

class QueueProvider with ChangeNotifier {
  final QueueService _queueService = QueueService();
  List<Appointment> _activeQueue = [];
  bool _isLoading = false;
  List<Appointment> get activeQueue => _activeQueue;
  bool get isLoading => _isLoading;
  QueueProvider() {
    // Listen to real-time changes
    _queueService.queueStream.listen((updatedQueue) {
      _activeQueue = updatedQueue;
      notifyListeners();
    });

    // Trigger initial load
    _queueService.triggerQueueUpdate();
  }
  Stream<Appointment?> getAppointmentLiveStream(String appointmentId) {
    return _queueService.getAppointmentLiveStream(appointmentId);
  }

  Map<String, dynamic> getDoctorQueueStats(String doctorId) {
    return _queueService.getDoctorQueueStats(doctorId);
  }

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
}
