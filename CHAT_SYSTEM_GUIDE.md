# Doctor-Patient Chat System Guide

## Overview

The chat system enables real-time communication between patients and doctors after appointment completion. It's built on Firestore and supports text messages, images, and prescriptions.

## Features

✅ **Real-time Messaging** - Firestore snapshots for instant updates
✅ **Appointment-Based Chat** - One chat per appointment
✅ **Message Types** - Text, Image, Prescription
✅ **Message Status** - Track seen/unseen messages
✅ **Prescription Sending** - Doctors can send medicine prescriptions
✅ **Notifications** - Real-time notification of new messages

## Architecture

### Models
```dart
// Message model in lib/models/message.dart
Message {
  id: String
  appointmentId: String
  senderUid: String
  senderName: String
  senderRole: String (patient|doctor)
  content: String
  messageType: String (text|image|prescription)
  mediaUrl: String?
  timestamp: DateTime
  isSeen: boolean
  prescriptionData: Map? (for prescriptions)
}
```

### Provider
```dart
// ChatProvider in lib/providers/chat_provider.dart
- listenToMessages(appointmentId)  // Start listening
- sendMessage(...)                 // Send text message
- sendPrescription(...)            // Send prescription
- markMessageAsSeen(messageId)     // Mark as read
- stopListening()                  // Stop listening
```

### Service
```dart
// No separate ChatService - uses Firestore directly
// All operations go through ChatProvider
```

## Implementation Steps

### Step 1: Create Chat Screen

Create a new file: `lib/screens/chat/doctor_patient_chat_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/appointment.dart';
import '../../models/message.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';

class DoctorPatientChatScreen extends StatefulWidget {
  final Appointment appointment;

  const DoctorPatientChatScreen({
    required this.appointment,
    Key? key,
  }) : super(key: key);

  @override
  State<DoctorPatientChatScreen> createState() =>
      _DoctorPatientChatScreenState();
}

class _DoctorPatientChatScreenState extends State<DoctorPatientChatScreen> {
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    
    // Start listening to messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().listenToMessages(widget.appointment.id);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    context.read<ChatProvider>().stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Dr. ${widget.appointment.doctorName}'),
            Text(
              widget.appointment.doctorSpecialization,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                final messages = chatProvider.messages;

                if (messages.isEmpty) {
                  return Center(
                    child: Text('No messages yet. Start the conversation!'),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    final isSender = message.senderUid == currentUser?.uid;

                    return Align(
                      alignment: isSender
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSender
                              ? Colors.blue.shade500
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        constraints:
                            BoxConstraints(maxWidth: 250),
                        child: Column(
                          crossAxisAlignment: isSender
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (message.messageType == 'text')
                              Text(
                                message.content,
                                style: TextStyle(
                                  color: isSender
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            if (message.messageType == 'prescription')
                              _buildPrescriptionWidget(message),
                            SizedBox(height: 4),
                            Text(
                              _formatTime(message.timestamp),
                              style: TextStyle(
                                fontSize: 10,
                                color: isSender
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    _sendMessage();
                  },
                  child: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final chatProvider = context.read<ChatProvider>();
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;

    if (user == null) return;

    bool success = await chatProvider.sendMessage(
      appointmentId: widget.appointment.id,
      senderUid: user.uid,
      senderName: user.name,
      senderRole: 'patient', // or 'doctor' based on user type
      content: _messageController.text,
    );

    if (success) {
      _messageController.clear();
    }
  }

  Widget _buildPrescriptionWidget(Message message) {
    final prescData = message.prescriptionData;
    if (prescData == null) return SizedBox.shrink();

    final medicines = prescData['medicines'] as List<dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prescription',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        if (medicines != null)
          ...medicines.map((med) {
            return Text('• ${med['name']} - ${med['dosage']}');
          }).toList(),
      ],
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}
```

### Step 2: Enable Chat After Appointment

