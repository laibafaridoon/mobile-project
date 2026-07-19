import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/medicine.dart';
import '../services/medicine_service.dart';

class MedicineProvider with ChangeNotifier {
  final MedicineService _medicineService = MedicineService();

  List<Medicine> _userMedicines = [];
  bool _isLoading = false;
  String? _error;

  List<Medicine> get userMedicines => _userMedicines;
  List<Medicine> get medicines => _userMedicines;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Calculate daily progress (taken / total scheduled)
  double get dailyProgress {
    int totalDoses = 0;
    int takenDoses = 0;
    for (var med in _userMedicines) {
      totalDoses++;
      if (med.isTaken == true) {
        takenDoses++;
      }
    }
    if (totalDoses == 0) return 1.0;
    return takenDoses / totalDoses;
  }

  // Get upcoming medicines
  List<Medicine> get upcomingMedicines =>
      _userMedicines.where((m) => m.endDate.isAfter(DateTime.now())).toList();

  // Get completed medicines
  List<Medicine> get completedMedicines =>
      _userMedicines.where((m) => m.endDate.isBefore(DateTime.now())).toList();

  MedicineProvider() {
    _initializeListener();
  }

  List<Medicine> get morningMedicines =>
      _userMedicines.where((m) => m.morning).toList();

  List<Medicine> get afternoonMedicines =>
      _userMedicines.where((m) => m.afternoon).toList();

  List<Medicine> get eveningMedicines =>
      _userMedicines.where((m) => m.evening).toList();

  List<Medicine> get nightMedicines =>
      _userMedicines.where((m) => m.night).toList();

  // Initialize real-time listener for user's medicines
  void _initializeListener() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      MedicineService.listenToUserMedicines(userId).listen(
        (medicines) {
          _userMedicines = medicines;
          _error = null;
          print(
            '[MedicineProvider] Real-time update: ${medicines.length} medicines',
          );
          notifyListeners();
        },
        onError: (e) {
          _error = e.toString();
          print('[MedicineProvider] Error: $e');
          notifyListeners();
        },
      );
    }
  }

  Future<void> loadMedicines() async {
    _setLoading(true);
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        _userMedicines = await MedicineService.getUserMedicines(userId);
        _error = null;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addMedicine(
    Medicine newMedicine, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _setLoading(true);
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final addedMedicine = await MedicineService.addMedicine(
        userId: userId,
        name: newMedicine.name,
        dosage: newMedicine.dosage,
        morning: newMedicine.morning,
        afternoon: newMedicine.afternoon,
        evening: newMedicine.evening,
        night: newMedicine.night,
        beforeFood: newMedicine.beforeFood,
        notes: newMedicine.notes,
        startDate: startDate,
        endDate: endDate,
      );
      if (addedMedicine != null) {
        _userMedicines.add(addedMedicine);
      }
      _error = null;
      notifyListeners();
      return addedMedicine != null;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> editMedicine(Medicine medicine) async {
    _setLoading(true);
    try {
      await _medicineService.editMedicine(medicine);
      final index = _userMedicines.indexWhere((m) => m.id == medicine.id);
      if (index != -1) {
        _userMedicines[index] = medicine;
      }
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteMedicine(String id) async {
    _setLoading(true);
    try {
      await MedicineService.deleteMedicine(id);
      _userMedicines.removeWhere((m) => m.id == id);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> markAsTaken(String medicineId, String timeSlot) async {
    _setLoading(true);
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final index = _userMedicines.indexWhere((m) => m.id == medicineId);
      if (index == -1) return false;

      final med = _userMedicines[index];
      final updatedTakenToday = Map<String, bool>.from(med.takenToday);
      updatedTakenToday[timeSlot] = true;

      await MedicineService.updateMedicineTakenToday(medicineId, updatedTakenToday);
      await MedicineService.markMedicineAsTaken(
        userId: userId,
        medicineId: medicineId,
        medicineName: med.name,
        timeSlot: timeSlot,
      );

      _userMedicines[index] = med.copyWith(takenToday: updatedTakenToday);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void toggleTaken(String id, String slot, bool val) {
    final index = _userMedicines.indexWhere((m) => m.id == id);
    if (index == -1) return;

    final med = _userMedicines[index];
    final updatedTakenToday = Map<String, bool>.from(med.takenToday);
    updatedTakenToday[slot] = val;

    _userMedicines[index] = med.copyWith(takenToday: updatedTakenToday);
    notifyListeners();

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    MedicineService.updateMedicineTakenToday(id, updatedTakenToday);
    if (val) {
      MedicineService.markMedicineAsTaken(
        userId: userId,
        medicineId: id,
        medicineName: med.name,
        timeSlot: slot,
      );
    }
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
