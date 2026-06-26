import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart'; // ← Naya import
import '../../routes/app_routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailAlerts = false;
  bool _queueAdvanceAlerts = true;
  bool _medicineAlerts = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // ThemeProvider ko globally listen karne k liye
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Section: Notifications
          _buildSectionHeader('Notifications Settings'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: _pushNotifications,
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive immediate alerts on mobile'),
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _pushNotifications = val),
                ),
                const Divider(height: 1, indent: 16),
                SwitchListTile(
                  value: _emailAlerts,
                  title: const Text('Email Alerts'),
                  subtitle: const Text(
                    'Receive reports and summaries via email',
                  ),
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _emailAlerts = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section: Queue management
          _buildSectionHeader('Queue Management'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: _queueAdvanceAlerts,
                  title: const Text('Queue Advance Alerts'),
                  subtitle: const Text(
                    'Notify 3 patient tokens before my turn',
                  ),
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _queueAdvanceAlerts = val),
                ),
                const Divider(height: 1, indent: 16),
                SwitchListTile(
                  value: _medicineAlerts,
                  title: const Text('Medicine Counter Reminders'),
                  subtitle: const Text('Alert when pharmacy token is called'),
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _medicineAlerts = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section: Theme UI (DARK MODE WORKING ✅)
          _buildSectionHeader('App Appearance'),
          Card(
            child: SwitchListTile(
              value:
                  themeProvider.isDarkMode, // ThemeProvider se value le rha h
              title: const Text('Dark Mode / Night Theme'),
              subtitle: const Text('Switch to high contrast dark aesthetics'),
              activeColor: AppColors.primary,
              onChanged: (val) {
                // Poori app ka theme change karne k liye trigger
                themeProvider.toggleTheme(val);
              },
            ),
          ),
          const SizedBox(height: 24),

          // Section: Account Actions (LOGOUT WORKING ✅)
          _buildSectionHeader('Account Actions'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text(
                'Log Out',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text('Securely sign out of this device'),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textLight,
              ),
              onTap: () {
                _showLogoutDialog(context, authProvider);
              },
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text(
            'Are you sure you want to log out of your account?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext); // Dialog close

                // Show loading spinner
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );

                try {
                  await auth.logout(); // Firebase/Service logout
                } catch (e) {
                  print("Logout trace error: $e");
                }

                if (context.mounted) {
                  Navigator.pop(context); // Remove spinner

                  // Clear stack and go to login
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                }
              },
              child: const Text(
                'Log Out',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
