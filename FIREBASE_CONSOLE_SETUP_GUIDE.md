# Firebase Console Setup - Complete Guide

## Step-by-Step Configuration

### PART 1: Authentication Setup

#### Step 1.1: Enable Email/Password Authentication
```
1. Go to: Firebase Console > Your Project > Authentication
2. Click "Get Started" or "Sign-in method"
3. Click on "Email/Password" provider
4. Toggle "Enable" ON
5. Click "Save"

Result: ✅ Users can now sign up and login with email/password
```

#### Step 1.2: Testing Authentication
```
1. In Authentication tab, click "Users" 
2. You should see any users created in the app here
3. Each signup creates a new user record here automatically
```

---

### PART 2: Firestore Database Setup

#### Step 2.1: Create Firestore Database
```
1. Go to: Firebase Console > Firestore Database
2. Click "Create database"
3. Choose: "Start in test mode" (for development)
   - Production mode can be set later with security rules
4. Select your region (closest to your users)
5. Click "Create"
```

#### Step 2.2: Create Collections
```
After Firestore is created, create these collections by clicking "+" or "Start collection"
```

**Collection 1: users**
```
Collection ID: users
Document ID (auto): Will be user's Firebase UID
Add fields when first user signs up
```

**Collection 2: doctors**
```
Collection ID: doctors
Document ID: Generate new ID
Structure:
{
  "name": "string",
  "specialization": "string",
  "experience": "number",
  "rating": "number",
  "reviewCount": "number",
  "isAvailable": "boolean",
  "room": "string",
  "phone": "string",
  "bio": "string",
  "imageUrl": "string"
}
```

**Collection 3: appointments**
```
Collection ID: appointments
Document ID: Generate new ID
Structure:
{
  "patientId": "string" (user UID),
  "doctorId": "string",
  "doctorName": "string",
  "date": "string" (ISO format),
  "timeSlot": "string",
  "status": "string" (Pending/Confirmed/Waiting/In Progress/Completed),
  "chatEnabled": "boolean",
  "createdAt": "string"
}
```

**Collection 4: medicines**
```
Collection ID: medicines
Document ID: Generate new ID
Structure:
{
  "patientId": "string" (user UID),
  "medicineName": "string",
  "dosage": "string",
  "frequency": "string",
  "startDate": "string" (ISO format),
  "endDate": "string" (ISO format),
  "isTaken": "boolean",
  "createdAt": "string"
}
```

**Collection 5: messages**
```
Collection ID: messages
Document ID: Generate new ID
Structure:
{
  "appointmentId": "string",
  "senderId": "string" (user UID),
  "senderType": "string" (patient/doctor),
  "message": "string",
  "timestamp": "string" (ISO format),
  "isRead": "boolean"
}
```

---

### PART 3: Security Rules

#### Step 3.1: Set Firestore Security Rules

Go to: Firestore Database > Rules

**Copy and paste these rules:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users can only read/write their own profile
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }
    
    // Anyone can read doctors (public list)
    match /doctors/{docId} {
      allow read: if true;
      allow write: if isAdmin();
    }
    
    // Users can only see their own appointments
    match /appointments/{docId} {
      allow read: if isAppointmentOwner(docId) || isDoctor(docId);
      allow write: if request.auth != null;
    }
    
    // Users can only see their medicines
    match /medicines/{docId} {
      allow read, write: if isMedicineOwner(docId);
    }
    
    // Chat messages between patient and doctor
    match /messages/{docId} {
      allow read: if isMessageParticipant(docId);
      allow create: if request.auth != null;
    }
    
    // Helper functions
    function isAdmin() {
      return exists(/databases/$(database)/documents/admins/$(request.auth.uid));
    }
    
    function isAppointmentOwner(appointmentId) {
      let apt = get(/databases/$(database)/documents/appointments/$(appointmentId));
      return request.auth.uid == apt.data.patientId || 
             request.auth.uid == apt.data.doctorId;
    }
    
    function isDoctor(doctorId) {
      return request.auth.uid == doctorId;
    }
    
    function isMedicineOwner(medicineId) {
      let medicine = get(/databases/$(database)/documents/medicines/$(medicineId));
      return request.auth.uid == medicine.data.patientId;
    }
    
    function isMessageParticipant(messageId) {
      let message = get(/databases/$(database)/documents/messages/$(messageId));
      return request.auth.uid == message.data.senderId || 
             request.auth.uid == message.data.recipientId;
    }
  }
}
```

#### Step 3.2: Publish Rules
```
1. Click "Publish"
2. Confirm the action
3. Rules take effect immediately
```

---

### PART 4: Storage Setup (Optional - for profile pictures)

#### Step 4.1: Enable Cloud Storage
```
1. Go to: Firebase Console > Storage
2. Click "Get Started"
3. Accept default rules (can be changed later)
4. Click "Done"
```

#### Step 4.2: Set Storage Rules
```
Go to: Storage > Rules

Replace with:
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}

Click "Publish"
```

---

### PART 5: Initialize Firebase in Your Flutter App

The app uses FlutterFire CLI. If already configured:

```bash
# Just verify it's setup correctly
flutterfire configure

# Select your Firebase project when prompted
# Select platforms (Android/iOS)
```

---

## Test Flow

### Test 1: Signup to Firestore ✅

```
1. Open the app
2. Click "Sign Up"
3. Enter:
   - Name: John Doe
   - Email: john@example.com
   - Password: test1234
   - Age: 28
   - Gender: Male
   - Blood Group: O+
4. Click "Sign Up"

