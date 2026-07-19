import '../models/appointment.dart';
import 'firebase_service.dart';
import 'appointment_service.dart';

class QueueService {
  // -------------------------------------------------------
  // Active statuses — appointment queue mein tab tak rahe
  // jab tak Completed ya Cancelled na ho.
  // -------------------------------------------------------
  static const List<String> activeStatuses = [
    'Pending',
    'Confirmed',
    'Waiting',
    'Your Turn Next',
    'In Progress',
  ];

  // -------------------------------------------------------
  // Real-time stream for a single appointment (Firestore doc listener)
  // Yeh stream tab tak live update dega jab tak appointment
  // Completed ya Cancelled na ho jaaye.
  // -------------------------------------------------------
  Stream<Appointment?> getAppointmentLiveStream(String appointmentId) {
    return FirebaseService.listenToDocument(
      collection: 'appointments',
      docId: appointmentId,
    ).map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return Appointment.fromMap(
        snapshot.data()! as Map<String, dynamic>,
        snapshot.id,
      );
    });
  }

  // -------------------------------------------------------
  // Real-time stream of ALL active appointments for a doctor.
  // Includes Pending, Confirmed, Waiting, Your Turn Next, In Progress.
  // -------------------------------------------------------
  Stream<List<Appointment>> getDoctorActiveQueueStream(String doctorId) {
    return FirebaseService.firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map((snapshot) {
      final all = snapshot.docs
          .map((doc) => Appointment.fromMap(doc.data(), doc.id))
          .toList();

      // Sirf active appointments filter karo
      final active =
          all.where((apt) => activeStatuses.contains(apt.status)).toList();

      // Queue position ke mutabiq sort karo
      active.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return active;
    });
  }

  // -------------------------------------------------------
  // Real-time stream of ALL active appointments (all doctors).
  // Used by QueueProvider to keep a global in-memory list.
  // -------------------------------------------------------
  Stream<List<Appointment>> getAllActiveQueueStream() {
    return FirebaseService.firestore
        .collection('appointments')
        .snapshots()
        .map((snapshot) {
      final all = snapshot.docs
          .map((doc) => Appointment.fromMap(doc.data(), doc.id))
          .toList();

      return all
          .where((apt) => activeStatuses.contains(apt.status))
          .toList();
    });
  }

  // -------------------------------------------------------
  // Queue stats for a specific doctor (computed from live data).
  // -------------------------------------------------------
  Map<String, dynamic> getDoctorQueueStats(List<Appointment> activeQueue,
      String doctorId) {
    final doctorQueue =
        activeQueue.where((apt) => apt.doctorId == doctorId).toList();
    doctorQueue.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    Appointment? serving;
    int waitingCount = 0;

    for (var apt in doctorQueue) {
      if (apt.status == 'In Progress') {
        serving = apt;
      } else if (apt.status == 'Waiting' ||
          apt.status == 'Your Turn Next' ||
          apt.status == 'Confirmed' ||
          apt.status == 'Pending') {
        waitingCount++;
      }
    }

    // Agar koi In Progress nahi hai toh pehle wala Waiting/Confirmed patient
    if (serving == null && doctorQueue.isNotEmpty) {
      serving = doctorQueue.firstWhere(
        (apt) =>
            apt.status == 'In Progress' ||
            apt.status == 'Waiting' ||
            apt.status == 'Your Turn Next' ||
            apt.status == 'Confirmed',
        orElse: () => doctorQueue.first,
      );
    }

    return {
      'servingToken': serving?.tokenNumber.isNotEmpty == true
          ? serving!.tokenNumber
          : 'N/A',
      'waitingCount': waitingCount,
      'estimatedTime': waitingCount * 15,
      'roomNumber': serving?.roomNumber ?? 'Room 101',
    };
  }

  // -------------------------------------------------------
  // Advance queue — doctor ke liye next patient call karo.
  // Firestore mein directly update hoga, stream auto-update karega.
  // -------------------------------------------------------
  Future<void> advanceQueue(String doctorId) async {
    // Firestore se current active appointments fetch karo
    final snapshot = await FirebaseService.firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .get();

    final allApts = snapshot.docs
        .map((doc) => Appointment.fromMap(doc.data(), doc.id))
        .toList();

    final active = allApts
        .where((apt) =>
            apt.status == 'Waiting' ||
            apt.status == 'In Progress' ||
            apt.status == 'Your Turn Next' ||
            apt.status == 'Confirmed')
        .toList();

    active.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    if (active.isEmpty) return;

    final inProgressIndex =
        active.indexWhere((apt) => apt.status == 'In Progress');

    if (inProgressIndex != -1) {
      // Current In Progress ko Complete karo
      await AppointmentService.updateStatus(
          active[inProgressIndex].id, 'Completed');

      // Next wale ko In Progress karo
      if (active.length > inProgressIndex + 1) {
        await AppointmentService.updateStatus(
            active[inProgressIndex + 1].id, 'In Progress');

        // Uske baad wale ko Your Turn Next karo
        if (active.length > inProgressIndex + 2) {
          await AppointmentService.updateStatus(
              active[inProgressIndex + 2].id, 'Your Turn Next');
        }
      }
    } else {
      // Koi In Progress nahi — pehle wale ko In Progress karo
      await AppointmentService.updateStatus(active[0].id, 'In Progress');
      if (active.length > 1) {
        await AppointmentService.updateStatus(
            active[1].id, 'Your Turn Next');
      }
    }
  }
}
