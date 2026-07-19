import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserProfile? _user;
  bool _isAdmin = false;
  bool _isDoctor = false;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfile? get user => _user;
  bool get isAdmin => _isAdmin;
  bool get isDoctor => _isDoctor;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  AuthService get authService => _authService;

  AuthProvider() {
    _user = _authService.currentUser;
    _isAdmin = _authService.isAdmin;
    _isDoctor = _authService.isDoctor;
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final loggedInUser = await _authService.signIn(email, password);
      if (loggedInUser != null) {
        _user = loggedInUser;
        _isAdmin = _authService.isAdmin;
        _isDoctor = _authService.isDoctor;
        print('[AuthProvider] Login successful for: ${loggedInUser.email}');
        notifyListeners();
        return true;
      }
      _errorMessage = 'Login failed. Please check your credentials.';
      return false;
    } catch (e) {
      _errorMessage = _parseFirebaseError(e.toString());
      print('[AuthProvider] Login error: $_errorMessage');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required int age,
    required String gender,
    required String bloodGroup,
    String role = 'patient',
    Map<String, dynamic>? doctorDetails,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final newUser = await _authService.signUp(
        name: name,
        email: email,
        password: password,
        age: age,
        gender: gender,
        bloodGroup: bloodGroup,
        role: role,
        doctorDetails: doctorDetails,
      );
      if (newUser != null) {
        _user = newUser;
        _isAdmin = false;
        _isDoctor = false; // Doctor will be marked true only after admin approval
        print('[AuthProvider] Registration successful for: ${newUser.email}');
        notifyListeners();
        return true;
      }
      _errorMessage = 'Registration failed. Please try again.';
      return false;
    } catch (e) {
      _errorMessage = _parseFirebaseError(e.toString());
      print('[AuthProvider] Registration error: $_errorMessage');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _user = null;
      _isAdmin = false;
      _isDoctor = false;
      _errorMessage = null;
      print('[AuthProvider] User logged out successfully');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Logout failed: $e';
      print('[AuthProvider] Logout error: $_errorMessage');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.sendPasswordResetEmail(email);
      print('[AuthProvider] Password reset email sent to: $email');
    } catch (e) {
      _errorMessage = _parseFirebaseError(e.toString());
      print('[AuthProvider] Password reset error: $_errorMessage');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile(UserProfile updatedProfile) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _user = await _authService.updateProfile(updatedProfile);
      print('[AuthProvider] Profile updated successfully');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Profile update failed: $e';
      print('[AuthProvider] Update profile error: $_errorMessage');
    } finally {
      _setLoading(false);
    }
  }

  // Parse Firebase error messages
  String _parseFirebaseError(String error) {
    if (error.contains('user-not-found')) {
      return 'User not found. Please sign up first.';
    } else if (error.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (error.contains('email-already-in-use')) {
      return 'This email is already registered. Please login instead.';
    } else if (error.contains('weak-password')) {
      return 'Password is too weak. Use at least 6 characters.';
    } else if (error.contains('invalid-email')) {
      return 'Invalid email address.';
    } else if (error.contains('network')) {
      return 'Network error. Please check your connection.';
    } else {
      return 'Error: ${error.replaceAll('Exception: ', '')}';
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
