import 'dart:async';
import '../models/appointment.dart';
import '../models/doctor.dart';
import 'notification_service.dart';

class AppointmentService {
  static final List<Appointment> _appointments = [
    // Pre-populate some historical and mock active appointments
    Appointment(
      id: 'apt_past_1',
      doctorId: 'doc_1',
      doctorName: 'Dr. Sarah Jenkins',
      doctorImageUrl:
          'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=300',
      doctorSpecialization: 'Cardiology',
      date: DateTime.now().subtract(const Duration(days: 3)),
      timeSlot: '09:00 AM',
      tokenNumber: 'TK-101',
      queuePosition: 0,
      estimatedWaitTime: 0,
      roomNumber: 'Room 305',
      status: 'Completed',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    Appointment(
      id: 'apt_past_2',
      doctorId: 'doc_5',
      doctorName: 'Dr. Clara Simmons',
      doctorImageUrl:
          'https://images.unsplash.com/photo-1527613426441-4da17471b66d?auto=format&fit=crop&q=80&w=300',
      doctorSpecialization: 'General Medicine',
      date: DateTime.now().subtract(const Duration(days: 1)),
      timeSlot: '11:00 AM',
      tokenNumber: 'TK-501',
      queuePosition: 0,
      estimatedWaitTime: 0,
      roomNumber: 'Room 102',
      status: 'Completed',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];
  // Callback to trigger notifications when queue advances
  static Function(Appointment)? onAppointmentUpdated;
  Future<List<Appointment>> getAppointments() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_appointments);
  }

  Future<Appointment> bookAppointment({
    required Doctor doctor,
    required DateTime date,
    required String timeSlot,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // Calculate queue position based on active appointments for this doctor on this day
    final existingForDoctor = _appointments
        .where(
          (apt) =>
              apt.doctorId == doctor.id &&
              apt.date.year == date.year &&
              apt.date.month == date.month &&
              apt.date.day == date.day &&
              (apt.status == 'Waiting' ||
                  apt.status == 'In Progress' ||
                  apt.status == 'Your Turn Next'),
        )
        .toList();
    final position = existingForDoctor.length + 1;
    final waitTime = position * 15; // 15 mins estimated per patient
    // Generate token: docPrefix + count
    final docPrefix = doctor.name.split(' ').last.substring(0, 3).toUpperCase();
    final token = '$docPrefix-${100 + position}';
    // Room numbers based on doctor ID
    final roomMap = {
      'doc_1': 'Room 305 (Cardiology Wing)',
      'doc_2': 'Room 110 (Pediatrics Wing)',
      'doc_3': 'Room 204 (Dermatology Wing)',
      'doc_4': 'Room 408 (Neurology Wing)',
      'doc_5': 'Room 102 (General Outpatient)',
    };
    final room = roomMap[doctor.id] ?? 'Room 101';
    final newAppointment = Appointment(
      id: 'apt_${DateTime.now().millisecondsSinceEpoch}',
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
      status: 'Waiting',
      createdAt: DateTime.now(),
    );
    _appointments.add(newAppointment);
    // Add a Notification automatically
    NotificationService.addNotification(
      title: 'Appointment Booked Successfully',
      body:
          'Your appointment with ${doctor.name} is confirmed for ${newAppointment.timeSlot} on ${_formatDate(date)}. Token: $token.',
      type: 'appointment',
    );
    return newAppointment;
  }

  Future<Appointment?> rescheduleAppointment(
    String id,
    DateTime newDate,
    String newSlot,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _appointments.indexWhere((apt) => apt.id == id);
    if (index == -1) return null;
    final existing = _appointments[index];
    final updated = existing.copyWith(
      date: newDate,
      timeSlot: newSlot,
      createdAt: DateTime.now(),
    );
    _appointments[index] = updated;
    NotificationService.addNotification(
      title: 'Appointment Rescheduled',
      body:
          'Your appointment with ${existing.doctorName} was rescheduled to $newSlot on ${_formatDate(newDate)}.',
      type: 'appointment',
    );
    return updated;
  }

  Future<void> cancelAppointment(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _appointments.indexWhere((apt) => apt.id == id);
    if (index == -1) return;
    final existing = _appointments[index];
    _appointments[index] = existing.copyWith(status: 'Cancelled');
    NotificationService.addNotification(
      title: 'Appointment Cancelled',
      body:
          'Your appointment with ${existing.doctorName} was successfully cancelled.',
      type: 'appointment',
    );
  }

  // Admin Queue Actions
  static List<Appointment> getRawAppointments() => _appointments;
  static void updateAppointmentStatus(String id, String status) {
    final index = _appointments.indexWhere((apt) => apt.id == id);
    if (index != -1) {
      final old = _appointments[index];

      // Update queue positions of other patients if completing/cancelling
      final updated = old.copyWith(status: status);
      _appointments[index] = updated;
      if (onAppointmentUpdated != null) {
        onAppointmentUpdated!(updated);
      }
      // Add a notification for status change
      String title = 'Queue Update';
      String body = '';
      if (status == 'In Progress') {
        body =
            '${old.doctorName} is ready for you. Please proceed near the door.';
      } else if (status == 'Your Turn Next') {
        title = 'Your Turn Next!';
        body =
            'You are next in line for ${old.doctorName} at ${old.roomNumber}.';
      } else if (status == 'Completed') {
        body =
            'Your consultation with ${old.doctorName} is complete. Take care!';
      }
      if (body.isNotEmpty) {
        NotificationService.addNotification(
          title: title,
          body: body,
          type: 'queue',
        );
      }
    }
  }

  static void updateRoomNumber(String docId, String roomNumber) {
    for (int i = 0; i < _appointments.length; i++) {
      if (_appointments[i].doctorId == docId &&
          _appointments[i].status != 'Completed' &&
          _appointments[i].status != 'Cancelled') {
        _appointments[i] = _appointments[i].copyWith(roomNumber: roomNumber);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
