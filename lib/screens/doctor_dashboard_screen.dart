import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../providers/auth_provider.dart';
import '../providers/appointment_provider.dart';
import '../routes/app_routes.dart';
import '../../services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      if (authProvider.user != null) {
        appointmentProvider.listenToDoctorAppointments(authProvider.user!.uid);
      }
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final aptProvider = Provider.of<AppointmentProvider>(context);

    final doctorName = authProvider.user?.name ?? 'Doctor';
    final allApts = aptProvider.doctorAppointments;

    // Filter appointments
    final pendingApts = allApts.where((apt) => apt.status == 'Pending').toList();
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final activeApts = allApts.where((apt) {
      final aptDay = DateFormat('yyyy-MM-dd').format(apt.date);
      return aptDay == todayStr &&
          (apt.status == 'Confirmed' ||
              apt.status == 'Waiting' ||
              apt.status == 'In Progress' ||
              apt.status == 'Your Turn Next');
    }).toList();

    // Sort active appointments by queue position
    activeApts.sort((a, b) => a.queuePosition.compareTo(b.queuePosition));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.primary),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.doctorProfile);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                      (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: aptProvider.isLoading
          ? const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      )
          : RefreshIndicator(
        onRefresh: () async {
          if (authProvider.user != null) {
            aptProvider.listenToDoctorAppointments(authProvider.user!.uid);
          }
        },
        child: Scrollbar(
          thumbVisibility: true,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            children: [
              Text(
                'Welcome, $doctorName',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your queue and patient requests for today.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Pending Requests',
                      value: '${pendingApts.length}',
                      icon: Icons.pending_actions_rounded,
                      color: Colors.orange.shade800,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Active Patients Today',
                      value: '${activeApts.length}',
                      icon: Icons.people_outline_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('Pending Booking Requests', pendingApts.length),
              const SizedBox(height: 12),
              if (pendingApts.isEmpty)
                _buildEmptyCard('No pending booking requests.')
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pendingApts.length,
                  itemBuilder: (context, index) {
                    return _buildPendingRequestTile(context, pendingApts[index], aptProvider);
                  },
                ),
              const SizedBox(height: 32),
              _buildSectionHeader('Today\'s Queue', activeApts.length),
              const SizedBox(height: 12),
              if (activeApts.isEmpty)
                _buildEmptyCard('No active appointments in the queue today.')
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activeApts.length,
                  itemBuilder: (context, index) {
                    return _buildQueueTile(context, activeApts[index], aptProvider);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (count > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
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

  Widget _buildEmptyCard(String message) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildPendingRequestTile(
      BuildContext context,
      dynamic apt,
      AppointmentProvider provider,
      ) {
    final dateStr = DateFormat('dd MMM yyyy').format(apt.date);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  apt.patientName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  apt.timeSlot,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Date: $dateStr',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            if (apt.notes != null && apt.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: "${apt.notes}"',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final success = await provider.rejectAppointmentRequest(apt.id);
                      if (context.mounted && success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Request rejected successfully'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final success = await provider.acceptAppointmentRequest(apt.id);
                      if (context.mounted && success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Request approved and token generated!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Accept', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueTile(
      BuildContext context,
      dynamic apt,
      AppointmentProvider provider,
      ) {
    Color statusColor = AppColors.waiting;
    if (apt.status == 'In Progress') {
      statusColor = AppColors.inProgress;
    } else if (apt.status == 'Your Turn Next') {
      statusColor = AppColors.yourTurn;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: apt.status == 'In Progress' ? AppColors.primary : AppColors.border,
          width: apt.status == 'In Progress' ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'TOKEN',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    apt.tokenNumber,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    apt.patientName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Slot: ${apt.timeSlot} • Room: ${apt.roomNumber}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      apt.status,
                      style: TextStyle(
                        fontSize: 10,
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                if (apt.status != 'In Progress')
                  IconButton(
                    icon: const Icon(Icons.play_circle_outline_rounded, color: Colors.green, size: 28),
                    onPressed: () {
                      provider.updateAppointmentStatus(apt.id, 'In Progress');
                    },
                    tooltip: 'Call Patient In',
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 28),
                    onPressed: () async {
                      await provider.updateAppointmentStatus(apt.id, 'Completed');
                      try {
                        await FirebaseService.addDocument(
                          collection: 'notifications',
                          data: {
                            'patientUid': apt.patientId,
                            'title': 'Consultation Completed',
                            'body': 'Your consultation with Dr. ${apt.doctorName} has been finalized.',
                            'timestamp': FieldValue.serverTimestamp(),
                          },
                        );
                      } catch (e) {
                        print('[DoctorDashboard] Notification error: $e');
                      }
                    },
                    tooltip: 'Finalize Consultation',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}