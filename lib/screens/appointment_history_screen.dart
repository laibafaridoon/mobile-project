import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../models/appointment.dart';
import '../../providers/appointment_provider.dart';
import '../../routes/app_routes.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  const AppointmentHistoryScreen({super.key});
  @override
  State<AppointmentHistoryScreen> createState() =>
      _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aptProvider = Provider.of<AppointmentProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment History'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'Active Consults'),
            Tab(text: 'Past / History'),
          ],
        ),
      ),
      body: aptProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
        controller: _tabController,
        children: [
          _buildAppointmentsTab(context, aptProvider.activeAppointments, isActive: true),
          _buildAppointmentsTab(context, aptProvider.pastAppointments, isActive: false),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab(BuildContext context, List<Appointment>? list, {required bool isActive}) {
    if (list == null || list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy_rounded, size: 72, color: AppColors.textLight),
            const SizedBox(height: 16),
            Text(isActive ? 'No active appointments' : 'No history found',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      itemBuilder: (context, index) => _buildAppointmentItem(context, list[index], isActive),
    );
  }

  Widget _buildAppointmentItem(BuildContext context, Appointment apt, bool isActive) {
    final formattedDate = DateFormat('dd MMM yyyy').format(apt.date);
    Color statusColor = AppColors.waiting;
    if (apt.status == 'In Progress') statusColor = AppColors.inProgress;
    if (apt.status == 'Your Turn Next') statusColor = AppColors.yourTurn;
    if (apt.status == 'Completed') statusColor = AppColors.completed;
    if (apt.status == 'Cancelled') statusColor = AppColors.error;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildSafeImage(apt.doctorImageUrl),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(apt.doctorName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(apt.status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      Text(apt.doctorSpecialization,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          _buildIconText(Icons.calendar_today_rounded, formattedDate),
                          _buildIconText(Icons.access_time_rounded, apt.timeSlot),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isActive && apt.status != 'Cancelled') ...[
              const Divider(height: 24, color: AppColors.border),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => _showCancelDialog(context, apt),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.liveQueue, arguments: apt.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Track Live', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildSafeImage(String url) {
    bool isValid = url.isNotEmpty && url.startsWith('http') && Uri.tryParse(url)?.hasAbsolutePath == true;
    if (!isValid) {
      return Container(
        width: 56,
        height: 56,
        color: AppColors.background,
        child: const Icon(Icons.person, color: AppColors.primary),
      );
    }
    return Image.network(
      url,
      width: 56,
      height: 56,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: 56,
        height: 56,
        color: AppColors.background,
        child: const Icon(Icons.person, color: AppColors.primary),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, Appointment apt) {
    // Calculate 90% refund (10% deduction)
    double originalAmount = apt.amountPaid ?? 0;
    double refundAmount = originalAmount * 0.90;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to cancel this appointment? This action cannot be undone.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Amount Paid:', style: TextStyle(fontSize: 12)),
                      Text('PKR ${originalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Refund (90%):', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                      Text('PKR ${refundAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('* 10% processing fee deducted.', style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No, Keep It')),
          TextButton(
            onPressed: () {
              Provider.of<AppointmentProvider>(context, listen: false).cancelAppointment(apt.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Cancelled. Refund of PKR ${refundAmount.toStringAsFixed(2)} processed.'),
                backgroundColor: AppColors.error,
              ));
            },
            child: const Text('Yes, Cancel & Refund', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
