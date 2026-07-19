import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/appointment.dart';
import '../models/doctor.dart';
import '../models/payment_model.dart';
import '../services/easypaisa_service.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';

class PaymentProvider with ChangeNotifier {
  final EasypaisaService _easypaisaService = EasypaisaService();
  final Uuid _uuid = const Uuid();

  bool _isLoading = false;
  String? _errorMessage;
  String? _transactionId;
  String? _paymentReference;
  double _amount = 0.0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get transactionId => _transactionId;
  String? get paymentReference => _paymentReference;
  double get amount => _amount;

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void resetState() {
    _isLoading = false;
    _errorMessage = null;
    _transactionId = null;
    _paymentReference = null;
    _amount = 0.0;
  }

  /// Processes the payment via Easypaisa Mobile Account (MA)
  /// and, if verified successfully, registers the appointment and payment record in Firestore.
  Future<Appointment?> processPayment({
    required String patientId,
    required String patientName,
    required String patientEmail,
    required Doctor doctor,
    required DateTime date,
    required String timeSlot,
    required double consultationFee,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    // Calculate total amount
    const double serviceFee = 5.0; // Standard service charge
    _amount = consultationFee + serviceFee;

    // Create a temporary reference for booking reference
    final String tempAppointmentId = _uuid.v4();

    try {
      // 1. Initiate payment request
      final paymentResult = await _easypaisaService.createPayment(
        appointmentId: tempAppointmentId,
        patientId: patientId,
        doctorId: doctor.id,
        amount: _amount,
        mobileNumber: '03001234567', // Will be gathered from input sheet
        email: patientEmail,
      );

      if (paymentResult['success'] != true) {
        _errorMessage = paymentResult['message'] ?? 'Payment initiation failed.';
        _setLoading(false);
        return null;
      }

      // Store response details
      _transactionId = paymentResult['transactionId'];
      _paymentReference = paymentResult['paymentReference'];

      // 2. Perform verification with the payment gateway
      final verificationResult = await _easypaisaService.verifyPayment(
        appointmentId: tempAppointmentId,
        transactionId: _transactionId!,
      );

      if (verificationResult['success'] != true) {
        _errorMessage = verificationResult['message'] ?? 'Payment verification failed.';
        _setLoading(false);
        return null;
      }

      // 3. Prepare Appointment details (e.g. queue position, estimated wait time, room assignment)
      final existingAppointments = await _getAppointmentsForDoctor(doctor.id, date);
      final int position = existingAppointments.length + 1;
      final int waitTime = position * 15; // 15 mins per patient
      
      final String docPrefix = doctor.name.split(' ').last.substring(0, 3).toUpperCase();
      final String token = '$docPrefix-${100 + position}';
      final String room = _assignRoom(doctor.id);

      final Appointment appointment = Appointment(
        id: tempAppointmentId,
        patientId: patientId,
        patientName: patientName,
        doctorId: doctor.id,
        doctorName: doctor.name,
        doctorImageUrl: doctor.imageUrl,
        doctorSpecialization: doctor.specialization,
        date: date,
        timeSlot: timeSlot,
        tokenNumber: token,
        queuePosition: position,
        estimatedWaitTime: waitTime,
        roomNumber: room,
        status: 'Pending',
        chatEnabled: false,
        createdAt: DateTime.now(),
        paymentStatus: 'Paid',
        paymentMethod: 'Easypaisa',
        transactionId: _transactionId,
        paymentReference: _paymentReference,
        amountPaid: _amount,
        bookingStatus: 'Paid',
      );

      // Create payment model
      final PaymentModel payment = PaymentModel(
        paymentId: _uuid.v4(),
        appointmentId: tempAppointmentId,
        patientId: patientId,
        doctorId: doctor.id,
        amount: _amount,
        transactionId: _transactionId!,
        paymentMethod: 'Easypaisa',
        paymentStatus: 'Paid',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save both to Firestore securely
      await FirebaseService.setDocument(
        collection: 'appointments',
        docId: tempAppointmentId,
        data: appointment.toMap(),
      );

      await FirebaseService.setDocument(
        collection: 'payments',
        docId: payment.paymentId,
        data: payment.toMap(),
      );

      // Create user notification
      await NotificationService.addNotification(
        title: 'Appointment Confirmed & Paid',
        body: 'Paid PKR ${_amount.toStringAsFixed(2)} for appointment with ${doctor.name} on ${date.day}/${date.month}/${date.year}',
        type: 'appointment',
        userId: patientId,
      );

      _setLoading(false);
      return appointment;

    } catch (e) {
      print('[PaymentProvider] Payment error: $e');
      _errorMessage = 'An unexpected error occurred: ${e.toString()}';
      _setLoading(false);
      return null;
    }
  }

  // Helper method to simulate fetch of existing appointments for queue counting
  Future<List<Map<String, dynamic>>> _getAppointmentsForDoctor(
    String doctorId,
    DateTime date,
  ) async {
    try {
      final formattedDate = date.toIso8601String().split('T')[0];
      final snapshot = await FirebaseService.firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      return snapshot.docs
          .map((doc) => doc.data())
          .where((data) => (data['date'] as String).startsWith(formattedDate))
          .toList();
    } catch (e) {
      print('Error getting existing appointments for count: $e');
      return [];
    }
  }

  // Room assignment logic helper
  String _assignRoom(String doctorId) {
    final int hash = doctorId.hashCode.abs();
    final int roomNumber = 101 + (hash % 15);
    return 'Room $roomNumber';
  }
}
