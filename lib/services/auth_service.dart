import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_profile.dart';
import 'firebase_service.dart';

class AuthService {
  static UserProfile? _currentUser;
  static bool _isAdmin = false;
  static bool _isDoctor = false;

  // Demo credentials
  static const String DEMO_EMAIL = 'demo@smarthospital.com';
  static const String DEMO_PASSWORD = '12345678';

  UserProfile? get currentUser => _currentUser;
  bool get isAdmin => _isAdmin;
  bool get isDoctor => _isDoctor;

  AuthService() {
    _loadCurrentUser();
  }

  // Load current user from Firestore if authenticated
  Future<void> _loadCurrentUser() async {
    try {
      final user = FirebaseService.getCurrentUser();
      if (user != null) {
        final userDoc = await FirebaseService.getDocument(
          collection: 'users',
          docId: user.uid,
        );
        if (userDoc.exists) {
          _currentUser = UserProfile.fromMap(
            userDoc.data() as Map<String, dynamic>,
            user.uid,
          );
          // Check if user is admin
          final adminDoc = await FirebaseService.getDocument(
            collection: 'admins',
            docId: user.uid,
          );
          _isAdmin = adminDoc.exists;

          // Check if user is doctor
          final doctorDoc = await FirebaseService.getDocument(
            collection: 'doctors',
            docId: user.uid,
          );
          _isDoctor = doctorDoc.exists;
        }
      }
    } catch (e) {
      print('[AuthService] Error loading current user: $e');
    }
  }

  // Sign In
  Future<UserProfile?> signIn(String email, String password) async {
    try {
      print('[AuthService] Starting login for: $email');

      // Check for demo account
      if (email.toLowerCase() == DEMO_EMAIL && password == DEMO_PASSWORD) {
        print('[AuthService] Demo account login');
        return _createDemoUser();
      }

      // Hardcoded admin login (admin@gmail.com / admin123)
      if (email.toLowerCase() == 'admin@gmail.com' && password == 'admin123') {
        print('[AuthService] Hardcoded admin login');
        // Create a mock user profile for admin
        _currentUser = UserProfile(
          uid: 'admin_hardcoded',
          name: 'Admin User',
          email: email,
          age: 0,
          gender: 'Other',
          bloodGroup: 'N/A',
          medicalHistory: [],
          emergencyContact: '',
          address: '',
          profilePictureUrl: '',
          role: 'admin',
        );
        _isAdmin = true;
        _isDoctor = false;
        return _currentUser;
      }

      // Sign in with Firebase
      final userCredential = await FirebaseService.signIn(
        email: email,
        password: password,
      );

      if (userCredential != null) {
        print(
          '[AuthService] Firebase auth successful for: ${userCredential.uid}',
        );

        // Fetch user profile from Firestore
        final userDoc = await FirebaseService.getDocument(
          collection: 'users',
          docId: userCredential.uid,
        );

        if (userDoc.exists) {
          print('[AuthService] User profile found in Firestore');
          _currentUser = UserProfile.fromMap(
            userDoc.data() as Map<String, dynamic>,
            userCredential.uid,
          );

          // Check if admin
          try {
            final adminDoc = await FirebaseService.getDocument(
              collection: 'admins',
              docId: userCredential.uid,
            );
            _isAdmin = adminDoc.exists;
            if (_isAdmin) print('[AuthService] Admin user detected');
          } catch (e) {
            print('[AuthService] Admin check: $e');
            _isAdmin = false;
          }

          // Check if doctor
          try {
            final doctorDoc = await FirebaseService.getDocument(
              collection: 'doctors',
              docId: userCredential.uid,
            );
            _isDoctor = doctorDoc.exists;
            if (_isDoctor) print('[AuthService] Doctor user detected');
          } catch (e) {
            print('[AuthService] Doctor check: $e');
            _isDoctor = false;
          }

          return _currentUser;
        } else {
          print('[AuthService] User profile not found in Firestore');
          throw Exception('User profile not found. Please sign up first.');
        }
      }
      return null;
    } catch (e) {
      print('[AuthService] Sign In Error: $e');
      rethrow;
    }
  }

