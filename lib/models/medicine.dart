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
  final Map<String, bool>
  takenToday; // e.g., {'morning': false, 'afternoon': false, 'evening': false, 'night': false}
  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.morning,
    required this.afternoon,
    required this.evening,
    required this.night,
    required this.beforeFood,
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
    Map<String, bool>? takenToday,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      morning: morning ?? this.morning,
      afternoon: afternoon ?? this.afternoon,
      evening: evening ?? this.evening,
      night: night ?? this.night,
      beforeFood: beforeFood ?? this.beforeFood,
      notes: notes ?? this.notes,
      takenToday: takenToday ?? this.takenToday,
    );
  }

  factory Medicine.fromMap(Map<String, dynamic> map, String docId) {
    return Medicine(
      id: docId,
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      morning: map['morning'] ?? false,
      afternoon: map['afternoon'] ?? false,
      evening: map['evening'] ?? false,
      night: map['night'] ?? false,
      beforeFood: map['beforeFood'] ?? false,
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
      'takenToday': takenToday,
    };
  }
}
