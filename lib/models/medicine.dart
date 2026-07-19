import 'package:cloud_firestore/cloud_firestore.dart';

class Medicine {
  final String id;
  final String name;
  final String dosage; // e.g. "1 Pill", "5ml"
  final bool morning;
  final bool afternoon;
  final bool evening;
  final bool night;
  final bool beforeFood; // true = before food, false = after food
  final String notes;
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, bool> takenToday;

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.morning,
    required this.afternoon,
    required this.evening,
    required this.night,
    required this.beforeFood,
    required this.startDate,
    required this.endDate,
    this.notes = '',
    Map<String, bool>? takenToday,
  }) : takenToday =
           takenToday ??
           {
             if (morning) 'morning': false,
             if (afternoon) 'afternoon': false,
             if (evening) 'evening': false,
             if (night) 'night': false,
           };

  bool get isTaken => takenToday.values.any((value) => value == true);

  Medicine copyWith({
    String? id,
    String? name,
    String? dosage,
    bool? morning,
    bool? afternoon,
    bool? evening,
    bool? night,
    bool? beforeFood,
    String? notes,
    DateTime? startDate,
    DateTime? endDate,
    Map<String, bool>? takenToday,
    bool? isTaken,
  }) {
    final updatedMorning = morning ?? this.morning;
    final updatedAfternoon = afternoon ?? this.afternoon;
    final updatedEvening = evening ?? this.evening;
    final updatedNight = night ?? this.night;

    final updatedTakenToday = takenToday ??
        (isTaken != null
            ? {
                if (updatedMorning) 'morning': isTaken,
                if (updatedAfternoon) 'afternoon': isTaken,
                if (updatedEvening) 'evening': isTaken,
                if (updatedNight) 'night': isTaken,
              }
            : this.takenToday);

    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      morning: updatedMorning,
      afternoon: updatedAfternoon,
      evening: updatedEvening,
      night: updatedNight,
      beforeFood: beforeFood ?? this.beforeFood,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      takenToday: updatedTakenToday,
    );
  }

  factory Medicine.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return Medicine(
      id: docId,
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      morning: map['morning'] ?? false,
      afternoon: map['afternoon'] ?? false,
      evening: map['evening'] ?? false,
      night: map['night'] ?? false,
      beforeFood: map['beforeFood'] ?? false,
      startDate: parseDate(map['startDate']),
      endDate: parseDate(map['endDate']),
      notes: map['notes'] ?? '',
      takenToday: Map<String, bool>.from(map['takenToday'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'morning': morning,
      'afternoon': afternoon,
      'evening': evening,
      'night': night,
      'beforeFood': beforeFood,
      'notes': notes,
      'startDate': startDate,
      'endDate': endDate,
      'takenToday': takenToday,
    };
  }
}
