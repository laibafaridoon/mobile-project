import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../routes/app_routes.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final docProvider = Provider.of<DoctorProvider>(context);
    final aptProvider = Provider.of<AppointmentProvider>(context);
    final totalDoctors = docProvider.doctors.length;
    final totalBookings = aptProvider.appointments.length;
    final activeQueuesCount = docProvider.doctors.where((doc) {
      final stats = Provider.of<AppointmentProvider>(
        context,
        listen: false,
      ).activeAppointments.where((apt) => apt.doctorId == doc.id).toList();
      return stats.isNotEmpty;
    }).length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: () {
              authProvider.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Intro
            const Text(
              'Hospital Overview',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Real-time stats and management controls',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            // Analytics Cards Grid
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticCard(
                    context,
                    title: 'Total Doctors',
                    value: '$totalDoctors',
                    icon: Icons.people_alt_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAnalyticCard(
                    context,
                    title: 'Total Bookings',
                    value: '$totalBookings',
                    icon: Icons.calendar_month_rounded,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticCard(
                    context,
                    title: 'Active Queues',
                    value: '$activeQueuesCount',
                    icon: Icons.rocket_launch_rounded,
                    color: Colors.amber.shade800,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildAnalyticCard(
                    context,
                    title: 'Revenue Today',
                    value: '\$${(totalBookings * 100).toStringAsFixed(0)}',
                    icon: Icons.monetization_on_rounded,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Quick Actions Cards list
            const Text(
              'Administration Tasks',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            _buildAdminActionTile(
              context,
              title: 'Manage Doctors database',
              subtitle: 'Add, update, or remove doctor profiles',
              icon: Icons.medical_services_outlined,
              color: AppColors.primary,
              route: AppRoutes.manageDoctors,
            ),
            const SizedBox(height: 12),
            _buildAdminActionTile(
              context,
              title: 'Manage Queue Progress',
              subtitle: 'Update room numbers and call next token',
              icon: Icons.queue_play_next_rounded,
              color: AppColors.accent,
              route: AppRoutes.manageQueue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Card(
      child: ListTile(
        onTap: () => Navigator.pushNamed(context, route),
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: AppColors.textLight,
        ),
      ),
    );
  }
}
