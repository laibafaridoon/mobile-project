import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../services/medicine_service.dart';

class MedicineProvider with ChangeNotifier {
  final MedicineService _medicineService = MedicineService();
  List<Medicine> _medicines = [];
  bool _isLoading = false;
  List<Medicine> get medicines => _medicines;
  bool get isLoading => _isLoading;
  // Calculate daily progress (taken / total scheduled)
  double get dailyProgress {
    int totalDoses = 0;
    int takenDoses = 0;
    for (var med in _medicines) {
      med.takenToday.forEach((slot, isTaken) {
        totalDoses++;
        if (isTaken) {
          takenDoses++;
        }
      });
    }
    if (totalDoses == 0) return 1.0;
    return takenDoses / totalDoses;
  }

  // Medicines grouped by schedule slot
  List<Medicine> get morningMedicines =>
      _medicines.where((m) => m.morning).toList();
  List<Medicine> get afternoonMedicines =>
      _medicines.where((m) => m.afternoon).toList();
  List<Medicine> get eveningMedicines =>
      _medicines.where((m) => m.evening).toList();
  List<Medicine> get nightMedicines =>
      _medicines.where((m) => m.night).toList();
  MedicineProvider() {
    loadMedicines();
  }
  Future<void> loadMedicines() async {
    _setLoading(true);
    try {
      _medicines = await _medicineService.getMedicines();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addMedicine(Medicine medicine) async {
    _setLoading(true);
    try {
      final added = await _medicineService.addMedicine(medicine);
      _medicines.add(added);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> editMedicine(Medicine medicine) async {
    _setLoading(true);
    try {
      final edited = await _medicineService.editMedicine(medicine);
      final index = _medicines.indexWhere((m) => m.id == medicine.id);
      if (index != -1) {
        _medicines[index] = edited;
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteMedicine(String id) async {
    _setLoading(true);
    try {
      await _medicineService.deleteMedicine(id);
      _medicines.removeWhere((m) => m.id == id);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleTaken(String id, String slot, bool isTaken) async {
    try {
      final updated = await _medicineService.toggleMedicationTaken(
        id,
        slot,
        isTaken,
      );
      final index = _medicines.indexWhere((m) => m.id == id);
      if (index != -1) {
        _medicines[index] = updated;
        notifyListeners();
      }
    } catch (_) {
      // Handle error silently
    }
  }

  void resetDaily() {
    MedicineService.resetDailyTracker();
    loadMedicines();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
