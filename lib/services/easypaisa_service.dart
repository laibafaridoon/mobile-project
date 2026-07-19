import 'dart:convert';
import 'package:http/http.dart' as http;

class EasypaisaService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS/Web
  // You can customize this URL based on your server configuration.
  static String baseUrl = 'http://10.0.2.2:5000/api/payment';

  // Set this to true to simulate payment success/failure without running the Node.js backend.
  static bool useDemoMode = true;

  /// Initiates a mobile account payment request.
  /// If [useDemoMode] is true, it simulates a successful initiation after a short delay.
  Future<Map<String, dynamic>> createPayment({
    required String appointmentId,
    required String patientId,
    required String doctorId,
    required double amount,
    required String mobileNumber,
    required String email,
  }) async {
    if (useDemoMode) {
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulating a successful transaction response
      return {
        'success': true,
        'transactionId': 'TXN-${DateTime.now().millisecondsSinceEpoch}',
        'message': 'Payment request sent. Please approve the USSD prompt on your phone.',
        'amount': amount,
        'paymentReference': 'REF-${DateTime.now().microsecondsSinceEpoch.toString().substring(8)}',
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'appointmentId': appointmentId,
          'patientId': patientId,
          'doctorId': doctorId,
          'amount': amount,
          'mobileNumber': mobileNumber,
          'email': email,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'transactionId': data['transactionId'],
            'message': data['message'] ?? 'Payment request sent.',
            'amount': amount,
            'paymentReference': data['paymentReference'] ?? '',
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to create payment transaction.',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}. Please try again later.',
        };
      }
    } catch (e) {
      print('[EasypaisaService] Create Payment Exception: $e');
      return {
        'success': false,
        'message': 'Network error or timeout. Please check your internet connection.',
      };
    }
  }

  /// Verifies a payment's status with Easypaisa via the backend.
  Future<Map<String, dynamic>> verifyPayment({
    required String appointmentId,
    required String transactionId,
  }) async {
    if (useDemoMode) {
      await Future.delayed(const Duration(seconds: 2));
      return {
        'success': true,
        'status': 'Paid',
        'message': 'Payment verified successfully (Demo Mode).',
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'appointmentId': appointmentId,
          'transactionId': transactionId,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? false,
          'status': data['status'] ?? 'Failed',
          'message': data['message'] ?? 'Verification request processed.',
        };
      } else {
        return {
          'success': false,
          'status': 'Failed',
          'message': 'Verification failed on server side (${response.statusCode}).',
        };
      }
    } catch (e) {
      print('[EasypaisaService] Verify Payment Exception: $e');
      return {
        'success': false,
        'status': 'Failed',
        'message': 'Network error or timeout while verifying payment.',
      };
    }
  }

  /// Checks the status of an initiated payment.
  Future<Map<String, dynamic>> checkPaymentStatus(String appointmentId) async {
    if (useDemoMode) {
      return {
        'success': true,
        'status': 'Paid',
      };
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/status/$appointmentId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? false,
          'status': data['status'] ?? 'Pending',
        };
      } else {
        return {
          'success': false,
          'status': 'Pending',
        };
      }
    } catch (e) {
      print('[EasypaisaService] Check Status Exception: $e');
      return {
        'success': false,
        'status': 'Pending',
      };
    }
  }
}
