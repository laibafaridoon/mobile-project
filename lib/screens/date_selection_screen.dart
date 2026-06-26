import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../providers/appointment_provider.dart';

class DateSelectionScreen extends StatelessWidget {
  const DateSelectionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final aptProvider = Provider.of<AppointmentProvider>(context);

    // Generate dates: next 14 days excluding Sundays (assuming clinic is closed Sundays)
    final List<DateTime> availableDates = [];
    DateTime tempDate = DateTime.now();
    for (int i = 0; i < 20; i++) {
      final checkDate = tempDate.add(Duration(days: i));
      if (checkDate.weekday != DateTime.sunday) {
        availableDates.add(checkDate);
      }
      if (availableDates.length >= 14) break;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Select Date')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Available Date',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Only working days are listed. Select a date below to view available time slots.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: availableDates.length,
                itemBuilder: (context, index) {
                  final date = availableDates[index];
                  final isSelected =
                      aptProvider.selectedDate != null &&
                      aptProvider.selectedDate!.year == date.year &&
                      aptProvider.selectedDate!.month == date.month &&
                      aptProvider.selectedDate!.day == date.day;
                  final dayName = DateFormat('E').format(date); // Mon, Tue
                  final dayNum = DateFormat('d').format(date); // 24
                  final monthName = DateFormat('MMM').format(date); // Jun
                  return InkWell(
                    onTap: () {
                      aptProvider.setBookingDate(date);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dayName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white.withOpacity(0.8)
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            dayNum,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            monthName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white.withOpacity(0.8)
                                  : AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