Expected Result:
- App shows home screen
- Firebase Console > Authentication shows new user
- Firebase Console > Firestore > users collection shows new document with user UID as ID
```

**Document should look like:**
```
Collection: users
Document ID: (auto-generated Firebase UID)
Fields:
  - uid: "abc123..."
  - name: "John Doe"
  - email: "john@example.com"
  - age: 28
  - gender: "Male"
  - bloodGroup: "O+"
  - medicalHistory: []
  - emergencyContact: ""
  - address: ""
  - profilePictureUrl: ""
  - createdAt: "2024-07-01T10:30:45.123Z"
  - updatedAt: "2024-07-01T10:30:45.123Z"
```

### Test 2: Login with Same User ✅

```
1. Logout from app
2. Click "Login"
3. Enter: john@example.com / test1234
4. Click "Login"

Expected Result:
- App loads user profile
- All user data appears (name, email, age, etc.)
- User is logged in successfully
```

### Test 3: Book Appointment ✅

```
1. While logged in as john@example.com
2. Go to "Doctors" section
3. Find a doctor and click "Book Appointment"
4. Select date and time
5. Click "Confirm"

Expected Result:
- Appointment appears in appointments collection
- Fields include: patientId (john's UID), doctorId, status, date, etc.
- Appointment status is "Pending"
```

### Test 4: Admin Edit Appointment Status ✅

```
1. Go to Firebase Console > Firestore > appointments collection
2. Find the appointment just created
3. Click on it, edit "status" field
4. Change from "Pending" to "Confirmed"
5. Click "Update"

Expected Result:
- Appointment status changes in real-time
- Refresh app and status shows "Confirmed"
- Real-time listener updates the app instantly
```

### Test 5: Multiple Logins ✅

```
1. Create 3 users:
   - user1@test.com
   - user2@test.com
   - user3@test.com

2. Login with user1 - Should see only user1's data
3. Logout
4. Login with user2 - Should see only user2's data
5. Logout
6. Login with user1 again - Should restore user1's data perfectly

Expected Result:
- Each user sees only their own appointments, medicines, etc.
- Data persists and restores correctly
- No data mixing between users
```

---

## Firestore Collection Diagram

```
Firebase Project
│
├── Authentication
│   └── Users: john@example.com, jane@test.com, etc.
│
├── Firestore
│   ├── users/{uid}
│   │   └── Profile data (name, email, age, etc.)
│   │
│   ├── doctors/{docId}
│   │   └── Doctor info (name, specialization, rating)
│   │
│   ├── appointments/{aptId}
│   │   └── Appointment data (patientId, doctorId, status, etc.)
│   │
│   ├── medicines/{medId}
│   │   └── Medicine tracking (patientId, medicineName, status)
│   │
│   └── messages/{msgId}
│       └── Chat messages (senderId, appointmentId, message text)
│
└── Storage (optional)
    └── profile-pictures/{userId}/image.jpg
```

---

## Data Flow

```
SIGNUP:
User enters data → Firebase Auth creates user
                → AuthService saves profile to /users/{uid}
                → User logged in with data from Firestore

LOGIN:
User enters email/password → Firebase Auth validates
                           → AuthService loads profile from /users/{uid}
                           → Real-time listeners activated
                           → User sees their data

APPOINTMENT BOOKING:
Patient selects doctor → AppointmentService saves to /appointments/{newId}
                       → patientId set to current user's UID
                       → Real-time listener notifies all parties
                       → Appointment appears instantly

DOCTOR UPDATE:
Admin changes status → Updates /appointments/{aptId}/status
                     → Real-time listener on app
                     → Patient sees update instantly
```

---

## Troubleshooting

### Issue: User can't login after signup
```
Solution:
- Check Firestore > users collection exists
- Check user document was created with email field
- Verify authentication is enabled in Firebase Console
- Check security rules allow user to read their profile
```

### Issue: Data not saving to Firestore
```
Solution:
- Verify Firestore database is created
- Check collections exist (users, appointments, medicines)
- Check security rules (might be blocking writes)
- Look at app console logs for error messages
```

### Issue: Real-time updates not working
```
Solution:
- Check Firestore security rules allow reads
- Verify user is authenticated
- Check that real-time listeners are initialized
- Look at Firebase Console > Usage tab for errors
```

### Issue: Too many reads causing billing issues
```
Solution:
- Firestore charges per read operation
- Real-time listeners are cheaper than manual reads
- Use security rules to prevent unauthorized access
- Implement query filters to read only needed data
```

---

## Best Practices

1. **Security First**
   - Always validate data before saving
   - Use security rules to protect user data
   - Never trust client-side validation alone

2. **Data Structure**
   - Use user UID as document ID for user data
   - Include timestamps in all documents
   - Keep documents small (break into subcollections if needed)

3. **Real-Time Listeners**
   - Only listen to collections user is authorized to see
   - Unsubscribe when widget is disposed
   - Handle errors and offline scenarios

4. **Performance**
   - Index frequently queried fields
   - Use composite indexes for complex queries
   - Implement pagination for large collections

5. **User Experience**
   - Show loading states while data syncs
   - Cache frequently accessed data locally
   - Handle errors gracefully with user-friendly messages

---

## Success Checklist

- ✅ Firebase project created
- ✅ Email/Password authentication enabled
- ✅ Firestore database created
- ✅ All collections created (users, doctors, appointments, medicines, messages)
- ✅ Security rules configured
- ✅ FlutterFire configured in app
- ✅ Signup creates user in Firebase
- ✅ Signup saves profile to Firestore
- ✅ Login loads profile from Firestore
- ✅ Real-time listeners working
- ✅ Multiple users can login separately
- ✅ Data syncs in real-time
- ✅ Appointments save to Firestore
- ✅ Medicines tracked in Firestore
- ✅ Messages sync in real-time
- ✅ App ready for production

---

**Your Firebase setup is complete!** 🎉

All data now flows through real Firestore with real-time synchronization. Users can signup, login, and all data persists securely.
