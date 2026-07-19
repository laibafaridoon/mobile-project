import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import Services & Providers
import 'services/firebase_service.dart';
import 'providers/auth_provider.dart';
import 'providers/doctor_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/queue_provider.dart';
import 'providers/medicine_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/theme_provider.dart'; // ← Ensure this file exists in providers
import 'providers/payment_provider.dart';

// Import Constants & Routes
import 'constants/theme.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await FirebaseService.initialize();
    print('[Main] Firebase initialized successfully');
  } catch (e) {
    print('[Main] Firebase initialization error (using demo mode): $e');
  }

  runApp(const SmartHospitalApp());
}

class SmartHospitalApp extends StatelessWidget {
  const SmartHospitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => QueueProvider()),
        ChangeNotifierProvider(create: (_) => MedicineProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: Builder(
        builder: (context) {
          final themeProvider = Provider.of<ThemeProvider>(context);

          return MaterialApp(
            title: 'Smart Hospital Queue & Appointment',
            debugShowCheckedModeBanner: false,

            // === LIGHT & DARK THEME SETUP ===
            themeMode:
                themeProvider.themeMode, // Handle auto/light/dark switching
            theme:
                AppTheme.lightTheme, // Aapka current light theme constants se
            darkTheme:
                AppTheme.darkTheme, // Aapka current dark theme constants se

            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRoutes.generateRoute,
          );
        },
      ),
    );
  }
}
