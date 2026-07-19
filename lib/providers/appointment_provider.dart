import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/appointment.dart';
import '../models/doctor.dart';
import '../services/appointment_service.dart';

class AppointmentProvider with ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService();

  List<Appointment> _userAppointments = [];
  List<Appointment> _allAppointments = [];
  Doctor? _selectedDoctor;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  bool _isLoading = false;
  String? _error;

  List<Appointment> get userAppointments => _userAppointments;
  List<Appointment> get allAppointments => _allAppointments;
  List<Appointment> get appointments => _allAppointments;
  List<Appointment> get activeAppointments => _allAppointments
      .where((appointment) => appointment.status != 'Cancelled')
      .toList();
  bool get isBookingReady =>
      _selectedDoctor != null &&
      _selectedDate != null &&
      _selectedTimeSlot != null;
  bool get isLoading => _isLoading;
  DateTime? get selectedDate => _selectedDate;
  String? get selectedTimeSlot => _selectedTimeSlot;
  Doctor? get selectedDoctor => _selectedDoctor;
  List<Appointment> get pastAppointments => _userAppointments
      .where(
        (appointment) =>
            appointment.status == 'Completed' ||
            appointment.status == 'Cancelled',
      )
      .toList();
  bool get hasError => _error != null;

  AppointmentProvider() {
    _initializeListener();
  }

  // Initialize real-time listener for user's appointments
  void _initializeListener() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      AppointmentService.listenToUserAppointments(userId).listen(
        (appointments) {
          _userAppointments = appointments;
          _allAppointments =
              appointments; // Sync with _allAppointments for dashboard
          _error = null;
          notifyListeners();
        },
        onError: (e) {
          _error = e.toString();
          notifyListeners();
        },
      );
    }
  }

  // Book appointment
  Future<bool> bookAppointment({
    required String doctorId,
    required String doctorName,
    required String doctorImageUrl,
    required String specialization,
    required DateTime appointmentDate,
    required String timeSlot,
  }) async {
    _setLoading(true);
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final userName = FirebaseAuth.instance.currentUser?.email ?? 'Patient';

      if (userId == null) throw Exception('User not authenticated');

      await AppointmentService.bookAppointment(
        patientId: userId,
        patientName: userName,
        doctorId: doctorId,
        doctorName: doctorName,
        doctor: Doctor(
          id: doctorId,
          name: doctorName,
          imageUrl: doctorImageUrl,
          specialization: specialization,
          qualification: '',
          experience: 0,
          hospitalName: '',
          consultationFee: 0,
          rating: 0.0,
          reviewsCount: 0,
          availableDays: [],
          availableTimeSlots: [],
          contactInfo: '',
        ),
        doctorImageUrl: doctorImageUrl,
        doctorSpecialization: specialization,
        appointmentDate: appointmentDate,
        date: appointmentDate,
        timeSlot: timeSlot,
      );

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get appointment by ID
  Future<Appointment?> getAppointment(String appointmentId) async {
    try {
      return await _appointmentService.getAppointmentById(appointmentId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Update appointment status
  Future<bool> updateAppointmentStatus(
    String appointmentId,
    String newStatus,
  ) async {
    _setLoading(true);
    try {
      await _appointmentService.updateAppointmentStatus(
        appointmentId,
        newStatus,
      );
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cancel appointment
  Future<bool> cancelAppointment(String appointmentId) async {
    _setLoading(true);
    try {
      await AppointmentService.cancelAppointment(appointmentId);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  Future<Appointment?> confirmAppointment() async {
    if (_selectedDoctor == null ||
        _selectedDate == null ||
        _selectedTimeSlot == null) {
      return null;
    }
    _setLoading(true);
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final userName = FirebaseAuth.instance.currentUser?.email ?? 'Patient';
      if (userId == null) throw Exception('User not authenticated');

      final appointment = await AppointmentService.bookAppointment(
        patientId: userId,
        patientName: userName,
        doctor: _selectedDoctor!,
        doctorId: _selectedDoctor!.id,
        doctorName: _selectedDoctor!.name,
        doctorImageUrl: _selectedDoctor!.imageUrl,
        doctorSpecialization: _selectedDoctor!.specialization,
        appointmentDate: _selectedDate!,
        date: _selectedDate!,
        timeSlot: _selectedTimeSlot!,
      );
      _error = null;
      notifyListeners();
      return appointment;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void setBookingDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void startBookingFlow(Doctor doctor) {
    _selectedDoctor = doctor;
    _selectedDate = null;
    _selectedTimeSlot = null;
    notifyListeners();
  }

  void loadAppointments() {
    _initializeListener();
  }

  void adminUpdateAppointmentStatus(String id, String val) {
    updateAppointmentStatus(id, val);
  }

  void setBookingTimeSlot(String slot) {
    _selectedTimeSlot = slot;
    notifyListeners();
  }

  List<Appointment> _doctorAppointments = [];
  List<Appointment> get doctorAppointments => _doctorAppointments;
  
  StreamSubscription<List<Appointment>>? _doctorAptsSubscription;

  void listenToDoctorAppointments(String doctorId) {
    _doctorAptsSubscription?.cancel();
    _doctorAptsSubscription = AppointmentService.listenToDoctorAppointments(doctorId).listen(
      (appointments) {
        _doctorAppointments = appointments;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> acceptAppointmentRequest(String appointmentId) async {
    _setLoading(true);
    try {
      final success = await AppointmentService.acceptAppointment(appointmentId);
      if (success) {
        _error = null;
        return true;
      }
      _error = 'Failed to accept appointment';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> rejectAppointmentRequest(String appointmentId) async {
    _setLoading(true);
    try {
      final success = await AppointmentService.rejectAppointment(appointmentId);
      if (success) {
        _error = null;
        return true;
      }
      _error = 'Failed to reject appointment';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    _doctorAptsSubscription?.cancel();
    super.dispose();
  }
}
