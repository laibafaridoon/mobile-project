import 'dart:async';
import '../models/user_profile.dart';

class AuthService {
  // Shared simulation state
  static UserProfile? _currentUser = UserProfile(
    uid: 'patient_123',
    name: 'John Doe',
    email: 'johndoe@example.com',
    age: 28,
    gender: 'Male',
    bloodGroup: 'O+',
    medicalHistory: ['Mild Asthma', 'Allergy to Penicillin'],
    emergencyContact: '+1 (555) 019-2834',
    address: '123 Health Ave, Medical City, MC 90210',
    profilePictureUrl:
        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=200',
  );
  static bool _isAdmin = false;
  UserProfile? get currentUser => _currentUser;
  bool get isAdmin => _isAdmin;
  Future<UserProfile?> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (email.toLowerCase() == 'admin@hospital.com') {
      _isAdmin = true;
      _currentUser = UserProfile(
        uid: 'admin_001',
        name: 'Hospital Administrator',
        email: 'admin@hospital.com',
        age: 45,
        gender: 'Female',
        bloodGroup: 'A+',
        medicalHistory: [],
        emergencyContact: '+1 (555) 999-9999',
        address: 'Hospital Admin Block Room 102',
        profilePictureUrl:
            'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&q=80&w=200',
      );
      return _currentUser;
    }
    _isAdmin = false;
    _currentUser = UserProfile(
      uid: 'patient_123',
      name: 'John Doe',
      email: email,
      age: 28,
      gender: 'Male',
      bloodGroup: 'O+',
      medicalHistory: ['Mild Asthma', 'Allergy to Penicillin'],
      emergencyContact: '+1 (555) 019-2834',
      address: '123 Health Ave, Medical City, MC 90210',
      profilePictureUrl:
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=200',
    );
    return _currentUser;
  }

  Future<UserProfile?> signUp({
    required String name,
    required String email,
    required String password,
    required int age,
    required String gender,
    required String bloodGroup,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _isAdmin = false;
    _currentUser = UserProfile(
      uid: 'patient_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      age: age,
      gender: gender,
      bloodGroup: bloodGroup,
      medicalHistory: [],
      emergencyContact: '+1 (555) 000-0000',
      address: 'Update address in settings',
      profilePictureUrl:
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=200',
    );
    return _currentUser;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 400));
    _currentUser = null;
    _isAdmin = false;
  }

  Future<UserProfile> updateProfile(UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = profile;
    return profile;
  }
}
