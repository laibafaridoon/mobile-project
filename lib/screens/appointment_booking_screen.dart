import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../models/doctor.dart';
import '../../providers/appointment_provider.dart';
import '../../routes/app_routes.dart';

class AppointmentBookingScreen extends StatelessWidget {
  final Doctor doctor;
  const AppointmentBookingScreen({super.key, required this.doctor});
  @override
  Widget build(BuildContext context) {
    final aptProvider = Provider.of<AppointmentProvider>(context);
    final selectedDateStr = aptProvider.selectedDate != null
        ? DateFormat('EEEE, dd MMMM yyyy').format(aptProvider.selectedDate!)
        : 'Select Date';
    final selectedSlotStr = aptProvider.selectedTimeSlot ?? 'Select Time Slot';
    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selected Doctor Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person, size: 48, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            doctor.specialization,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            doctor.hospitalName,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            // Step 1: Select Date Selector
            _buildSelectionTile(
              context,
              title: 'Select Date',
              subtitle: selectedDateStr,
              icon: Icons.calendar_today_rounded,
              isCompleted: aptProvider.selectedDate != null,
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.dateSelection),
            ),
            const SizedBox(height: 16),
            // Step 2: Select Time Slot Selector
            _buildSelectionTile(
              context,
              title: 'Select Time Slot',
              subtitle: selectedSlotStr,
              icon: Icons.access_time_rounded,
              isCompleted: aptProvider.selectedTimeSlot != null,
              onTap: () {
                if (aptProvider.selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a date first')),
                  );
                } else {
                  Navigator.pushNamed(context, AppRoutes.timeSlotSelection);
                }
              },
            ),
            const SizedBox(height: 28),
            // Patient Info Note
            Card(
              color: AppColors.primaryLight.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.border),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Important Queue Notice',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Your queue position and estimated arrival time will be calculated dynamically based on real-time room progress.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Proceed Button
            ElevatedButton(
              onPressed:
                  (aptProvider.selectedDate == null ||
                      aptProvider.selectedTimeSlot == null)
                  ? null
                  : () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.appointmentConfirmation,
                      );
                    },
              child: const Text('Review & Confirm'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.primaryLight : AppColors.background,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isCompleted ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isCompleted ? AppColors.textPrimary : AppColors.textLight,
          ),
        ),
        trailing: Icon(
          isCompleted
              ? Icons.check_circle_rounded
              : Icons.chevron_right_rounded,
          color: isCompleted ? AppColors.primary : AppColors.textLight,
        ),
      ),
    );
  }
}
