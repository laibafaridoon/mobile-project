import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/appointment.dart';
import '../../routes/app_routes.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final Appointment appointment;

  const PaymentSuccessScreen({super.key, required this.appointment});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Success Animation Icon
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Payment Successful!',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your payment has been verified. Your appointment is now officially confirmed.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Receipt Card
              Card(
                elevation: 0,
                color: AppColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildReceiptRow('Doctor', widget.appointment.doctorName),
                      const SizedBox(height: 12),
                      _buildReceiptRow('Specialization', widget.appointment.doctorSpecialization),
                      const SizedBox(height: 12),
                      _buildReceiptRow('Queue Token', widget.appointment.tokenNumber),
                      const SizedBox(height: 12),
                      _buildReceiptRow(
                        'Amount Paid',
                        'PKR ${widget.appointment.amountPaid?.toStringAsFixed(2) ?? "0.00"}',
                      ),
                      const Divider(height: 32, color: AppColors.border),
                      _buildReceiptRow(
                        'Transaction ID',
                        widget.appointment.transactionId ?? 'N/A',
                        isBold: false,
                        fontSize: 12,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // Primary Action: View Token
              ElevatedButton(
                onPressed: () {
                  // Direct to token details safely
                  Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.tokenDetail,
                    arguments: widget.appointment,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'View Queue Token',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),

              // Secondary Action: Return to Home (CRASH FIX APPLIED)
              TextButton(
                onPressed: () {
                  // SAFEST WAY: Clear navigation stack and go to Home
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                        (route) => false,
                  );
                },
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: const Text(
                  'Return to Dashboard',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = true, double fontSize = 14}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: fontSize,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}