In `appointment_service.dart`, chat is automatically enabled when appointment is completed:

```dart
if (newStatus == 'Completed') {
  // ... notification code
  // Enable chat after completed
  await enableChat(appointmentId);
}
```

### Step 3: Show Chat Button

Update appointment detail/history screens to show chat button:

```dart
if (appointment.chatEnabled && appointment.status == 'Completed')
  ElevatedButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DoctorPatientChatScreen(
            appointment: appointment,
          ),
        ),
      );
    },
    child: Text('Chat with Doctor'),
  ),
```

### Step 4: Doctor Prescription Sending

Create prescription sending in doctor screen:

```dart
// Doctor sends prescription
await chatProvider.sendPrescription(
  appointmentId: appointmentId,
  doctorUid: doctorUser.uid,
  doctorName: doctorUser.name,
  content: 'Please follow the prescribed medicines',
  medicines: [
    {
      'name': 'Paracetamol',
      'dosage': '500mg',
      'timing': 'Twice daily',
      'duration': '5 days',
    },
  ],
);
```

## Firestore Structure

### messages Collection
```
messages/{messageId}
├── appointmentId: "apt_123"
├── senderUid: "user_456"
├── senderName: "John Doe"
├── senderRole: "patient"
├── content: "Hello Doctor"
├── messageType: "text"
├── mediaUrl: null
├── timestamp: 2024-06-30T10:30:00Z
├── isSeen: false
└── prescriptionData: null
```

## Usage Examples

### Listen to Messages
```dart
final chatProvider = context.watch<ChatProvider>();
chatProvider.listenToMessages(appointmentId);

// Access messages
final messages = chatProvider.messages;
```

### Send Message
```dart
await chatProvider.sendMessage(
  appointmentId: appointmentId,
  senderUid: userId,
  senderName: userName,
  senderRole: 'patient',
  content: 'I have a question about my prescription',
);
```

### Send Prescription
```dart
await chatProvider.sendPrescription(
  appointmentId: appointmentId,
  doctorUid: doctorId,
  doctorName: 'Dr. Smith',
  content: 'Prescription for your symptoms',
  medicines: [
    {'name': 'Medicine A', 'dosage': '1 tablet', 'timing': 'Twice daily'},
    {'name': 'Medicine B', 'dosage': '5ml', 'timing': 'Once daily'},
  ],
);
```

### Mark as Seen
```dart
await chatProvider.markMessageAsSeen(messageId);
```

## Notifications

When a message is sent:
1. Patient gets notified: "Message from Dr. Smith"
2. Doctor gets notified: "New message from Patient"

These are handled by `NotificationService.notifyPatient()` and `NotificationService.notifyDoctor()`

## Best Practices

✅ Always call `listenToMessages()` in `initState()`
✅ Always call `stopListening()` in `dispose()`
✅ Handle null/empty message cases
✅ Show loading states for sent messages
✅ Confirm messages are sent before clearing input
✅ Handle real-time updates gracefully
✅ Optimize ListView with reverse scrolling

## Security Rules

Firestore rules for messages:
```javascript
match /messages/{messageId} {
  allow read, write: if request.auth != null && 
                        (request.auth.uid == resource.data.senderUid ||
                         request.auth.uid in 
                         get(/databases/$(database)/documents/appointments/$(resource.data.appointmentId)).data);
}
```

## Troubleshooting

**Messages not appearing?**
- Check Firestore security rules
- Verify appointmentId is correct
- Check browser console for errors

**Chat button not showing?**
- Verify appointment status is 'Completed'
- Check chatEnabled is true
- Ensure appointment has both patientId and doctorId

**Notifications not working?**
- Verify FCM is configured
- Check user permissions
- Ensure userId is set correctly

## Next Steps

1. Create the chat screen component
2. Add chat button to appointment detail screen
3. Implement doctor prescription UI
4. Add image sharing capability
5. Implement message search
6. Add typing indicators
