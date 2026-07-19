import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/medicine.dart';
import '../../providers/medicine_provider.dart';
import '../../routes/app_routes.dart';

class MedicineReminderScreen extends StatelessWidget {
  const MedicineReminderScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicineProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Reminders')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Progress Banner Card
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Adherence Tracker',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Keep tracking your pills daily to stay healthy.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Completion Progress',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${(provider.dailyProgress * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: provider.dailyProgress,
                      minHeight: 10,
                      color: AppColors.accent,
                      backgroundColor: Colors.white.withOpacity(0.25),
                    ),
                  ),
                ],
              ),
            ),
            // Time Slots sections
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSlotHeader('Morning Dosage', Icons.wb_sunny_rounded),
                  _buildMedicinesList(
                    context,
                    provider.morningMedicines,
                    'morning',
                    provider,
                  ),
                  const SizedBox(height: 24),

                  _buildSlotHeader('Afternoon Dosage', Icons.wb_twilight),
                  _buildMedicinesList(
                    context,
                    provider.afternoonMedicines,
                    'afternoon',
                    provider,
                  ),
                  const SizedBox(height: 24),

                  _buildSlotHeader('Evening Dosage', Icons.mode_night_rounded),
                  _buildMedicinesList(
                    context,
                    provider.eveningMedicines,
                    'evening',
                    provider,
                  ),
                  const SizedBox(height: 24),

                  _buildSlotHeader('Night Dosage', Icons.bedtime_rounded),
                  _buildMedicinesList(
                    context,
                    provider.nightMedicines,
                    'night',
                    provider,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addMedicine),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Pill', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildSlotHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMedicinesList(
    BuildContext context,
    List<Medicine>? list,
    String slot,
    MedicineProvider provider,
  ) {
    if (list == null || list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8.0, left: 26.0),
        child: Text(
          'No medicines scheduled.',
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final med = list[index];
        final isTaken = med.takenToday[slot] ?? false;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Icon(
              Icons.circle,
              size: 10,
              color: isTaken ? AppColors.success : AppColors.waiting,
            ),
            title: Text(
              med.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                decoration: isTaken ? TextDecoration.lineThrough : null,
                color: isTaken ? AppColors.textLight : AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              '${med.dosage} • ${med.beforeFood ? "Before Food" : "After Food"}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.editMedicine,
                      arguments: med,
                    );
                  },
                ),
                Checkbox(
                  value: isTaken,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (val != null) {
                      provider.toggleTaken(med.id, slot, val);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
