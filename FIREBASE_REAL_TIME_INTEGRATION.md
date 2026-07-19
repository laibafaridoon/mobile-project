# Firebase Real-Time Integration Complete Guide

## 📋 Table of Contents
1. [Firestore Database Structure](#firestore-database-structure)
2. [Files to Update](#files-to-update)
3. [Step-by-Step Changes](#step-by-step-changes)
4. [Firestore Security Rules](#firestore-security-rules)
5. [Testing Guide](#testing-guide)

---

## 🗄️ Firestore Database Structure

Your Firebase project needs these exact collections and fields:

### Collection: `users`
Each user document when signup/login:
```
/users/{uid}
  ├─ uid: string (auto from Firebase Auth)
  ├─ name: string (patient name)
  ├─ email: string (patient email)
  ├─ age: number (patient age)
  ├─ gender: string (Male/Female/Other)
  ├─ bloodGroup: string (O+, A-, etc.)
  ├─ medicalHistory: array (strings of conditions)
  ├─ emergencyContact: string (phone number)
  ├─ address: string (home address)
  ├─ profilePictureUrl: string (image URL)
  ├─ phone: string (contact number)
  ├─ createdAt: timestamp (auto-added by Firebase)
  └─ updatedAt: timestamp (auto-added by Firebase)
```

**Example:**
```json
{
  "name": "Ali Ahmed",
  "email": "ali@example.com",
  "age": 28,
  "gender": "Male",
  "bloodGroup": "O+",
  "medicalHistory": ["Hypertension", "Allergy to Penicillin"],
  "emergencyContact": "+92 300 1234567",
  "address": "123 Health Street, Karachi",
  "profilePictureUrl": "https://...",
  "phone": "+92 300 1234567",
  "createdAt": Timestamp,
  "updatedAt": Timestamp
}
```

### Collection: `appointments`
Appointment records linked to patients:
```
/appointments/{appointmentId}
  ├─ id: string (auto-generated or UUID)
  ├─ patientId: string (user UID)
  ├─ patientName: string
  ├─ doctorId: string
  ├─ doctorName: string
  ├─ doctorImageUrl: string
  ├─ doctorSpecialization: string
  ├─ date: timestamp
  ├─ timeSlot: string (e.g., "10:00 AM")
  ├─ tokenNumber: string
  ├─ queuePosition: number
  ├─ estimatedWaitTime: number (minutes)
  ├─ roomNumber: string
  ├─ status: string (Pending/Confirmed/Waiting/In Progress/Completed/Cancelled)
  ├─ notes: string (optional)
  ├─ chatEnabled: boolean
  ├─ createdAt: timestamp
  └─ updatedAt: timestamp
```

### Collection: `messages`
Doctor-patient chat messages:
```
/messages/{conversationId}/{messageId}
  ├─ id: string
  ├─ conversationId: string
  ├─ senderId: string (doctor or patient UID)
  ├─ senderName: string
  ├─ senderRole: string (doctor/patient)
  ├─ receiverId: string
  ├─ appointmentId: string (linked appointment)
  ├─ message: string
  ├─ timestamp: timestamp
  ├─ read: boolean
  ├─ type: string (text/prescription)
  └─ prescriptionData: map (if type = prescription)
```

### Collection: `doctors`
Doctor profiles:
```
/doctors/{doctorId}
  ├─ id: string
  ├─ name: string
  ├─ specialization: string
  ├─ qualification: string
  ├─ experience: number
  ├─ imageUrl: string
  ├─ rating: number (0-5)
  ├─ reviewCount: number
  ├─ availableSlots: map (day -> [times])
  ├─ isAvailable: boolean
  ├─ room: string
  ├─ phone: string
  ├─ bio: string
  └─ createdAt: timestamp
```

### Collection: `medicines`
Patient medicine prescriptions:
```
/medicines/{medicineId}
  ├─ id: string
  ├─ patientId: string (user UID)
  ├─ doctorId: string
  ├─ medicineName: string
  ├─ dosage: string (e.g., "500mg")
  ├─ frequency: string (e.g., "3 times daily")
  ├─ startDate: timestamp
  ├─ endDate: timestamp
  ├─ reason: string (diagnosis)
  ├─ sideEffects: array (strings)
  ├─ isTaken: boolean (compliance tracking)
  ├─ takenAt: timestamp (when last taken)
  └─ createdAt: timestamp
```

### Collection: `notifications`
Notification records:
```
/notifications/{notificationId}
  ├─ id: string
  ├─ userId: string (recipient UID)
  ├─ title: string
  ├─ body: string
  ├─ type: string (appointment/queue/medicine/chat)
  ├─ relatedId: string (appointment/message ID)
  ├─ read: boolean
  ├─ createdAt: timestamp
  └─ data: map (additional data)
```

---

## 📝 Files to Update

### Priority Order:
1. **auth_service.dart** ✅ (Already handles signup/login storage)
2. **auth_provider.dart** ✅ (Already loads user on init)
3. **appointment_service.dart** - Needs real-time listeners
4. **doctor_service.dart** - Needs real-time listeners
5. **medicine_service.dart** - Needs real-time listeners
6. **chat_provider.dart** - Already implemented
7. **notification_service.dart** - Already implemented

---

## 🔄 Step-by-Step Changes

### ✅ STEP 1: Auth Service (ALREADY CORRECT)

Your `auth_service.dart` is already correctly implemented. It:
- ✅ Creates user in Firebase Auth on signup
- ✅ Saves user profile to Firestore `users` collection
- ✅ Fetches user profile from Firestore on login
- ✅ Handles profile updates in Firestore

**No changes needed** - It's already complete!

---

### ✅ STEP 2: Auth Provider (ALREADY CORRECT)

Your `auth_provider.dart` is already correctly implemented. It:
- ✅ Loads current user on init
- ✅ Handles login/register with auth_service
- ✅ Stores user in state and notifies listeners
- ✅ Logs out properly

**No changes needed** - It's already complete!

---

### 📝 STEP 3: Update appointment_provider.dart

**File:** `/lib/providers/appointment_provider.dart`

Replace entire file with:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';

class AppointmentProvider with ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService();
  
  List<Appointment> _userAppointments = [];
  List<Appointment> _allAppointments = [];
  bool _isLoading = false;
  String? _error;
  
  List<Appointment> get userAppointments => _userAppointments;
  List<Appointment> get allAppointments => _allAppointments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  AppointmentProvider() {
    _initializeListener();
  }
  
  // Initialize real-time listener for user's appointments
  void _initializeListener() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _appointmentService.listenToUserAppointments(userId).listen(
        (appointments) {
          _userAppointments = appointments;
          _error = null;
          notifyListeners();
        },
        onError: (e) {
          _error = e.toString();
          notifyListeners();
        },
      );
    }
  }
  
  // Book appointment
  Future<bool> bookAppointment({
    required String doctorId,
    required String doctorName,
    required String doctorImageUrl,
    required String specialization,
    required DateTime appointmentDate,
    required String timeSlot,
  }) async {
    _setLoading(true);
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final userName = FirebaseAuth.instance.currentUser?.email ?? 'Patient';
      
      if (userId == null) throw Exception('User not authenticated');
      
      await _appointmentService.bookAppointment(
        patientId: userId,
        patientName: userName,
        doctorId: doctorId,
        doctorName: doctorName,
        doctorImageUrl: doctorImageUrl,
        doctorSpecialization: specialization,
        appointmentDate: appointmentDate,
        timeSlot: timeSlot,
      );
      
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Get appointment by ID
  Future<Appointment?> getAppointment(String appointmentId) async {
    try {
      return await _appointmentService.getAppointmentById(appointmentId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  // Update appointment status
  Future<bool> updateAppointmentStatus(
    String appointmentId,
    String newStatus,
  ) async {
    _setLoading(true);
    try {
      await _appointmentService.updateAppointmentStatus(
        appointmentId,
        newStatus,
      );
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Cancel appointment
  Future<bool> cancelAppointment(String appointmentId) async {
    _setLoading(true);
    try {
      await _appointmentService.cancelAppointment(appointmentId);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
```

---

### 📝 STEP 4: Update doctor_provider.dart

**File:** `/lib/providers/doctor_provider.dart`

Replace entire file with:

```dart
import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../services/doctor_service.dart';

class DoctorProvider with ChangeNotifier {
  final DoctorService _doctorService = DoctorService();
  
  List<Doctor> _allDoctors = [];
  List<Doctor> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  
  List<Doctor> get allDoctors => _allDoctors;
  List<Doctor> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  DoctorProvider() {
    _initializeListener();
  }
  
  // Initialize real-time listener for all doctors
  void _initializeListener() {
    _doctorService.listenToDoctors().listen(
      (doctors) {
        _allDoctors = doctors;
        _searchResults = doctors;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }
  
  // Search doctors by name or specialization
  void searchDoctors(String query) {
    if (query.isEmpty) {
      _searchResults = _allDoctors;
    } else {
      _searchResults = _allDoctors
          .where((doc) =>
              doc.name.toLowerCase().contains(query.toLowerCase()) ||
              doc.specialization.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
  
  // Filter by specialization
  void filterBySpecialization(String specialization) {
    if (specialization.isEmpty) {
      _searchResults = _allDoctors;
    } else {
      _searchResults = _allDoctors
          .where((doc) =>
              doc.specialization.toLowerCase() ==
              specialization.toLowerCase())
          .toList();
    }
    notifyListeners();
  }
  
  // Get doctor by ID
  Future<Doctor?> getDoctorById(String doctorId) async {
    try {
      return await _doctorService.getDoctorById(doctorId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  // Rate doctor
  Future<bool> rateDoctor(String doctorId, double rating) async {
    _setLoading(true);
    try {
      await _doctorService.rateDoctor(doctorId, rating);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
```

---

### 📝 STEP 5: Update medicine_provider.dart

**File:** `/lib/providers/medicine_provider.dart`

Replace entire file with:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/medicine.dart';
import '../services/medicine_service.dart';

class MedicineProvider with ChangeNotifier {
  final MedicineService _medicineService = MedicineService();
  
  List<Medicine> _userMedicines = [];
  bool _isLoading = false;
  String? _error;
  
  List<Medicine> get userMedicines => _userMedicines;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  MedicineProvider() {
    _initializeListener();
  }
  
  // Initialize real-time listener for user's medicines
  void _initializeListener() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _medicineService.listenToUserMedicines(userId).listen(
        (medicines) {
          _userMedicines = medicines;
          _error = null;
          notifyListeners();
        },
        onError: (e) {
          _error = e.toString();
          notifyListeners();
        },
      );
    }
  }
  
  // Add medicine
  Future<bool> addMedicine({
    required String medicineName,
    required String dosage,
    required String frequency,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    required String doctorId,
    List<String> sideEffects = const [],
  }) async {
    _setLoading(true);
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');
      
      await _medicineService.addMedicine(
        patientId: userId,
        medicineName: medicineName,
        dosage: dosage,
        frequency: frequency,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        doctorId: doctorId,
        sideEffects: sideEffects,
      );
      
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Mark medicine as taken
  Future<bool> markAsTaken(String medicineId) async {
    _setLoading(true);
    try {
      await _medicineService.markAsTaken(medicineId);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Get upcoming medicines
  List<Medicine> getUpcomingMedicines() {
    return _userMedicines
        .where((m) => m.endDate.isAfter(DateTime.now()))
        .toList();
  }
  
  // Get completed medicines
  List<Medicine> getCompletedMedicines() {
    return _userMedicines
        .where((m) => m.endDate.isBefore(DateTime.now()))
        .toList();
  }
  
  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
```

---

## 🔐 Firestore Security Rules

**Set these rules in Firebase Console → Firestore → Rules:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection - Users can read/write only their own document
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }
    
    // Appointments collection
    match /appointments/{appointmentId} {
      // Patients can read their own appointments
      allow read: if resource.data.patientId == request.auth.uid;
      // Doctors can read appointments assigned to them
      allow read: if resource.data.doctorId == request.auth.uid;
      // Patients can create appointments
      allow create: if request.auth != null && request.resource.data.patientId == request.auth.uid;
      // Update own appointments
      allow update: if request.auth.uid == resource.data.patientId || request.auth.uid == resource.data.doctorId;
    }
    
    // Messages collection
    match /messages/{conversationId}/{messageId} {
      allow read, write: if request.auth.uid == resource.data.senderId || 
                           request.auth.uid == resource.data.receiverId;
    }
    
    // Doctors collection - Public read
    match /doctors/{doctorId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == doctorId;
    }
    
    // Medicines collection
    match /medicines/{medicineId} {
      allow read, write: if resource.data.patientId == request.auth.uid;
    }
    
    // Notifications collection
    match /notifications/{notificationId} {
      allow read: if resource.data.userId == request.auth.uid;
      allow write: if request.auth != null;
    }
  }
}
```

---

## ✅ Testing Guide

### Test 1: Signup and Save to Firestore

1. Open your app
2. Go to Login screen
3. Click "Sign Up"
4. Fill in:
   - Name: Ali Ahmed
   - Email: ali@example.com
   - Password: 12345678
   - Age: 28
   - Gender: Male
   - Blood Group: O+
5. Click Sign Up

**Check in Firebase Console:**
- Go to Firestore → `users` collection
- You should see document with UID containing all data

---

### Test 2: Login and Fetch Data

1. Close app
2. Open app again
3. Login with ali@example.com / 12345678

**Expected:**
- User should be logged in
- User profile should load from Firestore
- All user data appears in app

---

### Test 3: Real-Time Sync

1. Login with one account
2. Book an appointment
3. Open Firebase Console in browser
4. Check `appointments` collection
5. Change `queuePosition` to 1 in Console

**Expected:**
- Appointment status updates in real-time in app
- UI automatically reflects Firestore changes

---

### Test 4: Medicines Real-Time

1. Navigate to Medicines
2. Add a medicine
3. Check Firebase → `medicines` collection
4. Update `frequency` in Console

**Expected:**
- Medicine appears in app list
- Changes sync real-time

---

## 🎯 Summary of What's Already Done

✅ **auth_service.dart** - Signup creates user in Firebase Auth + Firestore
✅ **auth_provider.dart** - Loads user on init
✅ **firebase_service.dart** - Real-time listeners ready
✅ **chat_provider.dart** - Real-time chat implemented
✅ **notification_service.dart** - Firebase notifications ready

---

## 📌 Next Steps

1. **Update 3 files:** appointment_provider, doctor_provider, medicine_provider (code above)
2. **Create Firestore collections** with structure shown above
3. **Apply Security Rules** from the section above
4. **Test signup/login** - Check Firestore for saved data
5. **Test real-time** - Make changes in Console, see them in app

---

## 🚀 After This Setup

Your app will have:
- ✅ Real signup/login with Firebase Auth
- ✅ User data saved in Firestore
- ✅ Real-time appointment syncing
- ✅ Real-time doctor list
- ✅ Real-time medicine tracking
- ✅ Doctor-patient chat with real-time messages
- ✅ Push notifications

**Everything production-ready!**
