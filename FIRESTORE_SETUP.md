# Firestore Database Setup - Step by Step

## ⚙️ Complete Setup Guide

---

## STEP 1: Create Firestore Collections

Go to Firebase Console → Firestore Database

### Collection 1: `users`

**Purpose:** Store patient profiles

**Click:** Create Collection → Type `users` → Create

Add these fields to first document (or let auto-create):

```
Field Name          | Type      | Example Value
uid                 | string    | Auto from Firebase Auth
name                | string    | Ali Ahmed
email               | string    | ali@example.com
age                 | number    | 28
gender              | string    | Male
bloodGroup          | string    | O+
medicalHistory      | array     | ["Hypertension", "Allergy"]
emergencyContact    | string    | +92 300 1234567
address             | string    | 123 Health Street
profilePictureUrl   | string    | https://...
phone               | string    | +92 300 1234567
createdAt           | timestamp | Auto (Firestore adds)
updatedAt           | timestamp | Auto (Firestore adds)
```

---

### Collection 2: `appointments`

**Purpose:** Store appointment records

**Click:** Create Collection → Type `appointments` → Create

```
Field Name              | Type       | Example Value
id                      | string     | apt_123456
patientId               | string     | {uid from users}
patientName             | string     | Ali Ahmed
doctorId                | string     | doc_001
doctorName              | string     | Dr. Hassan
doctorImageUrl          | string     | https://...
doctorSpecialization    | string     | General Medicine
date                    | timestamp  | 2024-07-05
timeSlot                | string     | 10:00 AM
tokenNumber             | string     | 05
queuePosition           | number     | 2
estimatedWaitTime       | number     | 30
roomNumber              | string     | A101
status                  | string     | Confirmed (or: Pending/Waiting/In Progress/Completed/Cancelled)
notes                   | string     | (optional)
chatEnabled             | boolean    | true
createdAt               | timestamp  | Auto
updatedAt               | timestamp  | Auto
```

---

### Collection 3: `doctors`

**Purpose:** Store doctor profiles

**Click:** Create Collection → Type `doctors` → Create

```
Field Name      | Type      | Example Value
id              | string    | doc_001
name            | string    | Dr. Hassan Ali
specialization  | string    | General Medicine
qualification   | string    | MBBS, MD
experience      | number    | 10
imageUrl        | string    | https://...
rating          | number    | 4.5
reviewCount     | number    | 128
isAvailable     | boolean   | true
room            | string    | A101
phone           | string    | +92 300 1111111
bio             | string    | Experienced doctor...
createdAt       | timestamp | Auto
```

---

### Collection 4: `medicines`

**Purpose:** Store medicine prescriptions

**Click:** Create Collection → Type `medicines` → Create

```
Field Name      | Type       | Example Value
id              | string     | med_123456
patientId       | string     | {uid from users}
doctorId        | string     | doc_001
medicineName    | string     | Paracetamol
dosage          | string     | 500mg
frequency       | string     | 3 times daily
startDate       | timestamp  | 2024-07-01
endDate         | timestamp  | 2024-07-15
reason          | string     | Fever
sideEffects     | array      | ["Nausea", "Dizziness"]
isTaken         | boolean    | true
takenAt         | timestamp  | 2024-07-05T10:30:00
createdAt       | timestamp  | Auto
```

---

### Collection 5: `messages` (Optional - For Chat)

**Purpose:** Store doctor-patient chat messages

**Click:** Create Collection → Type `messages` → Create

```
Field Name          | Type      | Example Value
id                  | string    | msg_123456
conversationId      | string    | conv_001
senderId            | string    | {user uid}
senderName          | string    | Ali Ahmed
senderRole          | string    | patient (or: doctor)
receiverId          | string    | {doctor uid}
appointmentId       | string    | apt_123456
message             | string    | How long should I take this medicine?
timestamp           | timestamp | 2024-07-05T10:30:00
read                | boolean   | true
type                | string    | text (or: prescription)
prescriptionData    | map       | {medicineName: "Paracetamol"...}
```

---

### Collection 6: `notifications` (Optional - For Alerts)

**Purpose:** Store notification records

**Click:** Create Collection → Type `notifications` → Create

```
Field Name      | Type       | Example Value
id              | string     | notif_123456
userId          | string     | {user uid}
title           | string     | Appointment Confirmed
body            | string     | Your appointment is at 10:00 AM
type            | string     | appointment (or: queue/medicine/chat)
relatedId       | string     | apt_123456
read            | boolean    | false
createdAt       | timestamp  | Auto
data            | map        | {appointmentId: "apt_123456"}
```

---

## STEP 2: Set Security Rules

