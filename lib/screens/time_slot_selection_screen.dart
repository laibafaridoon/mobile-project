import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../providers/appointment_provider.dart';

class TimeSlotSelectionScreen extends StatefulWidget {
  const TimeSlotSelectionScreen({super.key});

  @override
  State<TimeSlotSelectionScreen> createState() => _TimeSlotSelectionScreenState();
}

class _TimeSlotSelectionScreenState extends State<TimeSlotSelectionScreen> {

  @override
  void initState() {
    super.initState();
    // Ensure we are listening to the correct doctor's appointments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final aptProvider = Provider.of<AppointmentProvider>(context, listen: false);
      if (aptProvider.selectedDoctor != null) {
        aptProvider.listenToDoctorAppointments(aptProvider.selectedDoctor!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final aptProvider = Provider.of<AppointmentProvider>(context);
    final doctor = aptProvider.selectedDoctor;
    final selectedDate = aptProvider.selectedDate;

    if (doctor == null || selectedDate == null) {
      return const Scaffold(body: Center(child: Text('Invalid State. Please go back.')));
    }

    // Filter booked slots for the selected date
    final String dateKey = DateFormat('yyyy-MM-dd').format(selectedDate);
    final bookedSlots = aptProvider.doctorAppointments
        .where((apt) =>
    DateFormat('yyyy-MM-dd').format(apt.date) == dateKey &&
        (apt.status == 'Confirmed' || apt.status == 'Pending' || apt.status == 'Waiting'))
        .map((apt) => apt.timeSlot)
        .toList();

    // Use doctor's specific slots or fallback to default
    final allSlots = doctor.availableTimeSlots.isNotEmpty
        ? doctor.availableTimeSlots
        : ['09:00 AM', '10:00 AM', '11:00 AM', '02:00 PM', '03:00 PM', '04:00 PM'];

    // Categorize slots into Morning, Afternoon, Evening
    final morning = allSlots.where((s) => s.contains('AM')).toList();
    final afternoon = allSlots.where((s) => s.contains('PM') && (s.startsWith('01') || s.startsWith('02') || s.startsWith('03') || s.startsWith('04') || s.startsWith('12'))).toList();
    final evening = allSlots.where((s) => s.contains('PM') && !afternoon.contains(s)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Select Time Slot')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Slots for ${DateFormat('dd MMM yyyy').format(selectedDate)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Greyed out slots are already reserved by other patients.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 24),

            if (morning.isNotEmpty)
              _buildSection('Morning', morning, Icons.wb_sunny_outlined, aptProvider, bookedSlots),
            if (afternoon.isNotEmpty)
              _buildSection('Afternoon', afternoon, Icons.wb_twilight, aptProvider, bookedSlots),
            if (evening.isNotEmpty)
              _buildSection('Evening', evening, Icons.nights_stay_outlined, aptProvider, bookedSlots),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> slots, IconData icon, AppointmentProvider provider, List<String> bookedSlots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.2,
          ),
          itemCount: slots.length,
          itemBuilder: (context, index) {
            final slot = slots[index];
            final bool isReserved = bookedSlots.contains(slot);
            final bool isSelected = provider.selectedTimeSlot == slot;

            return InkWell(
              onTap: isReserved ? null : () {
                provider.setBookingTimeSlot(slot);
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: isReserved ? Colors.grey[200] : (isSelected ? AppColors.primary : Colors.white),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isReserved ? Colors.transparent : (isSelected ? AppColors.primary : AppColors.border),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  slot,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isReserved ? Colors.grey[400] : (isSelected ? Colors.white : AppColors.textPrimary),
                    decoration: isReserved ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
