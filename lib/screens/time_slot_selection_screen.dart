import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/appointment_provider.dart';

class TimeSlotSelectionScreen extends StatelessWidget {
  const TimeSlotSelectionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final aptProvider = Provider.of<AppointmentProvider>(context);
    // Default slots split by period
    final morningSlots = [
      '09:00 AM',
      '09:30 AM',
      '10:00 AM',
      '10:30 AM',
      '11:00 AM',
      '11:30 AM',
    ];
    final afternoonSlots = [
      '01:00 PM',
      '02:00 PM',
      '02:30 PM',
      '03:00 PM',
      '03:30 PM',
      '04:00 PM',
      '04:30 PM',
    ];
    final eveningSlots = ['05:00 PM', '05:30 PM', '06:00 PM', '06:30 PM'];
    return Scaffold(
      appBar: AppBar(title: const Text('Select Time Slot')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Available Time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Morning Section
            _buildPeriodSection(
              context,
              periodTitle: 'Morning',
              slots: morningSlots,
              icon: Icons.wb_sunny_outlined,
              provider: aptProvider,
            ),
            const SizedBox(height: 24),

            // Afternoon Section
            _buildPeriodSection(
              context,
              periodTitle: 'Afternoon',
              slots: afternoonSlots,
              icon: Icons.wb_twilight,
              provider: aptProvider,
            ),
            const SizedBox(height: 24),

            // Evening Section
            _buildPeriodSection(
              context,
              periodTitle: 'Evening',
              slots: eveningSlots,
              icon: Icons.nights_stay_outlined,
              provider: aptProvider,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSection(
    BuildContext context, {
    required String periodTitle,
    required List<String> slots,
    required IconData icon,
    required AppointmentProvider provider,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              periodTitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
          ),
          itemCount: slots.length,
          itemBuilder: (context, index) {
            final slot = slots[index];
            final isSelected = provider.selectedTimeSlot == slot;
            return InkWell(
              onTap: () {
                provider.setBookingTimeSlot(slot);
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  slot,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