  // Sign Up
  Future<UserProfile?> signUp({
    required String name,
    required String email,
    required String password,
    required int age,
    required String gender,
    required String bloodGroup,
    String role = 'patient',
    Map<String, dynamic>? doctorDetails,
  }) async {
    try {
      print('[AuthService] Starting signup for: $email');

      // Create Firebase user
      final user = await FirebaseService.signUp(
        email: email,
        password: password,
      );

      if (user != null) {
        print('[AuthService] Firebase user created: ${user.uid}');

        // If role is doctor, create a pending request in 'doctor_requests' collection
        if (role == 'doctor' && doctorDetails != null) {
          final Map<String, dynamic> requestData = {

  'uid': user.uid,

  'name': name,

  'email': email,

  'role': 'doctor',

  'status': 'pending',

  'qualification':
      doctorDetails['qualification'],

  'specialization':
      doctorDetails['specialization'],

  'experience':
      doctorDetails['experience'],

  'hospitalName':
      doctorDetails['hospitalName'],

  'consultationFee':
      doctorDetails['consultationFee'],

  'pmdcNumber':
      doctorDetails['pmdcNumber'],

  'availableDays':
      doctorDetails['availableDays'],

  'fromTime':
      doctorDetails['fromTime'],

  'toTime':
      doctorDetails['toTime'],

  'appointmentDuration':
      doctorDetails['appointmentDuration'],

  'maxPatientsPerDay':
      doctorDetails['maxPatientsPerDay'],

  'acceptsEmergency':
      doctorDetails['acceptsEmergency'],

  'rating': 0,

  'reviewsCount': 0,

  'isApproved': false,

  'createdAt':
      DateTime.now().toIso8601String(),

};

          await FirebaseService.setDocument(
            collection: 'doctor_requests',
            docId: user.uid,
            data: requestData,
          );

          // Doctor will be added to the 'doctors' collection after admin approval.
        } else {
          // No additional action required for other roles.
        }

        // Create user profile in Firestore with timestamp
        _currentUser = UserProfile(
          uid: user.uid,
          name: name,
          email: email,
          age: age,
          gender: gender,
          bloodGroup: bloodGroup,
          medicalHistory: [],
          emergencyContact: '',
          address: '',
          profilePictureUrl: '',
          role: role,
        );

        // Save to Firestore
        final userData = _currentUser!.toMap();
        userData['createdAt'] = DateTime.now().toIso8601String();
        userData['updatedAt'] = DateTime.now().toIso8601String();
        userData['uid'] = user.uid; // Store UID in document

        await FirebaseService.setDocument(
          collection: 'users',
          docId: user.uid,
          data: userData,
        );

        print('[AuthService] User profile saved to Firestore');
        _isAdmin = false;
        return _currentUser;
      }
      return null;
    } catch (e) {
      print('[AuthService] Sign Up Error: $e');
      rethrow;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await FirebaseService.signOut();
      _currentUser = null;
      _isAdmin = false;
    } catch (e) {
      print('[AuthService] Sign Out Error: $e');
      rethrow;
    }
  }

  // Approve a pending doctor request and move to doctors collection
  Future<void> approveDoctorRequest(String uid) async {
    try {
      final reqDoc = await FirebaseService.getDocument(
        collection: 'doctor_requests',
        docId: uid,
      );
      if (!reqDoc.exists) {
        print('[AuthService] No pending request for UID $uid');
        return;
      }
      final data = reqDoc.data() as Map<String, dynamic>;
      // Mark as approved and preserve fields
      data['status'] = 'approved';
      data['isApproved'] = true;
      // Ensure required fields exist
      data['id'] = uid;
      await FirebaseService.setDocument(
        collection: 'doctors',
        docId: uid,
        data: data,
      );
      await FirebaseService.updateDocument(
  collection: 'users',
  docId: uid,
  data: {
    'role': 'doctor',
  },
);
      // Delete the request document
      await FirebaseService.deleteDocument(
        collection: 'doctor_requests',
        docId: uid,
      );
      print('[AuthService] Doctor request approved for UID $uid');
    } catch (e) {
      print('[AuthService] Approve doctor error: $e');
      rethrow;
    }
  }

  // Reject a pending doctor request by deleting it
  Future<void> rejectDoctorRequest(String uid) async {
    try {
      await FirebaseService.deleteDocument(
        collection: 'doctor_requests',
        docId: uid,
      );
      print('[AuthService] Doctor request rejected for UID $uid');
    } catch (e) {
      print('[AuthService] Reject doctor error: $e');
      rethrow;
    }
  }

  // Send Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseService.sendPasswordReset(email);
    } catch (e) {
      print('[AuthService] Password Reset Error: $e');
      rethrow;
    }
  }

  // Update Profile
  Future<UserProfile?> updateProfile(UserProfile profile) async {
    try {
      await FirebaseService.updateDocument(
        collection: 'users',
        docId: profile.uid,
        data: profile.toMap(),
      );
      _currentUser = profile;
      return profile;
    } catch (e) {
      print('[AuthService] Update Profile Error: $e');
      rethrow;
    }
  }

  // Upload Profile Picture
  Future<String?> uploadProfilePicture(
    String userId,
    Uint8List imageBytes,
  ) async {
    try {
      if (userId.isEmpty) {
        throw Exception('User ID is empty');
      }

      final fileName =
          'profile_pictures/$userId/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseService.storage.ref().child(fileName);
      await ref.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final url = await ref.getDownloadURL();
      print('[AuthService] Profile picture uploaded: $url');
      return url;
    } catch (e) {
      print('[AuthService] Upload Profile Picture Error: $e');
      return null;
    }
  }

  // Create Demo User (for testing without Firebase)
  UserProfile _createDemoUser() {
    _currentUser = UserProfile(
      uid: 'demo_patient',
      name: 'Demo Patient',
      email: DEMO_EMAIL,
      age: 28,
      gender: 'Male',
      bloodGroup: 'O+',
      medicalHistory: ['Mild Asthma', 'Allergy to Penicillin'],
      emergencyContact: '+1 (555) 019-2834',
      address: '123 Health Ave, Medical City, MC 90210',
      profilePictureUrl:
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=200',
    );
    _isAdmin = false;
    return _currentUser!;
  }

  // Get Demo Account Credentials
  static Map<String, String> getDemoCredentials() {
    return {
      'email': DEMO_EMAIL,
      'password': DEMO_PASSWORD,
      'note': 'Demo Mode - No Firebase Required',
    };
  }
}
