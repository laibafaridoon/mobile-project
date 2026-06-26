import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../models/appointment.dart';
import '../../providers/appointment_provider.dart';
import '../../routes/app_routes.dart';

class TokenDetailScreen extends StatelessWidget {
  final Appointment appointment;
  const TokenDetailScreen({super.key, required this.appointment});
  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'EEEE, dd MMM yyyy',
    ).format(appointment.date);
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    // Dynamic color coding based on status
    Color statusColor = AppColors.waiting;
    if (appointment.status == 'In Progress') statusColor = AppColors.inProgress;
    if (appointment.status == 'Your Turn Next') {
      statusColor = AppColors.yourTurn;
    }
    if (appointment.status == 'Completed') statusColor = AppColors.completed;
    if (appointment.status == 'Cancelled') statusColor = AppColors.error;
    return Scaffold(
      appBar: AppBar(title: const Text('Token Ticket Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main Ticket Stub Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Doctor & Hospital Header Info
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                appointment.doctorImageUrl,
                                width: 64,
                                height: 64,
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
                                    appointment.doctorSpecialization,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    appointment.roomNumber,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Perforated line
                      Row(
                        children: List.generate(
                          20,
                          (i) => Expanded(
                            child: Container(
                              height: 1.5,
                              color: i % 2 == 0
                                  ? Colors.transparent
                                  : AppColors.border,
                            ),
                          ),
                        ),
                      ),
                      // Large Token Display
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 24.0,
                          horizontal: 16.0,
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'QUEUE TOKEN NUMBER',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textLight,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              appointment.tokenNumber,
                              style: const TextStyle(
                                fontSize: 44,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                appointment.status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // QR Code Mock
                      Container(
                        width: 140,
                        height: 140,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: _buildMockQRCode(),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Scan at Room entrance to check in',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textLight,
                        ),
                      ),

                      const SizedBox(height: 24),
                      // Bottom Stats Summary Wing
                      Container(
                        color: AppColors.primaryLight.withOpacity(0.3),
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildTicketStat(
                              'Position',
                              '#${appointment.queuePosition}',
                            ),
                            _buildTicketStat(
                              'Est. Wait',
                              '${appointment.estimatedWaitTime} min',
                            ),
                            _buildTicketStat('Time Slot', appointment.timeSlot),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Actions Buttons
            if (appointment.status != 'Completed' &&
                appointment.status != 'Cancelled') ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.liveQueue,
                    arguments: appointment.id,
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.rocket_launch_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text('Track Live Queue Progress'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  _showCancelDialog(
                    context,
                    appointmentProvider,
                    appointment.id,
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                child: const Text('Cancel Appointment'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTicketStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // Draw a premium mock QR code using basic shapes
  Widget _buildMockQRCode() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 25,
      itemBuilder: (context, index) {
        // Draw standard QR finder patterns in corners
        bool isCorner =
            (index == 0 ||
                index == 1 ||
                index == 5 ||
                index == 6) || // Top Left
            (index == 3 ||
                index == 4 ||
                index == 8 ||
                index == 9) || // Top Right
            (index == 20 ||
                index == 21 ||
                index == 15 ||
                index == 16); // Bottom Left
        bool isFilled = isCorner || (index % 3 == 0) || (index % 7 == 2);

        return Container(
          decoration: BoxDecoration(
            color: isFilled ? AppColors.textPrimary : Colors.white,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }

  void _showCancelDialog(
    BuildContext context,
    AppointmentProvider provider,
    String appointmentId,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Appointment'),
          content: const Text(
            'Are you sure you want to cancel this appointment? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Keep Appointment',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                provider.cancelAppointment(appointmentId);
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back from token detail
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Appointment cancelled successfully'),
                    backgroundColor: AppColors.error,
                  ),
                );
              },
              child: const Text(
                'Yes, Cancel',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
