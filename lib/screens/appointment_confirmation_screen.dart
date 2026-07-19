import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../providers/appointment_provider.dart';
import '../../routes/app_routes.dart';

class AppointmentConfirmationScreen extends StatelessWidget {
  const AppointmentConfirmationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final aptProvider = Provider.of<AppointmentProvider>(context);
    final doctor = aptProvider.selectedDoctor;
    final date = aptProvider.selectedDate;
    final slot = aptProvider.selectedTimeSlot;
    if (doctor == null || date == null || slot == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Error loading booking data. Please start booking again.',
          ),
        ),
      );
    }
    final dateStr = DateFormat('EEEE, dd MMMM yyyy').format(date);
    final fee = doctor.consultationFee;
    const serviceFee = 5.0; // dummy service charge
    final total = fee + serviceFee;
    void handleConfirm() {
      Navigator.pushNamed(context, AppRoutes.payment);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Review Confirmation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Details summary card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
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
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32, color: AppColors.border),

                    _buildConfirmationRow(
                      'Location',
                      doctor.hospitalName,
                      Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildConfirmationRow(
                      'Date',
                      dateStr,
                      Icons.calendar_today_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildConfirmationRow(
                      'Time',
                      slot,
                      Icons.access_time_rounded,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Billing breakdown card
            Text(
              'Billing Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildBillRow(
                      'Consultation Fee',
                      '\$${fee.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 8),
                    _buildBillRow('Platform Service Fee', '\$5.00'),
                    const Divider(height: 24, color: AppColors.border),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80), // bottom spacer
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ElevatedButton(
            onPressed: handleConfirm,
            child: const Text('Proceed to Payment'),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBillRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }
}
