import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../models/doctor.dart';
import '../services/appointment_service.dart';

class AppointmentProvider with ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService();
  List<Appointment> _appointments = [];
  bool _isLoading = false;
  // Booking Flow temporary state
  Doctor? _selectedDoctor;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;

  // Last successfully booked appointment
  Appointment? _lastBookedAppointment;
  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;
  Doctor? get selectedDoctor => _selectedDoctor;
  DateTime? get selectedDate => _selectedDate;
  String? get selectedTimeSlot => _selectedTimeSlot;
  Appointment? get lastBookedAppointment => _lastBookedAppointment;
  // Lists filtered by status
  List<Appointment> get activeAppointments =>
      _appointments
          .where(
            (apt) =>
                apt.status == 'Waiting' ||
                apt.status == 'In Progress' ||
                apt.status == 'Your Turn Next',
          )
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
  List<Appointment> get pastAppointments =>
      _appointments
          .where(
            (apt) => apt.status == 'Completed' || apt.status == 'Cancelled',
          )
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
  AppointmentProvider() {
    loadAppointments();
  }
  Future<void> loadAppointments() async {
    _setLoading(true);
    try {
      _appointments = await _appointmentService.getAppointments();
    } finally {
      _setLoading(false);
    }
  }

  void startBookingFlow(Doctor doctor) {
    _selectedDoctor = doctor;
    _selectedDate = null;
    _selectedTimeSlot = null;
    _lastBookedAppointment = null;
    notifyListeners();
  }

  void setBookingDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setBookingTimeSlot(String timeSlot) {
    _selectedTimeSlot = timeSlot;
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
      final newApt = await _appointmentService.bookAppointment(
        doctor: _selectedDoctor!,
        date: _selectedDate!,
        timeSlot: _selectedTimeSlot!,
      );

      _lastBookedAppointment = newApt;
      _appointments.add(newApt);

      // Reset flow
      _selectedDoctor = null;
      _selectedDate = null;
      _selectedTimeSlot = null;
      notifyListeners();
      return newApt;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    _setLoading(true);
    try {
      await _appointmentService.cancelAppointment(appointmentId);
      final index = _appointments.indexWhere((apt) => apt.id == appointmentId);
      if (index != -1) {
        _appointments[index] = _appointments[index].copyWith(
          status: 'Cancelled',
        );
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> rescheduleAppointment(
    String appointmentId,
    DateTime newDate,
    String newSlot,
  ) async {
    _setLoading(true);
    try {
      final updated = await _appointmentService.rescheduleAppointment(
        appointmentId,
        newDate,
        newSlot,
      );
      if (updated != null) {
        final index = _appointments.indexWhere(
          (apt) => apt.id == appointmentId,
        );
        if (index != -1) {
          _appointments[index] = updated;
        }
        notifyListeners();
      }
    } finally {
      _setLoading(false);
    }
  }

  // Admin access to update status
  void adminUpdateAppointmentStatus(String id, String status) {
    AppointmentService.updateAppointmentStatus(id, status);
    loadAppointments(); // reload list
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
