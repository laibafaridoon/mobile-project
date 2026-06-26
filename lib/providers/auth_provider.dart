import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserProfile? _user;
  bool _isAdmin = false;
  bool _isLoading = false;
  UserProfile? get user => _user;
  bool get isAdmin => _isAdmin;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  AuthProvider() {
    _user = _authService.currentUser;
    _isAdmin = _authService.isAdmin;
  }
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final loggedInUser = await _authService.signIn(email, password);
      if (loggedInUser != null) {
        _user = loggedInUser;
        _isAdmin = _authService.isAdmin;
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
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
  }) async {
    _setLoading(true);
    try {
      final newUser = await _authService.signUp(
        name: name,
        email: email,
        password: password,
        age: age,
        gender: gender,
        bloodGroup: bloodGroup,
      );
      if (newUser != null) {
        _user = newUser;
        _isAdmin = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
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
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    _setLoading(true);
    try {
      await _authService.sendPasswordResetEmail(email);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile(UserProfile updatedProfile) async {
    _setLoading(true);
    try {
      _user = await _authService.updateProfile(updatedProfile);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
