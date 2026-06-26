import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../services/doctor_service.dart';

class DoctorProvider with ChangeNotifier {
  final DoctorService _doctorService = DoctorService();
  List<Doctor> _doctors = [];
  List<Doctor> _filteredDoctors = [];
  bool _isLoading = false;
  String _selectedSpecialization = 'All';
  String _searchQuery = '';
  Doctor? _selectedDoctor;
  List<Doctor> get doctors => _doctors;
  List<Doctor> get filteredDoctors => _filteredDoctors;
  bool get isLoading => _isLoading;
  String get selectedSpecialization => _selectedSpecialization;
  String get searchQuery => _searchQuery;
  Doctor? get selectedDoctor => _selectedDoctor;
  List<String> get specializations => [
    'All',
    'General Medicine',
    'Cardiology',
    'Pediatrics',
    'Dermatology',
    'Neurology',
  ];
  DoctorProvider() {
    loadDoctors();
  }
  Future<void> loadDoctors() async {
    _setLoading(true);
    try {
      _doctors = await _doctorService.getDoctors();
      _applyFilter();
    } finally {
      _setLoading(false);
    }
  }

  void selectSpecialization(String specialization) {
    _selectedSpecialization = specialization;
    _applyFilter();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilter();
  }

  void selectDoctor(Doctor doctor) {
    _selectedDoctor = doctor;
    notifyListeners();
  }

  Future<void> addDoctor(Doctor doctor) async {
    _setLoading(true);
    try {
      final added = await _doctorService.addDoctor(doctor);
      _doctors.add(added);
      _applyFilter();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> editDoctor(Doctor doctor) async {
    _setLoading(true);
    try {
      final edited = await _doctorService.editDoctor(doctor);
      final index = _doctors.indexWhere((doc) => doc.id == doctor.id);
      if (index != -1) {
        _doctors[index] = edited;
      }
      _applyFilter();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteDoctor(String id) async {
    _setLoading(true);
    try {
      await _doctorService.deleteDoctor(id);
      _doctors.removeWhere((doc) => doc.id == id);
      _applyFilter();
    } finally {
      _setLoading(false);
    }
  }

  void _applyFilter() {
    _filteredDoctors = _doctors.where((doc) {
      final matchSpec =
          _selectedSpecialization == 'All' ||
          doc.specialization == _selectedSpecialization;
      final matchSearch =
          _searchQuery.isEmpty ||
          doc.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          doc.specialization.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          doc.hospitalName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchSpec && matchSearch;
    }).toList();
    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
