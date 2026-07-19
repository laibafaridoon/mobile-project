import 'package:uuid/uuid.dart';
import '../models/appointment.dart';
import '../models/doctor.dart';
import 'firebase_service.dart';
import 'notification_service.dart';

class AppointmentService {
  static const uuid = Uuid();
  static void Function(Appointment updatedAppointment)? _onAppointmentUpdated;

  static set onAppointmentUpdated(
    void Function(Appointment updatedAppointment)? callback,
  ) {
    _onAppointmentUpdated = callback;
  }

  // Book appointment
  static Future<Appointment> bookAppointment({
    required String patientId,
    required String patientName,
    required Doctor doctor,
    required DateTime date,
    required String timeSlot,
    required String doctorId,
    required String doctorName,
    required String doctorImageUrl,
    required DateTime appointmentDate,
    required String doctorSpecialization,
  }) async {
    try {
      // Calculate queue position
      final existingAppointments = await _getAppointmentsForDoctor(
        doctor.id,
        date,
      );

      final position = existingAppointments.length + 1;
      final waitTime = position * 15; // 15 mins per patient

      // Generate token
      final docPrefix = doctor.name
          .split(' ')
          .last
          .substring(0, 3)
          .toUpperCase();
      final token = '$docPrefix-${100 + position}';

      // Assign room
      final room = _assignRoom(doctor.id);

      // Create appointment
      final appointmentId = uuid.v4();
      final appointment = Appointment(
        id: appointmentId,
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
      );

      // Save to Firestore
      await FirebaseService.setDocument(
        collection: 'appointments',
        docId: appointmentId,
        data: appointment.toMap(),
      );

      _onAppointmentUpdated?.call(appointment);

      // Create notification
      await NotificationService.addNotification(
        title: 'Appointment Booked',
        body:
            'Appointment with ${doctor.name} on ${_formatDate(date)} at $timeSlot',
        type: 'appointment',
        userId: patientId,
      );

      return appointment;
    } catch (e) {
      print('[AppointmentService] Book Error: $e');
      rethrow;
    }
  }

