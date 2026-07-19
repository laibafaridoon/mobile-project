import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String appointmentId;
  final String senderUid;
  final String senderName;
  final String senderRole; // 'patient' or 'doctor'
  final String content;
  final String messageType; // 'text', 'image', 'prescription'
  final String? mediaUrl;
  final DateTime timestamp;
  final bool isSeen;
  final Map<String, dynamic>? prescriptionData; // For medicine prescriptions

  Message({
    required this.id,
    required this.appointmentId,
    required this.senderUid,
    required this.senderName,
    required this.senderRole,
    required this.content,
    required this.messageType,
    this.mediaUrl,
    required this.timestamp,
    this.isSeen = false,
    this.prescriptionData,
  });

  // Convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'appointmentId': appointmentId,
      'senderUid': senderUid,
      'senderName': senderName,
      'senderRole': senderRole,
      'content': content,
      'messageType': messageType,
      'mediaUrl': mediaUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'isSeen': isSeen,
      'prescriptionData': prescriptionData,
    };
  }

  // Create from map
  factory Message.fromMap(Map<String, dynamic> map, String docId) {
    return Message(
      id: docId,
      appointmentId: map['appointmentId'] ?? '',
      senderUid: map['senderUid'] ?? '',
      senderName: map['senderName'] ?? '',
      senderRole: map['senderRole'] ?? 'patient',
      content: map['content'] ?? '',
      messageType: map['messageType'] ?? 'text',
      mediaUrl: map['mediaUrl'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isSeen: map['isSeen'] ?? false,
      prescriptionData: map['prescriptionData'],
    );
  }

  // Copy with
  Message copyWith({
    String? id,
    String? appointmentId,
    String? senderUid,
    String? senderName,
    String? senderRole,
    String? content,
    String? messageType,
    String? mediaUrl,
    DateTime? timestamp,
    bool? isSeen,
    Map<String, dynamic>? prescriptionData,
  }) {
    return Message(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      senderUid: senderUid ?? this.senderUid,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      timestamp: timestamp ?? this.timestamp,
      isSeen: isSeen ?? this.isSeen,
      prescriptionData: prescriptionData ?? this.prescriptionData,
    );
  }
}
