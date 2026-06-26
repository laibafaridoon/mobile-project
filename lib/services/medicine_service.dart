import '../models/medicine.dart';
import 'notification_service.dart';

class MedicineService {
  static final List<Medicine> _medicines = [
    Medicine(
      id: 'med_1',
      name: 'Paracetamol',
      dosage: '500mg (1 Tablet)',
      morning: true,
      afternoon: false,
      evening: true,
      night: false,
      beforeFood: false,
      notes: 'Take after lunch/dinner for fever/pain relief.',
      takenToday: {'morning': true, 'evening': false},
    ),
    Medicine(
      id: 'med_2',
      name: 'Salbutamol Inhaler',
      dosage: '100mcg (2 Puffs)',
      morning: true,
      afternoon: true,
      evening: true,
      night: true,
      beforeFood: true,
      notes: 'Use daily before meals. Keep inhaler clean.',
      takenToday: {
        'morning': true,
        'afternoon': false,
        'evening': false,
        'night': false,
      },
    ),
    Medicine(
      id: 'med_3',
      name: 'Atorvastatin',
      dosage: '20mg (1 Tablet)',
      morning: false,
      afternoon: false,
      evening: false,
      night: true,
      beforeFood: false,
      notes: 'Take before bedtime.',
      takenToday: {'night': false},
    ),
  ];
  Future<List<Medicine>> getMedicines() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_medicines);
  }

  Future<Medicine> addMedicine(Medicine medicine) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final newMedicine = Medicine(
      id: 'med_${DateTime.now().millisecondsSinceEpoch}',
      name: medicine.name,
      dosage: medicine.dosage,
      morning: medicine.morning,
      afternoon: medicine.afternoon,
      evening: medicine.evening,
      night: medicine.night,
      beforeFood: medicine.beforeFood,
      notes: medicine.notes,
    );
    _medicines.add(newMedicine);
    NotificationService.addNotification(
      title: 'New Medicine Reminder Added',
      body: 'Reminder set for ${medicine.name} (${medicine.dosage}).',
      type: 'medicine',
    );
    return newMedicine;
  }

  Future<Medicine> editMedicine(Medicine medicine) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _medicines.indexWhere((m) => m.id == medicine.id);
    if (index != -1) {
      _medicines[index] = medicine;
    }
    return medicine;
  }

  Future<void> deleteMedicine(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _medicines.removeWhere((m) => m.id == id);
  }

  Future<Medicine> toggleMedicationTaken(
    String id,
    String slot,
    bool isTaken,
  ) async {
    final index = _medicines.indexWhere((m) => m.id == id);
    if (index == -1) throw Exception("Medicine not found");
    final existing = _medicines[index];
    final updatedTaken = Map<String, bool>.from(existing.takenToday);
    updatedTaken[slot] = isTaken;
    final updated = existing.copyWith(takenToday: updatedTaken);
    _medicines[index] = updated;
    if (isTaken) {
      // Trigger a silent simulator reminder/completion message
      NotificationService.addNotification(
        title: 'Medication Tracked',
        body: 'You marked ${existing.name} ($slot dosage) as taken.',
        type: 'medicine',
      );
    }
    return updated;
  }

  // Resets taken statuses for a new day
  static void resetDailyTracker() {
    for (int i = 0; i < _medicines.length; i++) {
      final med = _medicines[i];
      final resetTaken = <String, bool>{};
      if (med.morning) resetTaken['morning'] = false;
      if (med.afternoon) resetTaken['afternoon'] = false;
      if (med.evening) resetTaken['evening'] = false;
      if (med.night) resetTaken['night'] = false;
      _medicines[i] = med.copyWith(takenToday: resetTaken);
    }
  }
}
