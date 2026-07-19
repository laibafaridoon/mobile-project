import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../services/doctor_service.dart';

class DoctorProvider with ChangeNotifier {
  final DoctorService _doctorService = DoctorService();
  
  List<Doctor> _allDoctors = [];
  List<Doctor> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  
  List<Doctor> get allDoctors => _allDoctors;
  List<Doctor> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  DoctorProvider() {
    _initializeListener();
  }

  String? _selectedSpecialization;
  String _searchQuery = '';

  List<Doctor> get doctors => _allDoctors;

  List<String> get specializations {
    final specs = _allDoctors.map((doc) => doc.specialization).toSet().toList();
    return specs;
  }

  String? get selectedSpecialization => _selectedSpecialization;

  List<Doctor> get filteredDoctors {
    List<Doctor> list = _allDoctors;
    if (_selectedSpecialization != null && _selectedSpecialization!.isNotEmpty) {
      list = list.where((doc) => doc.specialization.toLowerCase() == _selectedSpecialization!.toLowerCase()).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list.where((doc) =>
          doc.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          doc.specialization.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return list;
  }

  void selectSpecialization(dynamic spec) {
    _selectedSpecialization = spec as String?;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addDoctor(Doctor doctor) async {
    _setLoading(true);
    try {
      await DoctorService.addDoctor(
        doctor,
        name: doctor.name,
        qualification: doctor.qualification,
        specialization: doctor.specialization,
        experience: doctor.experience,
        hospitalName: doctor.hospitalName,
        consultationFee: doctor.consultationFee,
        availableDays: doctor.availableDays,
        availableTimeSlots: doctor.availableTimeSlots,
        contactInfo: doctor.contactInfo,
        imageUrl: doctor.imageUrl.isNotEmpty
            ? doctor.imageUrl
            : 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&q=80&w=300',
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> editDoctor(Doctor doctor) async {
    _setLoading(true);
    try {
      await _doctorService.editDoctor(doctor);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteDoctor(String id) async {
    _setLoading(true);
    try {
      await DoctorService.deleteDoctor(id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _initializeListener() {
    DoctorService.listenToDoctors().listen(
      (doctors) {
        _allDoctors = doctors;
        _searchResults = doctors;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void searchDoctors(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _searchResults = _allDoctors;
    } else {
      _searchResults = _allDoctors
          .where((doc) =>
              doc.name.toLowerCase().contains(query.toLowerCase()) ||
              doc.specialization.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<bool> rateDoctor(String doctorId, double rating) async {
    _setLoading(true);
    try {
      await _doctorService.rateDoctor(doctorId, rating);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }
}