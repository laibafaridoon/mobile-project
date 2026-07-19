import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/payment_button.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _localLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handlePay(
    BuildContext context,
    PaymentProvider paymentProvider,
    AuthProvider authProvider,
    AppointmentProvider appointmentProvider,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _localLoading = true;
    });

    final doctor = appointmentProvider.selectedDoctor!;
    final date = appointmentProvider.selectedDate!;
    final slot = appointmentProvider.selectedTimeSlot!;
    final patient = authProvider.user;

    final patientId = patient?.uid ?? 'DEMO_USER_ID';
    final patientName = patient?.name ?? 'Patient';
    final patientEmail = patient?.email ?? 'patient@example.com';

    final appointment = await paymentProvider.processPayment(
      patientId: patientId,
      patientName: patientName,
      patientEmail: patientEmail,
      doctor: doctor,
      date: date,
      timeSlot: slot,
      consultationFee: doctor.consultationFee,
    );

    setState(() {
      _localLoading = false;
    });

    if (context.mounted) {
      if (appointment != null) {
        // Navigate to payment success screen and clear flow history
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.paymentSuccess,
          ModalRoute.withName(AppRoutes.home),
          arguments: appointment,
        );
      } else {
        // Navigate to payment failed screen with the error message
        Navigator.pushNamed(
          context,
          AppRoutes.paymentFailed,
          arguments: paymentProvider.errorMessage ?? 'Transaction aborted by user.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final paymentProvider = Provider.of<PaymentProvider>(context);

    final doctor = appointmentProvider.selectedDoctor;
    final date = appointmentProvider.selectedDate;
    final slot = appointmentProvider.selectedTimeSlot;

    if (doctor == null || date == null || slot == null) {
      return const Scaffold(
        body: Center(
          child: Text('Invalid state. Please start booking again.'),
        ),
      );
    }

    final dateStr = DateFormat('EEEE, dd MMMM yyyy').format(date);
    final fee = doctor.consultationFee;
    const serviceFee = 5.0; // Dummy platform fee in dollars (simulated in PKR below)
    final total = fee + serviceFee;

    // Standard styling values matching the smart hospital project
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Checkout'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary Section
              Text(
                'Appointment Summary',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.primaryLight,
                            child: const Icon(Icons.person, size: 36, color: AppColors.primary),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doctor.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  doctor.specialization,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32, color: AppColors.border),
                      _buildRow(Icons.calendar_today_outlined, 'Date', dateStr),
                      const SizedBox(height: 12),
                      _buildRow(Icons.access_time, 'Time Slot', slot),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Billing Information Section
              Text(
                'Billing Details',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildBillRow('Consultation Fee', 'PKR ${fee.toStringAsFixed(2)}'),
                      const SizedBox(height: 8),
                      _buildBillRow('Service Charges', 'PKR ${serviceFee.toStringAsFixed(2)}'),
                      const Divider(height: 24, color: AppColors.border),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            'PKR ${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Easypaisa Account Form
              Text(
                'Easypaisa Payment Wallet',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 11,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: 'Mobile Wallet Account Number',
                  hintText: 'e.g. 03XXXXXXXXX',
                  counterText: '',
                  prefixIcon: const Icon(Icons.phone_iphone, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your mobile account number';
                  }
                  final regExp = RegExp(r'^03[0-9]{9}$');
                  if (!regExp.hasMatch(value.trim())) {
                    return 'Please enter a valid Easypaisa account (03XXXXXXXXX)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              const Text(
                'After clicking pay, you will receive a push notification / USSD prompt on your registered phone number to enter your 5-digit Easypaisa pin.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 48),

              // Pay Button
              PaymentButton(
                text: 'Pay PKR ${total.toStringAsFixed(2)}',
                isLoading: _localLoading || paymentProvider.isLoading,
                onPressed: () => _handlePay(context, paymentProvider, authProvider, appointmentProvider),
                icon: Icons.lock_outline,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBillRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }
}
