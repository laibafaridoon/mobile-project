import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../models/appointment.dart';
import '../providers/queue_provider.dart';

class LiveQueueScreen extends StatelessWidget {
  final String appointmentId;
  const LiveQueueScreen({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context) {
    final queueProvider = Provider.of<QueueProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Live Queue Tracking')),
      body: StreamBuilder<Appointment?>(
        stream: queueProvider.getAppointmentLiveStream(appointmentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final appointment = snapshot.data;
          if (appointment == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 56,
                    color: AppColors.textLight,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Appointment not found.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            );
          }

          // ─── Status-based variables ───────────────────────────────
          Color statusColor = _getStatusColor(appointment.status);
          double progress = _getProgress(appointment);
          String statusMessage = _getStatusMessage(appointment);
          IconData statusIcon = _getStatusIcon(appointment.status);
          bool isCompleted = appointment.status == 'Completed';
          bool isCancelled = appointment.status == 'Cancelled';
          bool isPending = appointment.status == 'Pending';

          // Queue stats from provider's in-memory list
          final stats = queueProvider.getDoctorQueueStats(appointment.doctorId);
          final servingToken = stats['servingToken'] ?? 'N/A';

          // Remaining tokens ahead
          int remaining = 0;
          if (!isCompleted && !isCancelled && !isPending) {
            remaining = (appointment.queuePosition - 1).clamp(0, 999);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Doctor Card ────────────────────────────────────
                _buildDoctorCard(appointment, statusColor),
                const SizedBox(height: 20),

                // ── Status Banner (Pending state) ─────────────────
                if (isPending) _buildPendingBanner(),

                // ── Status Banner (Cancelled) ─────────────────────
                if (isCancelled) _buildCancelledBanner(),

                // ── Live Tracker Card ──────────────────────────────
                if (!isCancelled)
                  _buildTrackerCard(
                    appointment: appointment,
                    servingToken: servingToken,
                    progress: progress,
                    statusColor: statusColor,
                    statusMessage: statusMessage,
                    statusIcon: statusIcon,
                    remaining: remaining,
                    isCompleted: isCompleted,
                    isPending: isPending,
                  ),
                const SizedBox(height: 20),

                // ── Location Details Card ──────────────────────────
                if (!isCancelled && !isPending) _buildLocationCard(appointment),

                // ── Completed Card ─────────────────────────────────
                if (isCompleted) ...[
                  const SizedBox(height: 16),
                  _buildCompletedCard(context),
                ],

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Doctor header card ──────────────────────────────────────────────
  Widget _buildDoctorCard(Appointment apt, Color statusColor) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: apt.doctorImageUrl.isNotEmpty
                  ? Image.network(
                      apt.doctorImageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _doctorAvatarFallback(),
                    )
                  : _doctorAvatarFallback(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    apt.doctorName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${apt.doctorSpecialization}${apt.roomNumber.isNotEmpty ? " • ${apt.roomNumber}" : ""}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                apt.status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _doctorAvatarFallback() {
    return Container(
      width: 60,
      height: 60,
      color: AppColors.primaryLight,
      child: const Icon(
        Icons.person_rounded,
        color: AppColors.primary,
        size: 32,
      ),
    );
  }

  // ── Pending banner ──────────────────────────────────────────────────
  Widget _buildPendingBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Request Sent — Awaiting Acceptance',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your appointment request has been sent to the doctor. You will receive a notification and a token number once the doctor accepts it.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.orange.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Cancelled banner ────────────────────────────────────────────────
  Widget _buildCancelledBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.cancel_outlined, color: AppColors.error, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Appointment Cancelled',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your appointment has been cancelled.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Main tracker card ───────────────────────────────────────────────
  Widget _buildTrackerCard({
    required Appointment appointment,
    required String servingToken,
    required double progress,
    required Color statusColor,
    required String statusMessage,
    required IconData statusIcon,
    required int remaining,
    required bool isCompleted,
    required bool isPending,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Status icon + message
            Icon(statusIcon, color: statusColor, size: 36),
            const SizedBox(height: 8),
            Text(
              statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            const Divider(height: 28, color: AppColors.border),

            // Currently Serving token
            if (!isPending) ...[
              const Text(
                'CURRENTLY SERVING',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                servingToken,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  color: statusColor,
                  backgroundColor: AppColors.primaryLight,
                ),
              ),
              const SizedBox(height: 24),

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(
                    'Your Token',
                    appointment.tokenNumber,
                    AppColors.primary,
                  ),
                  Container(width: 1, height: 40, color: AppColors.border),
                  _buildStat(
                    'Ahead',
                    isCompleted ? '0' : '$remaining',
                    Colors.deepOrange.shade600,
                  ),
                  Container(width: 1, height: 40, color: AppColors.border),
                  _buildStat(
                    'Est. Wait',
                    isCompleted
                        ? 'Done'
                        : '${appointment.estimatedWaitTime} min',
                    Colors.amber.shade800,
                  ),
                ],
              ),
            ] else ...[
              // Pending state — token not yet assigned
              const SizedBox(height: 8),
              const Text(
                'Token aur queue number will be assigned once the doctor accepts your appointment request.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Appointment Date',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${appointment.date.day}/${appointment.date.month}/${appointment.date.year} — ${appointment.timeSlot}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Location card ───────────────────────────────────────────────────
  Widget _buildLocationCard(Appointment apt) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Location Details',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.door_sliding_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Room:',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    apt.roomNumber.isNotEmpty
                        ? apt.roomNumber
                        : 'To be assigned',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.notifications_active_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Alerts:',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    apt.status == 'Completed'
                        ? 'Consultation complete!'
                        : 'Active at 30m, 15m, 5m',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Completed banner ────────────────────────────────────────────────
  Widget _buildCompletedCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            Colors.green.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 48),
          const SizedBox(height: 10),
          const Text(
            'Consultation Complete!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Appointment has been successfully completed. Thank you for using our service!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            label: const Text('Back to Home'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }

  // ── Stat widget ─────────────────────────────────────────────────────
  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange.shade700;
      case 'Confirmed':
        return Colors.blue.shade700;
      case 'Waiting':
        return AppColors.waiting;
      case 'In Progress':
        return AppColors.inProgress;
      case 'Your Turn Next':
        return AppColors.yourTurn;
      case 'Completed':
        return AppColors.completed;
      case 'Cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  double _getProgress(Appointment apt) {
    switch (apt.status) {
      case 'Completed':
        return 1.0;
      case 'In Progress':
        return 0.85;
      case 'Your Turn Next':
        return 0.7;
      case 'Waiting':
      case 'Confirmed':
        final pos = apt.queuePosition;
        if (pos > 0) {
          return (10 - pos).clamp(1, 9) / 10.0;
        }
        return 0.15;
      case 'Pending':
        return 0.05;
      default:
        return 0.0;
    }
  }

  String _getStatusMessage(Appointment apt) {
    switch (apt.status) {
      case 'Pending':
        return 'Waiting for doctor approval...';
      case 'Confirmed':
        return 'Appointment confirmed! You\'re in queue.';
      case 'Waiting':
        return 'In queue — please be near the waiting area.';
      case 'Your Turn Next':
        return '🔔 You\'re next! Please proceed to the room.';
      case 'In Progress':
        return '✅ Your consultation is in progress.';
      case 'Completed':
        return '🎉 Consultation completed successfully!';
      case 'Cancelled':
        return '❌ Appointment has been cancelled.';
      default:
        return apt.status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.pending_actions_rounded;
      case 'Confirmed':
        return Icons.event_available_rounded;
      case 'Waiting':
        return Icons.queue_rounded;
      case 'Your Turn Next':
        return Icons.notifications_active_rounded;
      case 'In Progress':
        return Icons.medical_services_rounded;
      case 'Completed':
        return Icons.check_circle_rounded;
      case 'Cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }
}
