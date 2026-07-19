class PaymentModel {
  final String paymentId;
  final String appointmentId;
  final String patientId;
  final String doctorId;
  final double amount;
  final String currency;
  final String transactionId;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentModel({
    required this.paymentId,
    required this.appointmentId,
    required this.patientId,
    required this.doctorId,
    required this.amount,
    this.currency = 'PKR',
    required this.transactionId,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map, String docId) {
    return PaymentModel(
      paymentId: docId,
      appointmentId: map['appointmentId'] ?? '',
      patientId: map['patientId'] ?? '',
      doctorId: map['doctorId'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'PKR',
      transactionId: map['transactionId'] ?? '',
      paymentMethod: map['paymentMethod'] ?? 'Easypaisa',
      paymentStatus: map['paymentStatus'] ?? 'Pending',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'patientId': patientId,
      'doctorId': doctorId,
      'amount': amount,
      'currency': currency,
      'transactionId': transactionId,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
