import 'package:uuid/uuid.dart';
import '../models/medicine.dart';
import 'firebase_service.dart';
import 'notification_service.dart';

class MedicineService {
  static const uuid = Uuid();

  // Add medicine for user
  static Future<Medicine?> addMedicine({
    required String userId,
    required String name,
    required String dosage,
    required bool morning,
    required bool afternoon,
    required bool evening,
    required bool night,
    required bool beforeFood,
    required String notes,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final medicineId = uuid.v4();
      final medicine = Medicine(
        id: medicineId,
        name: name,
        dosage: dosage,
        morning: morning,
        afternoon: afternoon,
        evening: evening,
        night: night,
        beforeFood: beforeFood,
        notes: notes,
        startDate: startDate,
        endDate: endDate,
      );

      await FirebaseService.setDocument(
        collection: 'medicines',
        docId: medicineId,
        data: {
          'userId': userId,
          ...medicine.toMap(),
          'createdAt': DateTime.now(),
        },
      );

      await NotificationService.addNotification(
        title: 'Medicine Added',
        body: 'Reminder set for $name ($dosage)',
        type: 'medicine',
        userId: userId,
      );

      return medicine;
    } catch (e) {
      print('[MedicineService] Add Error: $e');
      return null;
    }
  }

  // Get user's medicines
  static Future<List<Medicine>> getUserMedicines(String userId) async {
    try {
      final query = await FirebaseService.queryCollection(
        collection: 'medicines',
        field: 'userId',
        value: userId,
      );

      return query.docs
          .map(
            (doc) =>
                Medicine.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      print('[MedicineService] Get Medicines Error: $e');
      return [];
    }
  }

  // Update medicine
  static Future<bool> updateMedicine({
    required String medicineId,
    required String name,
    required String dosage,
    required bool morning,
    required bool afternoon,
    required bool evening,
    required bool night,
    required bool beforeFood,
    required String notes,
    required DateTime startDate,
    required DateTime endDate,
    Map<String, bool>? takenToday,
  }) async {
    try {
      final data = {
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
      };
      if (takenToday != null) {
        data['takenToday'] = takenToday;
      }

      await FirebaseService.updateDocument(
        collection: 'medicines',
        docId: medicineId,
        data: data,
      );
      return true;
    } catch (e) {
      print('[MedicineService] Update Error: $e');
      return false;
    }
  }

  // Delete medicine
  static Future<bool> deleteMedicine(String medicineId) async {
    try {
      await FirebaseService.deleteDocument(
        collection: 'medicines',
        docId: medicineId,
      );
      return true;
    } catch (e) {
      print('[MedicineService] Delete Error: $e');
      return false;
    }
  }

  // Mark medicine as taken
  static Future<bool> markMedicineAsTaken({
    required String userId,
    required String medicineId,
    required String medicineName,
    required String timeSlot,
  }) async {
    try {
      // Create a record in medicine_intake collection
      await FirebaseService.addDocument(
        collection: 'medicine_intake',
        data: {
          'userId': userId,
          'medicineId': medicineId,
          'medicineName': medicineName,
          'timeSlot': timeSlot,
          'date': DateTime.now(),
          'takenAt': DateTime.now(),
        },
      );

      await NotificationService.addNotification(
        title: 'Medication Tracked',
        body: 'You took $medicineName at $timeSlot',
        type: 'medicine',
        userId: userId,
      );

      return true;
    } catch (e) {
      print('[MedicineService] Mark Taken Error: $e');
      return false;
    }
  }

  // Get medicine intake history
  static Future<List<Map<String, dynamic>>> getMedicineHistory({
    required String userId,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      var query = FirebaseService.firestore
          .collection('medicine_intake')
          .where('userId', isEqualTo: userId);

      if (from != null) {
        query = query.where('date', isGreaterThanOrEqualTo: from);
      }
      if (to != null) {
        query = query.where('date', isLessThanOrEqualTo: to);
      }

      final result = await query.orderBy('date', descending: true).get();
      return result.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('[MedicineService] Get History Error: $e');
      return [];
    }
  }

  // Get today's medicines
  static Future<List<Medicine>> getTodaysMedicines(String userId) async {
    try {
      return await getUserMedicines(userId);
    } catch (e) {
      print('[MedicineService] Get Today Medicines Error: $e');
      return [];
    }
  }

  // Listen to medicines in real-time
  static Stream<List<Medicine>> listenToUserMedicines(String userId) {
    return FirebaseService.listenToQuery(
      collection: 'medicines',
      field: 'userId',
      value: userId,
    ).map((snapshot) {
      return snapshot.docs
          .map(
            (doc) =>
                Medicine.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    });
  }

  // Send medicine reminder
  static Future<void> sendMedicineReminder({
    required String userId,
    required String medicineName,
    required String dosage,
    required String timeSlot,
    required bool beforeFood,
  }) async {
    try {
      final foodTiming = beforeFood ? 'before food' : 'after food';
      await NotificationService.sendMedicineReminder(
        userId: userId,
        medicineName: medicineName,
        dosage: dosage,
        time: '$timeSlot ($foodTiming)',
      );
    } catch (e) {
      print('[MedicineService] Send Reminder Error: $e');
    }
  }

  static Future<bool> updateMedicineTakenToday(
    String medicineId,
    Map<String, bool> takenToday,
  ) async {
    try {
      await FirebaseService.updateDocument(
        collection: 'medicines',
        docId: medicineId,
        data: {'takenToday': takenToday},
      );
      return true;
    } catch (e) {
      print('[MedicineService] Update TakenToday Error: $e');
      return false;
    }
  }

  // Get medicine compliance stats
  static Future<Map<String, dynamic>> getMedicineCompliance(
    String userId,
  ) async {
    try {
      final medicines = await getUserMedicines(userId);
      final history = await getMedicineHistory(
        userId: userId,
        from: DateTime.now().subtract(const Duration(days: 7)),
      );

      int totalExpected = 0;
      for (var med in medicines) {
        if (med.morning) totalExpected++;
        if (med.afternoon) totalExpected++;
        if (med.evening) totalExpected++;
        if (med.night) totalExpected++;
      }

      totalExpected *= 7; // 7 days

      return {
        'totalMedicines': medicines.length,
        'totalExpectedDoses': totalExpected,
        'totalDosesTaken': history.length,
        'compliancePercentage': totalExpected > 0
            ? ((history.length / totalExpected) * 100).toStringAsFixed(1)
            : '0',
      };
    } catch (e) {
      print('[MedicineService] Compliance Stats Error: $e');
      return {
        'totalMedicines': 0,
        'totalExpectedDoses': 0,
        'totalDosesTaken': 0,
        'compliancePercentage': '0',
      };
    }
  }

  Future<bool> editMedicine(Medicine medicine) async {
    return await updateMedicine(
      medicineId: medicine.id,
      name: medicine.name,
      dosage: medicine.dosage,
      morning: medicine.morning,
      afternoon: medicine.afternoon,
      evening: medicine.evening,
      night: medicine.night,
      beforeFood: medicine.beforeFood,
      notes: medicine.notes,
      startDate: medicine.startDate,
      endDate: medicine.endDate,
      takenToday: medicine.takenToday,
    );
  }

  Future<bool> markAsTaken(String medicineId) async {
    return false;
  }
}
