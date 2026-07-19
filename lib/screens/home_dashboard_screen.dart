import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_hospital/models/appointment.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/medicine_provider.dart';
import '../../providers/notification_provider.dart';
import '../../routes/app_routes.dart';
import 'ai_assistant_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final medicineProvider = Provider.of<MedicineProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);

    final patientName = authProvider.user?.name ?? 'Patient';
    final activeAppointments = appointmentProvider.activeAppointments;
    final medicines = medicineProvider.medicines;

    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
    } else if (hour >= 17) {
      greeting = 'Good Evening';
    }

    return Scaffold(
      floatingActionButton: ScaleTransition(
        scale: _pulseAnimation,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AiAssistantScreen()),
            );
          },
          backgroundColor: AppColors.primary,
          elevation: 10,
          shape: const CircleBorder(),
          child: const Icon(Icons.psychology_alt_rounded, color: Colors.white, size: 30),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                            child: CircleAvatar(
                              radius: 26,
                              backgroundColor: AppColors.primaryLight,
                              backgroundImage: authProvider.user?.profilePictureUrl.isNotEmpty == true
                                  ? NetworkImage(authProvider.user!.profilePictureUrl)
                                  : null,
                              child: authProvider.user?.profilePictureUrl.isEmpty == true
                                  ? const Icon(Icons.person, color: AppColors.primary, size: 28)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(greeting, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7))),
                              Text(patientName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 28),
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
                          ),
                          if (notificationProvider.unreadCount > 0)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                child: Text('${notificationProvider.unreadCount}',
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.searchDoctor),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search_rounded, color: AppColors.textSecondary),
                          SizedBox(width: 12),
                          Text('Search doctors, specialities...', style: TextStyle(color: AppColors.textLight, fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickAction(context, label: 'Book Consult', icon: Icons.calendar_month_rounded, color: AppColors.primary, route: AppRoutes.doctorList),
                  _buildQuickAction(context, label: 'Live Queue', icon: Icons.rocket_launch_rounded, color: AppColors.accent, onTap: () {
                    if (activeAppointments.isNotEmpty) {
                      Navigator.pushNamed(context, AppRoutes.liveQueue, arguments: activeAppointments.first.id);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No active appointments to track')));
                    }
                  }),
                  _buildQuickAction(context, label: 'Medicines', icon: Icons.medical_services_rounded, color: Colors.teal.shade300, route: AppRoutes.medicineReminder),
                  _buildQuickAction(context, label: 'Profile', icon: Icons.person_rounded, color: Colors.teal.shade800, route: AppRoutes.profile),
                ],
              ),
            ),

            const SizedBox(height: 28),
            if (activeAppointments.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Current Queue Token', style: Theme.of(context).textTheme.titleMedium),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.liveQueue, arguments: activeAppointments.first.id),
                      child: const Text('Track Live'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildQueueStatusCard(context, activeAppointments.first),
              ),
              const SizedBox(height: 28),
            ],

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Upcoming Consults', style: Theme.of(context).textTheme.titleMedium),
                  TextButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.appointmentHistory), child: const Text('View All')),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (activeAppointments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildEmptyState(context, message: 'No upcoming appointments booked.', actionText: 'Book a Doctor Now', onAction: () => Navigator.pushNamed(context, AppRoutes.doctorList)),
              )
            else
              Container(
                height: 125,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: activeAppointments.length,
                  itemBuilder: (context, index) => _buildAppointmentCard(context, activeAppointments[index]),
                ),
              ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Today\'s Medicines', style: Theme.of(context).textTheme.titleMedium),
                  TextButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.medicineReminder), child: const Text('Full Log')),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (medicines.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildEmptyState(context, message: 'No active medicine reminders.', actionText: 'Add Medicine', onAction: () => Navigator.pushNamed(context, AppRoutes.addMedicine)),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildMedicineProgressCard(medicineProvider, medicines),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineProgressCard(MedicineProvider provider, List medicines) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Medication Adherence', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('${(provider.dailyProgress * 100).toInt()}% Done', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: provider.dailyProgress, minHeight: 8, color: AppColors.primary, backgroundColor: AppColors.primaryLight),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: medicines.length > 3 ? 3 : medicines.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, idx) {
                final med = medicines[idx];
                final firstSlot = med.takenToday.keys.isNotEmpty ? med.takenToday.keys.first : '';
                final isTaken = firstSlot.isNotEmpty ? med.takenToday[firstSlot] ?? false : false;
                return Row(
                  children: [
                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.poll, color: AppColors.primary, size: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(firstSlot.isNotEmpty ? '${med.dosage} • ${med.beforeFood ? "Before Food" : "After Food"}' : '${med.dosage} • No scheduled slot', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    if (firstSlot.isNotEmpty)
                      Checkbox(value: isTaken, activeColor: AppColors.primary, onChanged: (val) => provider.toggleTaken(med.id, firstSlot, val ?? false)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, {required String label, required IconData icon, required Color color, String? route, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () { if (route != null) Navigator.pushNamed(context, route); },
      child: Column(children: [
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.1), width: 1.5)), child: Icon(icon, color: color, size: 28)),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ]),
    );
  }

  Widget _buildQueueStatusCard(BuildContext context, Appointment appointment) {
    Color statusColor = appointment.status == 'In Progress' ? AppColors.inProgress : (appointment.status == 'Your Turn Next' ? AppColors.yourTurn : AppColors.waiting);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: AppColors.primary, width: 1.5)),
      child: Container(padding: const EdgeInsets.all(16.0), child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(appointment.doctorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(appointment.roomNumber, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))]),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Text(appointment.status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold))),
        ]),
        const Divider(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _buildQueueStat('Token No.', appointment.tokenNumber, AppColors.primary),
          _buildQueueStat('Position', '${appointment.queuePosition}', AppColors.accent),
          _buildQueueStat('Est. Wait', '${appointment.estimatedWaitTime} min', Colors.orange.shade700),
        ]),
      ])),
    );
  }

  Widget _buildQueueStat(String label, String value, Color color) {
    return Column(children: [Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)), const SizedBox(height: 4), Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold))]);
  }

  Widget _buildAppointmentCard(BuildContext context, Appointment appointment) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.tokenDetail, arguments: appointment),
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(right: 16),
        child: Card(child: Padding(padding: const EdgeInsets.all(12.0), child: Row(children: [
          CircleAvatar(radius: 28, backgroundColor: AppColors.primaryLight, child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 28)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(appointment.doctorName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(appointment.doctorSpecialization, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            const SizedBox(height: 8),
            Row(children: [const Icon(Icons.access_time_rounded, size: 12, color: AppColors.primary), const SizedBox(width: 4), Text(appointment.timeSlot, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]),
          ])),
        ]))),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, {required String message, required String actionText, required VoidCallback onAction}) {
    return Card(child: Container(width: double.infinity, padding: const EdgeInsets.all(20), child: Column(children: [Text(message, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13), textAlign: TextAlign.center), const SizedBox(height: 12), OutlinedButton(onPressed: onAction, child: Text(actionText, style: const TextStyle(fontSize: 12)))])));
  }
}