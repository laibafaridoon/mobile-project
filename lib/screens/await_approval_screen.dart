import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../routes/app_routes.dart';

class AwaitApprovalScreen extends StatelessWidget {
  const AwaitApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
          },
        ),
        title: const Text('Pending Approval'),
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.hourglass_top, size: 80, color: AppColors.primary),
              SizedBox(height: 24),
              Text(
                'Your registration request is under review by the admin.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: AppColors.textPrimary),
              ),
              SizedBox(height: 12),
              Text(
                'You will be able to access the doctor dashboard once approved.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
