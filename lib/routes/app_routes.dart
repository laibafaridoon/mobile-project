import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_hospital/providers/auth_provider.dart';
import 'package:smart_hospital/screens/doctor_profile_screen.dart';
import 'package:smart_hospital/screens/Onboarding%202_screen.dart';
import 'package:smart_hospital/screens/Onboarding%201_screen.dart';
import 'package:smart_hospital/screens/add_medicine_screen.dart';
import 'package:smart_hospital/screens/admin_dashboard_screen.dart';
import 'package:smart_hospital/screens/appointment_booking_screen.dart';
import 'package:smart_hospital/screens/appointment_confirmation_screen.dart';
import 'package:smart_hospital/screens/appointment_history_screen.dart';
import 'package:smart_hospital/screens/appointment_success_screen.dart';
import 'package:smart_hospital/screens/date_selection_screen.dart';
import 'package:smart_hospital/screens/doctor_dashboard_screen.dart';
import 'package:smart_hospital/screens/manage_doctor_screen.dart';
import 'package:smart_hospital/screens/admin/manage_patients_screen.dart';
import 'package:smart_hospital/screens/admin/manage_doctor_requests_screen.dart';
import 'package:smart_hospital/screens/doctor_detail_screen.dart';
import 'package:smart_hospital/screens/doctor_list_screen.dart';
import 'package:smart_hospital/screens/edit_medicine_screen.dart';
import 'package:smart_hospital/screens/forgot_password_screen.dart';
import 'package:smart_hospital/screens/home_dashboard_screen.dart';
import 'package:smart_hospital/screens/live_queue_screen.dart';
import 'package:smart_hospital/screens/login_screen.dart';
import 'package:smart_hospital/screens/manage_queue_screen.dart';
import 'package:smart_hospital/screens/medicine_reminder_screen.dart';
import 'package:smart_hospital/screens/notification_screen.dart';
import 'package:smart_hospital/screens/profile_screen.dart';
import 'package:smart_hospital/screens/queue_history_screen.dart';
import 'package:smart_hospital/screens/search_doctor_screen.dart';
import 'package:smart_hospital/screens/setting_screen.dart';
import 'package:smart_hospital/screens/signup_screen.dart';
import 'package:smart_hospital/screens/splash_screen.dart';
import 'package:smart_hospital/screens/time_slot_selection_screen.dart';
import 'package:smart_hospital/screens/total_detailed_screen.dart';
import 'package:smart_hospital/screens/await_approval_screen.dart';
import 'package:smart_hospital/screens/ai_assistant_screen.dart'; // Import added
import '../models/appointment.dart';
import '../models/doctor.dart';
import '../models/medicine.dart';
import 'package:smart_hospital/screens/payment/payment_screen.dart';
import 'package:smart_hospital/screens/payment/payment_success.dart';
import 'package:smart_hospital/screens/payment/payment_failed.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding1 = '/onboarding1';
  static const String onboarding2 = '/onboarding2';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String doctorList = '/doctor-list';
  static const String doctorDetail = '/doctor-detail';
  static const String searchDoctor = '/search-doctor';
  static const String appointmentBooking = '/book-appointment';
  static const String dateSelection = '/select-date';
  static const String timeSlotSelection = '/select-time';
  static const String appointmentConfirmation = '/confirm-appointment';
  static const String appointmentSuccess = '/appointment-success';
  static const String appointmentHistory = '/appointment-history';
  static const String liveQueue = '/live-queue';
  static const String tokenDetail = '/token-detail';
  static const String queueHistory = '/queue-history';
  static const String medicineReminder = '/medicine-reminder';
  static const String addMedicine = '/add-medicine';
  static const String editMedicine = '/edit-medicine';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String awaitApproval = '/await-approval';
  static const String manageDoctorRequests = '/manage-doctor-requests';
  static const String manageDoctors = '/manage-doctors';
  static const String manageQueue = '/manage-queue';
  static const String doctorDashboard = '/doctor-dashboard';
  static const String doctorProfile = '/doctor-profile';
  static const String adminDashboard = '/admin-dashboard';
  static const String managePatients = '/manage-patients';
  static const String aiAssistant = '/ai-assistant'; // Name added

  static const String payment = '/payment';
  static const String paymentSuccess = '/payment-success';
  static const String paymentFailed = '/payment-failed';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    WidgetBuilder errorBuilder(String message) {
      return (_) => Scaffold(
        appBar: AppBar(title: const Text('Route Error')),
        body: Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    switch (settings.name) {
      case splash: return _fadeRoute(const SplashScreen());
      case onboarding1: return _slideRoute(const Onboarding1Screen(), AxisDirection.left);
      case onboarding2: return _slideRoute(const Onboarding2Screen(), AxisDirection.left);
      case login: return _fadeRoute(const LoginScreen());
      case signup: return _slideRoute(const SignUpScreen(), AxisDirection.up);
      case forgotPassword: return _slideRoute(const ForgotPasswordScreen(), AxisDirection.left);
      case home: return _fadeRoute(const HomeDashboardScreen());
      case doctorList: return _slideRoute(const DoctorListScreen(), AxisDirection.left);
      case doctorDetail:
        if (settings.arguments is Doctor) {
          return _slideRoute(DoctorDetailScreen(doctor: settings.arguments as Doctor), AxisDirection.left);
        }
        return MaterialPageRoute(builder: errorBuilder('Doctor details missing.'));
      case searchDoctor: return _fadeRoute(const SearchDoctorScreen());
      case appointmentBooking:
        if (settings.arguments is Doctor) {
          return _slideRoute(AppointmentBookingScreen(doctor: settings.arguments as Doctor), AxisDirection.up);
        }
        return MaterialPageRoute(builder: errorBuilder('Doctor details missing.'));
      case dateSelection: return _slideRoute(const DateSelectionScreen(), AxisDirection.left);
      case timeSlotSelection: return _slideRoute(const TimeSlotSelectionScreen(), AxisDirection.left);
      case appointmentConfirmation: return _slideRoute(const AppointmentConfirmationScreen(), AxisDirection.left);
      case appointmentSuccess:
        if (settings.arguments is Appointment) {
          return _fadeRoute(AppointmentSuccessScreen(appointment: settings.arguments as Appointment));
        }
        return MaterialPageRoute(builder: errorBuilder('Appointment data missing.'));
      case payment: return _slideRoute(const PaymentScreen(), AxisDirection.left);
      case paymentSuccess:
        if (settings.arguments is Appointment) {
          return _fadeRoute(PaymentSuccessScreen(appointment: settings.arguments as Appointment));
        }
        return MaterialPageRoute(builder: errorBuilder('Payment details missing.'));
      case paymentFailed: return _slideRoute(PaymentFailedScreen(errorMessage: settings.arguments as String?), AxisDirection.left);
      case appointmentHistory: return _slideRoute(const AppointmentHistoryScreen(), AxisDirection.left);
      case liveQueue:
        if (settings.arguments is String) {
          return _slideRoute(LiveQueueScreen(appointmentId: settings.arguments as String), AxisDirection.left);
        }
        return MaterialPageRoute(builder: errorBuilder('Appointment ID missing.'));
      case tokenDetail:
        if (settings.arguments is Appointment) {
          return _slideRoute(TokenDetailScreen(appointment: settings.arguments as Appointment), AxisDirection.left);
        }
        return MaterialPageRoute(builder: errorBuilder('Appointment details missing.'));
      case queueHistory: return _slideRoute(const QueueHistoryScreen(), AxisDirection.left);
      case medicineReminder: return _slideRoute(const MedicineReminderScreen(), AxisDirection.left);
      case addMedicine: return _slideRoute(const AddMedicineScreen(), AxisDirection.up);
      case editMedicine:
        if (settings.arguments is Medicine) {
          return _slideRoute(EditMedicineScreen(medicine: settings.arguments as Medicine), AxisDirection.up);
        }
        return MaterialPageRoute(builder: errorBuilder('Medicine details missing.'));
      case notifications: return _slideRoute(const NotificationScreen(), AxisDirection.down);
      case profile:
        return _slideRoute(
          Builder(builder: (context) {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            if (authProvider.isDoctor || authProvider.user?.role == 'doctor') return const DoctorProfileScreen();
            return const ProfileScreen();
          }),
          AxisDirection.right,
        );
      case AppRoutes.settings: return _slideRoute(const SettingsScreen(), AxisDirection.left);
      case manageDoctorRequests: return _slideRoute(const ManageDoctorRequestsScreen(), AxisDirection.left);
      case manageDoctors: return _slideRoute(const ManageDoctorsScreen(), AxisDirection.left);
      case manageQueue: return _slideRoute(const ManageQueueScreen(), AxisDirection.left);
      case doctorDashboard: return _fadeRoute(const DoctorDashboardScreen());
      case awaitApproval: return _fadeRoute(const AwaitApprovalScreen());
      case doctorProfile: return _fadeRoute(const DoctorProfileScreen());
      case adminDashboard: return _fadeRoute(const AdminDashboardScreen());
      case managePatients: return _slideRoute(const ManagePatientsScreen(), AxisDirection.left);
      case aiAssistant: return _fadeRoute(const AiAssistantScreen()); // Case added
      default: return MaterialPageRoute(builder: (_) => Scaffold(body: Center(child: Text('No route defined for ${settings.name}'))));
    }
  }

  // Animation methods remain same...
  static PageRouteBuilder _fadeRoute(Widget child) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static PageRouteBuilder _slideRoute(Widget child, AxisDirection direction) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        Offset begin;
        switch (direction) {
          case AxisDirection.left: begin = const Offset(1.0, 0.0); break;
          case AxisDirection.right: begin = const Offset(-1.0, 0.0); break;
          case AxisDirection.up: begin = const Offset(0.0, 1.0); break;
          case AxisDirection.down: begin = const Offset(0.0, -1.0); break;
        }
        return SlideTransition(position: animation.drive(Tween(begin: begin, end: Offset.zero).chain(CurveTween(curve: Curves.easeInOutCubic))), child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}