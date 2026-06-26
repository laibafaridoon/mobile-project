import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/appointment.dart';
import '../../providers/queue_provider.dart';

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
              child: Text('Appointment or active token not found.'),
            );
          }
          final stats = queueProvider.getDoctorQueueStats(appointment.doctorId);
          final servingToken = stats['servingToken'];

          // Calculate remaining patients
          // If status is completed or cancelled, remaining is 0
          int remainingTokens = appointment.queuePosition - 1;
          if (appointment.status == 'Completed' ||
              appointment.status == 'Cancelled') {
            remainingTokens = 0;
          } else if (appointment.status == 'In Progress') {
            remainingTokens = 0;
          }
          if (remainingTokens < 0) remainingTokens = 0;
          // Progress calculation
          double progress = 0.0;
          if (appointment.status == 'Completed') {
            progress = 1.0;
          } else if (appointment.status == 'In Progress') {
            progress = 0.85;
          } else if (appointment.status == 'Your Turn Next') {
            progress = 0.7;
          } else {
            // Waiting: scale progress based on position
            final initialPos = appointment.queuePosition;
            if (initialPos > 0) {
              progress = (10 - initialPos).clamp(1, 9) / 10.0;
            } else {
              progress = 0.1;
            }
          }
          Color statusColor = AppColors.waiting;
          if (appointment.status == 'In Progress') {
            statusColor = AppColors.inProgress;
          }
          if (appointment.status == 'Your Turn Next') {
            statusColor = AppColors.yourTurn;
          }
          if (appointment.status == 'Completed') {
            statusColor = AppColors.completed;
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Doctor Summary Header Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            appointment.doctorImageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment.doctorName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${appointment.doctorSpecialization} • ${appointment.roomNumber}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            appointment.status,
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
                ),
                const SizedBox(height: 24),
                // Live Tracker Widget Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Text(
                          'CURRENTLY SERVING',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          servingToken,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Live Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 12,
                            color: AppColors.primary,
                            backgroundColor: AppColors.primaryLight,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Stats Grid Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildTrackerStat(
                              'Your Token',
                              appointment.tokenNumber,
                              color: AppColors.primary,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: AppColors.border,
                            ),
                            _buildTrackerStat(
                              'Tokens Ahead',
                              appointment.status == 'Completed'
                                  ? '0'
                                  : '$remainingTokens',
                              color: Colors.deepOrange.shade600,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: AppColors.border,
                            ),
                            _buildTrackerStat(
                              'Est. Wait',
                              appointment.status == 'Completed'
                                  ? '0 min'
                                  : '${appointment.estimatedWaitTime} min',
                              color: Colors.amber.shade800,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Map/Wing Info Details Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location Details',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            Icon(
                              Icons.door_sliding_outlined,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Room Wing:',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '2nd Floor, Wing B',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.textPrimary,
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
                              'Queue Alerts:',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                appointment.status == 'Completed'
                                    ? 'Completed'
                                    : 'Alerts active at 30m, 15m, 5m',
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
                ),
                const SizedBox(height: 32),
                // Simulation controls (for demonstrating live updates)
                if (appointment.status != 'Completed' &&
                    appointment.status != 'Cancelled') ...[
                  ElevatedButton(
                    onPressed: () {
                      queueProvider.advanceQueue(appointment.doctorId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.skip_next_rounded, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Simulate Call Next Patient'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '*This simulation button advances the doctor\'s queue ticket and triggers real-time UI/notification updates immediately.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textLight,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrackerStat(String label, String value, {required Color color}) {
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
}