  // Get user's appointments
  static Future<List<Appointment>> getUserAppointments(String userId) async {
    try {
      final query = await FirebaseService.queryCollection(
        collection: 'appointments',
        field: 'patientId',
        value: userId,
      );

      return query.docs
          .map(
            (doc) =>
                Appointment.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      print('[AppointmentService] Get User Appointments Error: $e');
      return [];
    }
  }

  // Get doctor's appointments for a specific date
  static Future<List<Appointment>> _getAppointmentsForDoctor(
    String doctorId,
    DateTime date,
  ) async {
    try {
      final query = await FirebaseService.queryCollection(
        collection: 'appointments',
        field: 'doctorId',
        value: doctorId,
      );

      return query.docs
          .map(
            (doc) =>
                Appointment.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .where(
            (apt) =>
                apt.date.year == date.year &&
                apt.date.month == date.month &&
                apt.date.day == date.day &&
                (apt.status == 'Pending' ||
                    apt.status == 'Confirmed' ||
                    apt.status == 'Waiting' ||
                    apt.status == 'In Progress'),
          )
          .toList();
    } catch (e) {
      print('[AppointmentService] Get Doctor Appointments Error: $e');
      return [];
    }
  }

  // Reschedule appointment
  static Future<Appointment?> rescheduleAppointment(
    String appointmentId,
    DateTime newDate,
    String newSlot,
  ) async {
    try {
      final aptDoc = await FirebaseService.getDocument(
        collection: 'appointments',
        docId: appointmentId,
      );

      if (!aptDoc.exists) return null;

      final appointment = Appointment.fromMap(
        aptDoc.data()! as Map<String, dynamic>,
        appointmentId,
      );
      final updated = appointment.copyWith(
        date: newDate,
        timeSlot: newSlot,
        status: 'Pending',
      );

      await FirebaseService.updateDocument(
        collection: 'appointments',
        docId: appointmentId,
        data: updated.toMap(),
      );

      await NotificationService.addNotification(
        title: 'Appointment Rescheduled',
        body: 'Your appointment with ${appointment.doctorName} rescheduled',
        type: 'appointment',
        userId: appointment.patientId,
      );

      return updated;
    } catch (e) {
      print('[AppointmentService] Reschedule Error: $e');
      return null;
    }
  }

  // Cancel appointment
  static Future<bool> cancelAppointment(String appointmentId) async {
    try {
      final aptDoc = await FirebaseService.getDocument(
        collection: 'appointments',
        docId: appointmentId,
      );

      if (!aptDoc.exists) return false;

      final appointment = Appointment.fromMap(
        aptDoc.data()! as Map<String, dynamic>,
        appointmentId,
      );

      await FirebaseService.updateDocument(
        collection: 'appointments',
        docId: appointmentId,
        data: {'status': 'Cancelled'},
      );

      await NotificationService.addNotification(
        title: 'Appointment Cancelled',
        body: 'Your appointment with ${appointment.doctorName} was cancelled',
        type: 'appointment',
        userId: appointment.patientId,
      );

      return true;
    } catch (e) {
      print('[AppointmentService] Cancel Error: $e');
      return false;
    }
  }

  // Enable chat for confirmed appointment
  static Future<bool> enableChat(String appointmentId) async {
    try {
      await FirebaseService.updateDocument(
        collection: 'appointments',
        docId: appointmentId,
        data: {'chatEnabled': true},
      );
      return true;
    } catch (e) {
      print('[AppointmentService] Enable Chat Error: $e');
      return false;
    }
  }

  // Update appointment status (admin)
  static Future<bool> updateStatus(
    String appointmentId,
    String newStatus,
  ) async {
    try {
      final aptDoc = await FirebaseService.getDocument(
        collection: 'appointments',
        docId: appointmentId,
      );

      if (!aptDoc.exists) return false;

      final appointment = Appointment.fromMap(
        aptDoc.data()! as Map<String, dynamic>,
        appointmentId,
      );

      await FirebaseService.updateDocument(
        collection: 'appointments',
        docId: appointmentId,
        data: {'status': newStatus},
      );

      _onAppointmentUpdated?.call(appointment);

      // Create notification for status change
      String? title;
      String? body;
      if (newStatus == 'Confirmed') {
        title = 'Appointment Confirmed';
        body =
            'Your appointment with ${appointment.doctorName} is confirmed for ${_formatDate(appointment.date)} at ${appointment.timeSlot}';
      } else if (newStatus == 'Your Turn Next') {
        title = 'You\'re Next!';
        body =
            'You are next for ${appointment.doctorName} at ${appointment.roomNumber}';
      } else if (newStatus == 'In Progress') {
        title = 'Consultation Started';
        body =
            'Dr. ${appointment.doctorName} is ready for you at ${appointment.roomNumber}';
      } else if (newStatus == 'Completed') {
        title = 'Consultation Completed';
        body = 'Your consultation with ${appointment.doctorName} is complete';
        // Enable chat after completed
        await enableChat(appointmentId);
      }

      if (title != null && body != null) {
        await NotificationService.addNotification(
          title: title,
          body: body,
          type: 'queue',
          userId: appointment.patientId,
        );
      }

      return true;
    } catch (e) {
      print('[AppointmentService] Update Status Error: $e');
      return false;
    }
  }

  // Listen to appointments
  static Stream<List<Appointment>> listenToUserAppointments(String userId) {
    return FirebaseService.listenToQuery(
      collection: 'appointments',
      field: 'patientId',
      value: userId,
    ).map((snapshot) {
      return snapshot.docs
          .map(
            (doc) =>
                Appointment.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    });
  }

  // Helper methods
  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String _assignRoom(String doctorId) {
    final roomMap = {
      'doc_1': 'Room 305 (Cardiology)',
      'doc_2': 'Room 110 (Pediatrics)',
      'doc_3': 'Room 204 (Dermatology)',
      'doc_4': 'Room 408 (Neurology)',
      'doc_5': 'Room 102 (General)',
    };
    return roomMap[doctorId] ?? 'Room 101';
  }

  Future<void> updateAppointmentStatus(String id, String status) async {
    await AppointmentService.updateStatus(id, status);
  }

  static List<Appointment> getRawAppointments() {
    return [];
  }

  Future<Appointment?> getAppointmentById(String appointmentId) async {
    try {
      final doc = await FirebaseService.getDocument(
        collection: 'appointments',
        docId: appointmentId,
      );
      if (!doc.exists) return null;
      return Appointment.fromMap(doc.data()! as Map<String, dynamic>, doc.id);
    } catch (e) {
      print('[AppointmentService] Get appointment by ID error: $e');
      return null;
    }
  }

  // Real-time listener for doctor's appointments
  static Stream<List<Appointment>> listenToDoctorAppointments(String doctorId) {
    return FirebaseService.firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Appointment.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Accept appointment (Doctor Dashboard action)
  static Future<bool> acceptAppointment(String appointmentId) async {
    try {
      final aptDoc = await FirebaseService.getDocument(
        collection: 'appointments',
        docId: appointmentId,
      );

      if (!aptDoc.exists) return false;

      final appointment = Appointment.fromMap(
        aptDoc.data()! as Map<String, dynamic>,
        appointmentId,
      );

      final docId = appointment.doctorId;
      final docRef = await FirebaseService.getDocument(collection: 'doctors', docId: docId);
      Doctor doctor;
      if (docRef.exists) {
        doctor = Doctor.fromMap(docRef.data()! as Map<String, dynamic>, docId);
      } else {
        doctor = Doctor(
          id: docId,
          name: appointment.doctorName,
          imageUrl: appointment.doctorImageUrl,
          specialization: appointment.doctorSpecialization,
          qualification: '',
          experience: 0,
          hospitalName: '',
          consultationFee: 0,
          rating: 5.0,
          reviewsCount: 1,
          availableDays: [],
          availableTimeSlots: [],
          contactInfo: '',
        );
      }

      final existingAppointments = await _getAppointmentsForDoctor(
        docId,
        appointment.date,
      );

      final position = existingAppointments.length + 1;
      final waitTime = position * 15;

      final lastWord = doctor.name.split(' ').last;
      final docPrefix = lastWord.substring(0, lastWord.length >= 3 ? 3 : lastWord.length).toUpperCase();
      final token = '$docPrefix-${100 + position}';
      final room = _assignRoom(docId);

      await FirebaseService.updateDocument(
        collection: 'appointments',
        docId: appointmentId,
        data: {
          'status': 'Confirmed',
          'tokenNumber': token,
          'queuePosition': position,
          'estimatedWaitTime': waitTime,
          'roomNumber': room,
        },
      );

      await NotificationService.addNotification(
        title: 'Appointment Confirmed',
        body: 'Dr. ${appointment.doctorName} has confirmed your appointment. Token: $token, Room: $room.',
        type: 'queue',
        userId: appointment.patientId,
      );

      return true;
    } catch (e) {
      print('[AppointmentService] Accept Error: $e');
      return false;
    }
  }

  // Reject appointment (Doctor Dashboard action)
  static Future<bool> rejectAppointment(String appointmentId) async {
    try {
      final aptDoc = await FirebaseService.getDocument(
        collection: 'appointments',
        docId: appointmentId,
      );

      if (!aptDoc.exists) return false;

      final appointment = Appointment.fromMap(
        aptDoc.data()! as Map<String, dynamic>,
        appointmentId,
      );

      await FirebaseService.updateDocument(
        collection: 'appointments',
        docId: appointmentId,
        data: {'status': 'Cancelled'},
      );

      await NotificationService.addNotification(
        title: 'Appointment Cancelled',
        body: 'Dr. ${appointment.doctorName} was unable to accept your request and cancelled it.',
        type: 'appointment',
        userId: appointment.patientId,
      );

      return true;
    } catch (e) {
      print('[AppointmentService] Reject Error: $e');
      return false;
    }
  }
}
