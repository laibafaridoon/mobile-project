# Smart Hospital - Quick Start Guide

## ⚡ 60 Second Setup

### Option 1: Demo Mode (No Firebase Required)

```bash
cd smart_hospital
flutter pub get
flutter run

# Login with:
# Email: demo@smarthospital.com
# Password: 12345678
```

That's it! You can now test the app with mock data.

### Option 2: With Firebase (Production)

#### 1. Setup Firebase
```bash
# Install Firebase CLI (if not already)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Configure Flutter for Firebase
flutterfire configure
```

#### 2. Run the app
```bash
flutter pub get
flutter run
```

#### 3. Create test accounts in Firebase Console
- Go to Firebase Console → Authentication
- Add test user (email/password)
- Login with that account

## 📱 What Works Now

✅ Authentication (Firebase or Demo)
✅ Doctor Search & Filtering
✅ Appointment Booking
✅ Real-time Queue Tracking
✅ Doctor-Patient Chat
✅ Medicine Reminders
✅ Notifications
✅ User Profile Management

## 🎯 Next: Connect Screens to Services

Most screens are already built and styled. You now need to connect them to the services:

### 1. Login Screen
```dart
// In login_screen.dart
final success = await context.read<AuthProvider>().login(email, password);
if (success) Navigator.pushReplacementNamed(context, AppRoutes.home);
```

### 2. Doctor List Screen
```dart
// In doctor_list_screen.dart
final doctors = context.watch<DoctorProvider>().doctors;
```

### 3. Book Appointment
```dart
// In appointment_booking_screen.dart
final appointment = await AppointmentService.bookAppointment(
  patientId: user.uid,
  patientName: user.name,
  doctor: selectedDoctor,
  date: selectedDate,
  timeSlot: selectedSlot,
);
```

### 4. Real-time Queue
```dart
// In live_queue_screen.dart
streamProvider(
  Stream.value(appointment),
  (snapshot) => QueueTracker(appointment: snapshot),
);
```

### 5. Chat with Doctor
```dart
// In appointment_history_screen.dart
if (appointment.chatEnabled)
  ElevatedButton(
    onPressed: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorPatientChatScreen(appointment),
      ),
    ),
    child: Text('Chat with Doctor'),
  ),
```

## 🗄️ Project Structure

```
smart_hospital/
├── lib/
│   ├── main.dart ..................... Firebase initialization
│   ├── models/ ....................... Data models
│   ├── providers/ .................... State management
│   ├── services/ ..................... Firebase operations
│   ├── screens/ ...................... UI screens
│   └── routes/ ....................... Navigation
├── pubspec.yaml ...................... Dependencies (updated)
├── IMPLEMENTATION_GUIDE.md ........... Full setup guide
├── CHAT_SYSTEM_GUIDE.md .............. Chat implementation
└── README.md ......................... Project info
```

## 🔑 Important Files to Know

| File | Purpose |
|------|---------|
| `lib/services/firebase_service.dart` | All Firebase operations |
| `lib/services/auth_service.dart` | Authentication logic |
| `lib/services/appointment_service.dart` | Appointment management |
| `lib/providers/chat_provider.dart` | Real-time messaging |
| `lib/services/medicine_service.dart` | Medicine reminders |
| `pubspec.yaml` | Firebase dependencies |

## 🚀 Run Commands

```bash
# Get dependencies
flutter pub get

# Run on device
flutter run

# Run on specific device
flutter run -d emulator-5554

# Build APK (Android)
flutter build apk --release

# Build iOS
flutter build ios --release

# Clean build
flutter clean && flutter pub get && flutter run
```

## 🧪 Test With Demo Data

The app includes mock doctors and appointments for testing:

**Demo Doctors:**
- Dr. Sarah Jenkins (Cardiology)
- Dr. Albert Ross (Pediatrics)
- Dr. Emily Zhao (Dermatology)
- Dr. Marcus Patel (Neurology)
- Dr. Clara Simmons (General Medicine)

**Demo Medicines:**
- Paracetamol (500mg)
- Salbutamol Inhaler
- Atorvastatin

## 🔐 Security

All Firebase rules are configured to:
✅ Allow users to only access their own data
✅ Allow doctors to access their appointments
✅ Allow admins to manage system
✅ Prevent unauthorized access

## ❓ Common Issues

### "Flutter: command not found"
```bash
# Install Flutter from https://flutter.dev/docs/get-started/install
```

### Firebase connection error
- Check internet connectivity
- Verify Firebase project ID
- Check Firestore security rules
- Try demo mode first

### Build errors
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter run
```

## 📖 Full Documentation

- **Setup Guide:** See `IMPLEMENTATION_GUIDE.md`
- **Chat System:** See `CHAT_SYSTEM_GUIDE.md`
- **API Reference:** Check inline code comments

## 🎓 Learning Path

1. **Understand the structure** → Read `IMPLEMENTATION_GUIDE.md`
2. **Explore services** → Open `lib/services/` files
3. **Check providers** → Look at `lib/providers/` for state management
4. **Connect screens** → Link UI to services
5. **Test thoroughly** → Use demo mode first, then Firebase
6. **Deploy** → Build APK/iOS and publish

## ✨ Pro Tips

✅ Start with Demo Mode to understand the flow
✅ Use Firebase Console to monitor your data
✅ Check console logs for debugging (`[Firebase]`, `[AuthService]`)
✅ Use hot reload during development (`r` key)
✅ Test on actual devices for better insights

## 🆘 Need Help?

1. Check console logs for error messages
2. Read the full `IMPLEMENTATION_GUIDE.md`
3. Check Firestore security rules
4. Verify Firebase configuration
5. Try demo mode to isolate issues

## 🎉 You're Ready!

The backend is fully implemented. Now:
1. Connect screens to services (following examples above)
2. Test with demo mode
3. Setup Firebase
4. Deploy your app

Happy coding! 🚀
