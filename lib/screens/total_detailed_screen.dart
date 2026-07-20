import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/appointment.dart';
import '../../providers/appointment_provider.dart';
import '../../routes/app_routes.dart';

class TokenDetailScreen extends StatelessWidget {
  final Appointment appointment;
  const TokenDetailScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);

    Color statusColor = AppColors.waiting;
    if (appointment.status == 'In Progress') statusColor = AppColors.inProgress;
    if (appointment.status == 'Your Turn Next') statusColor = AppColors.yourTurn;
    if (appointment.status == 'Completed') statusColor = AppColors.completed;
    if (appointment.status == 'Cancelled') statusColor = AppColors.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Token Ticket Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _buildSafeImage(appointment.doctorImageUrl),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(appointment.doctorName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(appointment.doctorSpecialization, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                                  Text(appointment.roomNumber, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: List.generate(20, (i) => Expanded(
                          child: Container(height: 1.5, color: i % 2 == 0 ? Colors.transparent : AppColors.border),
                        )),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Column(
                          children: [
                            const Text('QUEUE TOKEN NUMBER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textLight, letterSpacing: 1)),
                            Text(appointment.tokenNumber, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                              child: Text(appointment.status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 120,
                        height: 120,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                        child: _buildMockQRCode(),
                      ),
                      const SizedBox(height: 8),
                      const Text('Scan at Room entrance to check in', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
                      const SizedBox(height: 20),
                      Container(
                        color: AppColors.primaryLight.withOpacity(0.2),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        child: Row(
                          children: [
                            Expanded(child: _buildTicketStat('Position', '#${appointment.queuePosition}')),
                            Expanded(child: _buildTicketStat('Est. Wait', '${appointment.estimatedWaitTime}m')),
                            Expanded(child: _buildTicketStat('Time Slot', appointment.timeSlot)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (appointment.status != 'Completed' && appointment.status != 'Cancelled') ...[
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.liveQueue, arguments: appointment.id),
                child: const Text('Track Live Queue Progress'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _showCancelDialog(context, appointmentProvider, appointment.id),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                child: const Text('Cancel Appointment'),
              ),
            ],
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back to Dashboard', style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafeImage(String url) {
    bool isValidUrl = url.isNotEmpty && url.startsWith('http') && Uri.tryParse(url)?.hasAbsolutePath == true;
    if (!isValidUrl) return _buildPlaceholderIcon();
    return Image.network(url, width: 60, height: 60, fit: BoxFit.cover, errorBuilder: (c, e, s) => _buildPlaceholderIcon());
  }

  Widget _buildPlaceholderIcon() => Container(width: 60, height: 60, color: AppColors.background, child: const Icon(Icons.person, color: AppColors.primary));

  Widget _buildTicketStat(String label, String value) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
      Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary)),
    ]);
  }

  Widget _buildMockQRCode() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 4, mainAxisSpacing: 4),
      itemCount: 25,
      itemBuilder: (context, index) {
        bool isCorner = (index == 0 || index == 1 || index == 5 || index == 6) || (index == 3 || index == 4 || index == 8 || index == 9) || (index == 20 || index == 21 || index == 15 || index == 16);
        return Container(decoration: BoxDecoration(color: isCorner || (index % 3 == 0) ? AppColors.textPrimary : Colors.white, borderRadius: BorderRadius.circular(2)));
      },
    );
  }

  void _showCancelDialog(BuildContext context, AppointmentProvider provider, String appointmentId) {
    double refundAmount = (appointment.amountPaid ?? 0) * 0.90;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel & Refund?'),
        content: Text('Are you sure? 10% will be deducted. You will get PKR ${refundAmount.toStringAsFixed(2)} back.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
          TextButton(
            onPressed: () {
              provider.cancelAppointment(appointmentId);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}