1. Go to **Firestore Database** → **Rules** tab
2. **Delete** the default rules (allow read, write: if false)
3. **Copy and paste** this complete ruleset:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // USERS COLLECTION
    // Users can only read/write their own document
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid;
    }
    
    // APPOINTMENTS COLLECTION
    match /appointments/{appointmentId} {
      // Patients can read their own appointments
      allow read: if resource.data.patientId == request.auth.uid;
      // Doctors can read their appointments
      allow read: if resource.data.doctorId == request.auth.uid;
      // Patients can create new appointments
      allow create: if request.auth != null && 
                       request.resource.data.patientId == request.auth.uid;
      // Both patient and doctor can update their appointments
      allow update: if request.auth.uid == resource.data.patientId || 
                       request.auth.uid == resource.data.doctorId;
      // Only delete own data
      allow delete: if request.auth.uid == resource.data.patientId;
    }
    
    // DOCTORS COLLECTION
    // All authenticated users can read doctors
    match /doctors/{doctorId} {
      allow read: if request.auth != null;
      // Doctors can write their own profile
      allow write: if request.auth.uid == doctorId;
    }
    
    // MEDICINES COLLECTION
    match /medicines/{medicineId} {
      allow read, write: if request.auth != null && 
                            resource.data.patientId == request.auth.uid;
    }
    
    // MESSAGES COLLECTION
    match /messages/{conversationId}/{messageId} {
      allow read, write: if request.auth.uid == resource.data.senderId || 
                            request.auth.uid == resource.data.receiverId;
    }
    
    // NOTIFICATIONS COLLECTION
    match /notifications/{notificationId} {
      allow read: if request.auth.uid == resource.data.userId;
      allow write: if request.auth != null;
    }
  }
}
```

4. Click **Publish**

---

## STEP 3: Test Signup & Firestore Save

### Test Flow:

```
1. Open your Flutter app
2. Click "Sign Up" or "Register"
3. Fill in:
   - Name: Test User
   - Email: test@example.com
   - Password: 12345678
   - Age: 25
   - Gender: Male
   - Blood Group: O+
4. Click "Sign Up"
5. Should login automatically
```

### Check Firestore:

```
1. Go to Firebase Console
2. Click Firestore Database
3. Click "users" collection
4. Should see a new document with UID as ID
5. Click the document
6. Verify all fields are saved:
   ✓ name: "Test User"
   ✓ email: "test@example.com"
   ✓ age: 25
   ✓ gender: "Male"
   ✓ bloodGroup: "O+"
   ✓ createdAt: timestamp
```

---

## STEP 4: Test Real-Time Sync

### For Appointments:

```
1. Login with patient account in app
2. Book an appointment
3. Check Firestore → appointments collection
4. Verify appointment document created
5. In Firebase Console, edit "status" field:
   Change from "Pending" to "Confirmed"
6. Watch app - status should update instantly!
```

### For Doctors:

```
1. Check Firestore → doctors collection
2. Edit doctor rating from 4.0 to 5.0
3. In app, doctor list should update instantly
```

### For Medicines:

```
1. Login with patient account
2. Open Firestore → medicines collection
3. Add new medicine document with:
   - patientId: {user's uid}
   - medicineName: "Test Medicine"
   - dosage: "500mg"
   - other fields...
4. In app, medicine should appear instantly!
```

---

## STEP 5: Verify Everything Works

### Checklist:

- [ ] Firestore collections created (users, appointments, doctors, medicines)
- [ ] Security rules published
- [ ] Signup creates user document in Firestore
- [ ] Login retrieves user data from Firestore
- [ ] Real-time listeners work (changes sync instantly)
- [ ] Can book appointment and see it in Firestore
- [ ] Can see doctor list
- [ ] Can add medicines

---

## STEP 6: Import Demo Data (Optional)

To populate your Firestore with demo data:

### Add Demo Doctors:

Go to Firestore → **doctors** collection → **Add Document**

**Doctor 1:**
```
id: doc_001
name: Dr. Hassan Ali
specialization: General Medicine
experience: 10
rating: 4.5
isAvailable: true
room: A101
```

**Doctor 2:**
```
id: doc_002
name: Dr. Fatima Khan
specialization: Cardiology
experience: 12
rating: 4.8
isAvailable: true
room: B202
```

**Doctor 3:**
```
id: doc_003
name: Dr. Ahmed Shah
specialization: Pediatrics
experience: 8
rating: 4.3
isAvailable: true
room: C303
```

---

## STEP 7: Deploy & Test in Production

### Before Deployment:

```
1. Test with multiple user accounts
2. Book appointments across accounts
3. Verify doctor list syncs
4. Check medicine prescriptions
5. Test chat messages
6. Monitor Firebase usage
```

### Deploy:

```
flutter build apk  # For Android
flutter build ios  # For iOS
```

---

## 🔧 Troubleshooting

### Problem: "Permission denied" error

**Solution:** Check security rules
- Go to Firestore → Rules tab
- Make sure rules are published
- Check that patientId matches user's UID

### Problem: Data not saving

**Solution:** Check collection name
- Must be exactly: `users`, `appointments`, `doctors`, `medicines`
- Check uppercase/lowercase

### Problem: Real-time not updating

**Solution:** Check listener
- Make sure provider is initialized
- Check that user is authenticated
- Look at Flutter console for errors

### Problem: Signup doesn't save to Firestore

**Solution:** Check auth_service
- Make sure `setDocument()` is called after signup
- Check Firestore is initialized in `firebase_service.dart`

---

## ✅ Success Indicators

When everything is working:

✅ Can create account → data appears in Firestore
✅ Can login → data loads from Firestore
✅ Can book appointment → appears in Firestore instantly
✅ Changes in Firebase Console → app updates in real-time
✅ No errors in Flutter console
✅ App works offline (cached data)
✅ Real-time listeners active

---

## 📊 Data Flow

```
App Signup
    ↓
Firebase Auth creates user
    ↓
auth_service saves profile to /users/{uid}
    ↓
Profile appears in Firestore Console
    ↓
Next login loads from Firestore
    ↓
Real-time listeners keep app synced
```

---

## 🎯 You're Done!

Your Firestore database is now set up and your app is:
- ✅ Saving user data on signup
- ✅ Retrieving user data on login
- ✅ Syncing appointments in real-time
- ✅ Syncing doctors in real-time
- ✅ Syncing medicines in real-time
- ✅ Production-ready!

**Next:** Build your app, test thoroughly, and deploy! 🚀
