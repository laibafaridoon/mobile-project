class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorImageUrl;
  final String doctorSpecialization;
  final DateTime date;
  final String timeSlot;
  final String tokenNumber;
  final int queuePosition;
  final int estimatedWaitTime; // in minutes
  final String roomNumber;
  final String
  status; // "Waiting", "In Progress", "Your Turn Next", "Completed", "Cancelled"
  final DateTime createdAt;
  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorImageUrl,
    required this.doctorSpecialization,
    required this.date,
    required this.timeSlot,
    required this.tokenNumber,
    required this.queuePosition,
    required this.estimatedWaitTime,
    required this.roomNumber,
    required this.status,
    required this.createdAt,
  });
  Appointment copyWith({
    String? id,
    String? doctorId,
    String? doctorName,
    String? doctorImageUrl,
    String? doctorSpecialization,
    DateTime? date,
    String? timeSlot,
    String? tokenNumber,
    int? queuePosition,
    int? estimatedWaitTime,
    String? roomNumber,
    String? status,
    DateTime? createdAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorImageUrl: doctorImageUrl ?? this.doctorImageUrl,
      doctorSpecialization: doctorSpecialization ?? this.doctorSpecialization,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      tokenNumber: tokenNumber ?? this.tokenNumber,
      queuePosition: queuePosition ?? this.queuePosition,
      estimatedWaitTime: estimatedWaitTime ?? this.estimatedWaitTime,
      roomNumber: roomNumber ?? this.roomNumber,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Appointment.fromMap(Map<String, dynamic> map, String docId) {
    return Appointment(
      id: docId,
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      doctorImageUrl: map['doctorImageUrl'] ?? '',
      doctorSpecialization: map['doctorSpecialization'] ?? '',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      timeSlot: map['timeSlot'] ?? '',
      tokenNumber: map['tokenNumber'] ?? '',
      queuePosition: map['queuePosition'] ?? 0,
      estimatedWaitTime: map['estimatedWaitTime'] ?? 0,
      roomNumber: map['roomNumber'] ?? '',
      status: map['status'] ?? 'Waiting',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorImageUrl': doctorImageUrl,
      'doctorSpecialization': doctorSpecialization,
      'date': date.toIso8601String(),
      'timeSlot': timeSlot,
      'tokenNumber': tokenNumber,
      'queuePosition': queuePosition,
      'estimatedWaitTime': estimatedWaitTime,
      'roomNumber': roomNumber,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
