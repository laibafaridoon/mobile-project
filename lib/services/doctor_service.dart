import '../models/doctor.dart';

class DoctorService {
  static final List<Doctor> _doctors = [
    Doctor(
      id: 'doc_1',
      name: 'Dr. Sarah Jenkins',
      qualification: 'MD, DM (Cardiology)',
      specialization: 'Cardiology',
      experience: 12,
      hospitalName: 'Metro Heart Care',
      consultationFee: 120.0,
      rating: 4.9,
      reviewsCount: 142,
      availableDays: ['Mon', 'Tue', 'Wed', 'Fri'],
      availableTimeSlots: [
        '09:00 AM',
        '10:00 AM',
        '11:00 AM',
        '02:00 PM',
        '03:00 PM',
      ],
      contactInfo: '+1 (555) 123-4567',
      imageUrl:
          'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=300',
    ),
    Doctor(
      id: 'doc_2',
      name: 'Dr. Albert Ross',
      qualification: 'MD, DCH (Pediatrics)',
      specialization: 'Pediatrics',
      experience: 15,
      hospitalName: 'St. Jude Children\'s Hospital',
      consultationFee: 90.0,
      rating: 4.8,
      reviewsCount: 215,
      availableDays: ['Mon', 'Wed', 'Thu', 'Sat'],
      availableTimeSlots: [
        '09:30 AM',
        '10:30 AM',
        '11:30 AM',
        '03:30 PM',
        '04:30 PM',
      ],
      contactInfo: '+1 (555) 234-5678',
      imageUrl:
          'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&q=80&w=300',
    ),
    Doctor(
      id: 'doc_3',
      name: 'Dr. Emily Zhao',
      qualification: 'MD (Dermatology)',
      specialization: 'Dermatology',
      experience: 8,
      hospitalName: 'Skin Care & Laser Center',
      consultationFee: 100.0,
      rating: 4.7,
      reviewsCount: 98,
      availableDays: ['Tue', 'Thu', 'Fri'],
      availableTimeSlots: [
        '10:00 AM',
        '11:00 AM',
        '01:00 PM',
        '04:00 PM',
        '05:00 PM',
      ],
      contactInfo: '+1 (555) 345-6789',
      imageUrl:
          'https://images.unsplash.com/photo-1594824813573-246434de83fb?auto=format&fit=crop&q=80&w=300',
    ),
    Doctor(
      id: 'doc_4',
      name: 'Dr. Marcus Patel',
      qualification: 'MD, PhD (Neurology)',
      specialization: 'Neurology',
      experience: 20,
      hospitalName: 'Brain & Spine Institute',
      consultationFee: 150.0,
      rating: 4.95,
      reviewsCount: 310,
      availableDays: ['Mon', 'Tue', 'Thu'],
      availableTimeSlots: [
        '08:00 AM',
        '09:00 AM',
        '10:00 AM',
        '11:00 AM',
        '02:00 PM',
      ],
      contactInfo: '+1 (555) 456-7890',
      imageUrl:
          'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&q=80&w=300',
    ),
    Doctor(
      id: 'doc_5',
      name: 'Dr. Clara Simmons',
      qualification: 'MBBS (General Medicine)',
      specialization: 'General Medicine',
      experience: 10,
      hospitalName: 'City Care Clinic',
      consultationFee: 60.0,
      rating: 4.6,
      reviewsCount: 188,
      availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
      availableTimeSlots: [
        '09:00 AM',
        '10:00 AM',
        '11:00 AM',
        '12:00 PM',
        '02:00 PM',
        '03:00 PM',
        '04:00 PM',
      ],
      contactInfo: '+1 (555) 567-8901',
      imageUrl:
          'https://images.unsplash.com/photo-1527613426441-4da17471b66d?auto=format&fit=crop&q=80&w=300',
    ),
  ];
  Future<List<Doctor>> getDoctors() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.from(_doctors);
  }

  Future<List<Doctor>> searchDoctors(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (query.isEmpty) return List.from(_doctors);
    final lowercaseQuery = query.toLowerCase();
    return _doctors.where((doc) {
      return doc.name.toLowerCase().contains(lowercaseQuery) ||
          doc.specialization.toLowerCase().contains(lowercaseQuery) ||
          doc.hospitalName.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Future<List<Doctor>> getDoctorsBySpecialization(String specialization) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (specialization == 'All') return List.from(_doctors);
    return _doctors
        .where((doc) => doc.specialization == specialization)
        .toList();
  }

  Future<Doctor> addDoctor(Doctor doctor) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final newDoctor = Doctor(
      id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
      name: doctor.name,
      qualification: doctor.qualification,
      specialization: doctor.specialization,
      experience: doctor.experience,
      hospitalName: doctor.hospitalName,
      consultationFee: doctor.consultationFee,
      rating: doctor.rating,
      reviewsCount: doctor.reviewsCount,
      availableDays: doctor.availableDays,
      availableTimeSlots: doctor.availableTimeSlots,
      contactInfo: doctor.contactInfo,
      imageUrl: doctor.imageUrl.isEmpty
          ? 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&q=80&w=300'
          : doctor.imageUrl,
    );
    _doctors.add(newDoctor);
    return newDoctor;
  }

  Future<Doctor> editDoctor(Doctor doctor) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _doctors.indexWhere((doc) => doc.id == doctor.id);
    if (index != -1) {
      _doctors[index] = doctor;
    }
    return doctor;
  }

  Future<void> deleteDoctor(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _doctors.removeWhere((doc) => doc.id == id);
  }
}
