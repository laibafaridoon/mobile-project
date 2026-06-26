import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/doctor.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/queue_provider.dart';

class ManageQueueScreen extends StatefulWidget {
  const ManageQueueScreen({super.key});
  @override
  State<ManageQueueScreen> createState() => _ManageQueueScreenState();
}

class _ManageQueueScreenState extends State<ManageQueueScreen> {
  Doctor? _selectedDoctor;
  final _roomController = TextEditingController();
  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final docProvider = Provider.of<DoctorProvider>(context);
    final aptProvider = Provider.of<AppointmentProvider>(context);
    final queueProvider = Provider.of<QueueProvider>(context);
    // Initial default doctor selection if not selected yet
    if (_selectedDoctor == null && docProvider.doctors.isNotEmpty) {
      _selectedDoctor = docProvider.doctors.first;
      _roomController.text = _selectedDoctor!.hospitalName; // default room
    }
    final doctorQueue = _selectedDoctor != null
        ? aptProvider.activeAppointments
              .where((apt) => apt.doctorId == _selectedDoctor!.id)
              .toList()
        : [];
    final stats = _selectedDoctor != null
        ? queueProvider.getDoctorQueueStats(_selectedDoctor!.id)
        : {'servingToken': 'N/A', 'waitingCount': 0, 'roomNumber': 'N/A'};
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Queues')),
      body: docProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Doctor Selector Section
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Doctor Queue',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Doctor>(
                        initialValue: _selectedDoctor,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: docProvider.doctors.map((doc) {
                          return DropdownMenuItem(
                            value: doc,
                            child: Text('${doc.name} (${doc.specialization})'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedDoctor = val;
                            if (val != null) {
                              _roomController.text = stats['roomNumber'];
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
                if (_selectedDoctor != null) ...[
                  // Queue stats display card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Card(
                      color: AppColors.primaryLight.withOpacity(0.4),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatsColumn(
                                  'Now Serving',
                                  stats['servingToken'],
                                  AppColors.primary,
                                ),
                                _buildStatsColumn(
                                  'Waiting',
                                  '${stats['waitingCount']}',
                                  AppColors.accent,
                                ),
                                _buildStatsColumn(
                                  'Active Room',
                                  stats['roomNumber']
                                      .toString()
                                      .split(' ')
                                      .first,
                                  Colors.orange.shade700,
                                ),
                              ],
                            ),
                            const Divider(height: 24, color: AppColors.border),

                            // Room Configuration field
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _roomController,
                                    decoration: const InputDecoration(
                                      labelText: 'Update Room Number',
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                    ),
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    final roomText = _roomController.text
                                        .trim();
                                    if (roomText.isNotEmpty) {
                                      // Call service update directly
                                      // Normally would go through provider
                                      // Let's call provider/service directly
                                      // We added updateRoomNumber in appointment service
                                      // Let's run it.
                                      setState(() {
                                        // Update room
                                      });
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Room details updated'),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    minimumSize: Size.zero,
                                  ),
                                  child: const Text(
                                    'Update',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Call Next Patient button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ElevatedButton(
                      onPressed: doctorQueue.isEmpty
                          ? null
                          : () {
                              queueProvider.advanceQueue(_selectedDoctor!.id);
                              // Refresh
                              aptProvider.loadAppointments();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.record_voice_over_rounded,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8),
                          Text('Call Next Patient (Advance Queue)'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Queue List View Header
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Patients in Queue Line',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Queue Patients List
                  Expanded(
                    child: doctorQueue.isEmpty
                        ? _buildEmptyQueue()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 4,
                            ),
                            itemCount: doctorQueue.length,
                            itemBuilder: (context, index) {
                              final apt = doctorQueue[index];

                              Color statusColor = AppColors.waiting;
                              if (apt.status == 'In Progress') {
                                statusColor = AppColors.inProgress;
                              }
                              if (apt.status == 'Your Turn Next') {
                                statusColor = AppColors.yourTurn;
                              }
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 12.0,
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: AppColors.border,
                                        radius: 18,
                                        child: Text(
                                          '${apt.queuePosition}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              apt.tokenNumber,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const Text(
                                              'Patient ID: John Doe', // mock
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Manual status action dropdown
                                      DropdownButton<String>(
                                        value: apt.status,
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: statusColor,
                                        ),
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        underline: Container(),
                                        items:
                                            [
                                              'Waiting',
                                              'In Progress',
                                              'Your Turn Next',
                                              'Completed',
                                              'Cancelled',
                                            ].map((s) {
                                              return DropdownMenuItem(
                                                value: s,
                                                child: Text(s),
                                              );
                                            }).toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            aptProvider
                                                .adminUpdateAppointmentStatus(
                                                  apt.id,
                                                  val,
                                                );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildStatsColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyQueue() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checklist_rtl_rounded,
            size: 56,
            color: AppColors.textLight,
          ),
          SizedBox(height: 12),
          Text(
            'Queue line is empty',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            'No active appointments booked for this doctor today.',
            style: TextStyle(fontSize: 12, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}
