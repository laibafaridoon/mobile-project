import 'dart:async';
import '../models/appointment.dart';
import 'appointment_service.dart';

class QueueService {
  // Global stream controller for real-time queue changes
  static final StreamController<List<Appointment>> _queueStreamController =
      StreamController<List<Appointment>>.broadcast();
  Stream<List<Appointment>> get queueStream => _queueStreamController.stream;
  QueueService() {
    // Register callback with appointment service to push updates down the stream
    AppointmentService.onAppointmentUpdated = (updatedApt) {
      triggerQueueUpdate();
    };
  }
  void triggerQueueUpdate() {
    final activeAppointments = AppointmentService.getRawAppointments()
        .where(
          (apt) =>
              apt.status == 'Waiting' ||
              apt.status == 'In Progress' ||
              apt.status == 'Your Turn Next',
        )
        .toList();
    _queueStreamController.add(activeAppointments);
  }

  // Get active queue statistics for a specific doctor
  Map<String, dynamic> getDoctorQueueStats(String doctorId) {
    final list = AppointmentService.getRawAppointments();
    final doctorQueue = list
        .where(
          (apt) =>
              apt.doctorId == doctorId &&
              (apt.status == 'Waiting' ||
                  apt.status == 'In Progress' ||
                  apt.status == 'Your Turn Next'),
        )
        .toList();
    // Sort by creation time to find who is being served
    doctorQueue.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    Appointment? serving;
    int waitingCount = 0;
    for (var apt in doctorQueue) {
      if (apt.status == 'In Progress') {
        serving = apt;
      } else if (apt.status == 'Waiting' || apt.status == 'Your Turn Next') {
        waitingCount++;
      }
    }
    // If nobody is marked In Progress, the oldest Waiting patient is next
    if (serving == null && doctorQueue.isNotEmpty) {
      serving = doctorQueue.firstWhere(
        (apt) => apt.status == 'Waiting' || apt.status == 'Your Turn Next',
        orElse: () => doctorQueue.first,
      );
    }
    return {
      'servingToken': serving?.tokenNumber ?? 'N/A',
      'waitingCount': waitingCount,
      'estimatedTime': waitingCount * 15,
      'roomNumber': serving?.roomNumber ?? 'Room 101',
    };
  }

  // Stream for tracking a specific patient's appointment status
  Stream<Appointment?> getAppointmentLiveStream(String appointmentId) async* {
    // Emit initial
    yield _getAppointmentById(appointmentId);
    // Watch for updates
    await for (final list in queueStream) {
      final found = list.firstWhere(
        (apt) => apt.id == appointmentId,
        orElse: () => _getAppointmentById(appointmentId) ?? list.first,
      );
      yield found;
    }
  }

  Appointment? _getAppointmentById(String id) {
    try {
      return AppointmentService.getRawAppointments().firstWhere(
        (apt) => apt.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  // Advance queue manually for simulation or via admin dashboard
  Future<void> advanceQueue(String doctorId) async {
    final list = AppointmentService.getRawAppointments();

    // Filter active for doctor
    final active = list
        .where(
          (apt) =>
              apt.doctorId == doctorId &&
              (apt.status == 'Waiting' ||
                  apt.status == 'In Progress' ||
                  apt.status == 'Your Turn Next'),
        )
        .toList();
    active.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    if (active.isEmpty) return;
    // Find the one current in progress
    final inProgressIndex = active.indexWhere(
      (apt) => apt.status == 'In Progress',
    );

    if (inProgressIndex != -1) {
      // Complete the current one
      AppointmentService.updateAppointmentStatus(
        active[inProgressIndex].id,
        'Completed',
      );

      // Let's set the next one to In Progress if exists
      if (active.length > inProgressIndex + 1) {
        AppointmentService.updateAppointmentStatus(
          active[inProgressIndex + 1].id,
          'In Progress',
        );

        // And set the one after that to Your Turn Next
        if (active.length > inProgressIndex + 2) {
          AppointmentService.updateAppointmentStatus(
            active[inProgressIndex + 2].id,
            'Your Turn Next',
          );
        }
      }
    } else {
      // If none is in progress, make the first one In Progress
      AppointmentService.updateAppointmentStatus(active[0].id, 'In Progress');
      if (active.length > 1) {
        AppointmentService.updateAppointmentStatus(
          active[1].id,
          'Your Turn Next',
        );
      }
    }

    // Dynamically recalculate estimated waiting times and positions
    _recalculatePositions(doctorId);

    triggerQueueUpdate();
  }

  void _recalculatePositions(String doctorId) {
    final list = AppointmentService.getRawAppointments();
    final active = list
        .where(
          (apt) =>
              apt.doctorId == doctorId &&
              (apt.status == 'Waiting' || apt.status == 'Your Turn Next'),
        )
        .toList();
    active.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    for (int i = 0; i < active.length; i++) {
      final aptIndex = list.indexWhere((apt) => apt.id == active[i].id);
      if (aptIndex != -1) {
        final currentPosition = i + 1;
        list[aptIndex] = list[aptIndex].copyWith(
          queuePosition: currentPosition,
          estimatedWaitTime: currentPosition * 15,
        );
      }
    }
  }
}
