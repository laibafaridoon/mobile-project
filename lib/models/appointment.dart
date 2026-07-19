class Appointment {
  final String id;
  final String patientId;
  final String patientName;
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
  final String status; // "Pending", "Confirmed", "Waiting", "In Progress", "Your Turn Next", "Completed", "Cancelled", "Rescheduled"
  final String? notes;
  final bool chatEnabled; // Doctor-patient chat after appointment
  final DateTime createdAt;

  // Payment Details
  final String? paymentStatus; // "Pending", "Paid", "Failed"
  final String? paymentMethod; // "Easypaisa"
  final String? transactionId;
  final String? paymentReference;
  final double? amountPaid;
  final String? bookingStatus; // "Unpaid", "Paid"
  
  Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
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
    this.notes,
    this.chatEnabled = false,
    required this.createdAt,
    this.paymentStatus = 'Pending',
    this.paymentMethod,
    this.transactionId,
    this.paymentReference,
    this.amountPaid,
    this.bookingStatus = 'Unpaid',
  });

  Appointment copyWith({
    String? id,
    String? patientId,
    String? patientName,
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
    String? notes,
    bool? chatEnabled,
    DateTime? createdAt,
    String? paymentStatus,
    String? paymentMethod,
    String? transactionId,
    String? paymentReference,
    double? amountPaid,
    String? bookingStatus,
  }) {
    return Appointment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
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
      notes: notes ?? this.notes,
      chatEnabled: chatEnabled ?? this.chatEnabled,
      createdAt: createdAt ?? this.createdAt,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      paymentReference: paymentReference ?? this.paymentReference,
      amountPaid: amountPaid ?? this.amountPaid,
      bookingStatus: bookingStatus ?? this.bookingStatus,
    );
  }

  factory Appointment.fromMap(Map<String, dynamic> map, String docId) {
    return Appointment(
      id: docId,
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
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
      status: map['status'] ?? 'Pending',
      notes: map['notes'],
      chatEnabled: map['chatEnabled'] ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      paymentStatus: map['paymentStatus'] ?? 'Pending',
      paymentMethod: map['paymentMethod'],
      transactionId: map['transactionId'],
      paymentReference: map['paymentReference'],
      amountPaid: map['amountPaid'] != null ? (map['amountPaid'] as num).toDouble() : null,
      bookingStatus: map['bookingStatus'] ?? 'Unpaid',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'patientName': patientName,
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
      'notes': notes,
      'chatEnabled': chatEnabled,
      'createdAt': createdAt.toIso8601String(),
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'paymentReference': paymentReference,
      'amountPaid': amountPaid,
      'bookingStatus': bookingStatus,
    };
  }
}
