import 'package:uuid/uuid.dart';
import '../models/doctor.dart';
import 'firebase_service.dart';

class DoctorService {
  static const uuid = Uuid();

  // Demo doctors (fallback if Firebase is not available)
  static final List<Doctor> _demoDoctors = [
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
      reviewsCount: 187,
      availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
      availableTimeSlots: [
        '08:00 AM',
        '09:00 AM',
        '10:00 AM',
        '11:00 AM',
        '01:00 PM',
        '02:00 PM',
        '03:00 PM',
      ],
      contactInfo: '+1 (555) 567-8901',
      imageUrl:
          'https://images.unsplash.com/photo-1527613426441-4da17471b66d?auto=format&fit=crop&q=80&w=300',
    ),
  ];

  // Get all doctors from Firebase or demo
  static Future<List<Doctor>> getAllDoctors() async {
    try {
      final query = await FirebaseService.getCollection(collection: 'doctors');
      if (query.docs.isNotEmpty) {
        return query.docs
            .map(
              (doc) =>
                  Doctor.fromMap(doc.data() as Map<String, dynamic>, doc.id),
            )
            .toList();
      }
      // Return demo doctors if Firebase is empty
      return _demoDoctors;
    } catch (e) {
      print('[DoctorService] Get All Doctors Error: $e');
      // Return demo doctors as fallback
      return _demoDoctors;
    }
  }

  // Search doctors
  static Future<List<Doctor>> searchDoctors(String query) async {
    try {
      final allDoctors = await getAllDoctors();
      final lowerQuery = query.toLowerCase();
      return allDoctors
          .where(
            (doc) =>
                doc.name.toLowerCase().contains(lowerQuery) ||
                doc.specialization.toLowerCase().contains(lowerQuery) ||
                doc.hospitalName.toLowerCase().contains(lowerQuery),
          )
          .toList();
    } catch (e) {
      print('[DoctorService] Search Error: $e');
      return [];
    }
  }

  // Filter doctors by specialization
  static Future<List<Doctor>> filterBySpecialization(
    String specialization,
  ) async {
    try {
      final allDoctors = await getAllDoctors();
      return allDoctors
          .where(
            (doc) =>
                doc.specialization.toLowerCase() ==
                specialization.toLowerCase(),
          )
          .toList();
    } catch (e) {
      print('[DoctorService] Filter Error: $e');
      return [];
    }
  }

  // Get doctor by ID
  static Future<Doctor?> getDoctorById(String doctorId) async {
    try {
      final allDoctors = await getAllDoctors();
      return allDoctors.firstWhere(
        (doc) => doc.id == doctorId,
        orElse: () => throw Exception('Doctor not found'),
      );
    } catch (e) {
      print('[DoctorService] Get Doctor Error: $e');
      return null;
    }
  }

  // Add doctor (admin only)
  static Future<Doctor?> addDoctor(
    Doctor doctor, {
    required String name,
    required String qualification,
    required String specialization,
    required int experience,
    required String hospitalName,
    required double consultationFee,
    required List<String> availableDays,
    required List<String> availableTimeSlots,
    required String contactInfo,
    required String imageUrl,
  }) async {
    try {
      final doctorId = uuid.v4();
      final doctor = Doctor(
        id: doctorId,
        name: name,
        qualification: qualification,
        specialization: specialization,
        experience: experience,
        hospitalName: hospitalName,
        consultationFee: consultationFee,
        rating: 0.0,
        reviewsCount: 0,
        availableDays: availableDays,
        availableTimeSlots: availableTimeSlots,
        contactInfo: contactInfo,
        imageUrl: imageUrl,
      );

      await FirebaseService.setDocument(
        collection: 'doctors',
        docId: doctorId,
        data: doctor.toMap(),
      );

      return doctor;
    } catch (e) {
      print('[DoctorService] Add Doctor Error: $e');
      return null;
    }
  }

  // Update doctor (admin only)
  static Future<bool> updateDoctor({
    required String doctorId,
    required Map<String, dynamic> updatedData,
  }) async {
    try {
      await FirebaseService.updateDocument(
        collection: 'doctors',
        docId: doctorId,
        data: updatedData,
      );
      return true;
    } catch (e) {
      print('[DoctorService] Update Doctor Error: $e');
      return false;
    }
  }

  // Delete doctor (admin only)
  static Future<bool> deleteDoctor(String doctorId) async {
    try {
      await FirebaseService.deleteDocument(
        collection: 'doctors',
        docId: doctorId,
      );
      return true;
    } catch (e) {
      print('[DoctorService] Delete Doctor Error: $e');
      return false;
    }
  }

  // Add review for doctor
  static Future<bool> addReview({
    required String doctorId,
    required String userId,
    required String userName,
    required double rating,
    required String reviewText,
  }) async {
    try {
      final reviewId = uuid.v4();
      await FirebaseService.addDocument(
        collection: 'reviews',
        data: {
          'reviewId': reviewId,
          'doctorId': doctorId,
          'userId': userId,
          'userName': userName,
          'rating': rating,
          'reviewText': reviewText,
          'createdAt': DateTime.now(),
        },
      );

      // Update doctor's rating
      final allReviews = await FirebaseService.queryCollection(
        collection: 'reviews',
        field: 'doctorId',
        value: doctorId,
      );

      double avgRating = 0;
      for (var review in allReviews.docs) {
        avgRating += review['rating'] as double;
      }
      avgRating = avgRating / allReviews.docs.length;

      await FirebaseService.updateDocument(
        collection: 'doctors',
        docId: doctorId,
        data: {'rating': avgRating, 'reviewsCount': allReviews.docs.length},
      );

      return true;
    } catch (e) {
      print('[DoctorService] Add Review Error: $e');
      return false;
    }
  }

  // Get doctor reviews
  static Future<List<Map<String, dynamic>>> getDoctorReviews(
    String doctorId,
  ) async {
    try {
      final query = await FirebaseService.queryCollection(
        collection: 'reviews',
        field: 'doctorId',
        value: doctorId,
      );
      return query.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('[DoctorService] Get Reviews Error: $e');
      return [];
    }
  }

  // Get all specializations
  static Future<List<String>> getAllSpecializations() async {
    try {
      final allDoctors = await getAllDoctors();
      final specializations = <String>{};
      for (var doctor in allDoctors) {
        specializations.add(doctor.specialization);
      }
      return specializations.toList();
    } catch (e) {
      print('[DoctorService] Get Specializations Error: $e');
      return [];
    }
  }

  // Listen to all doctors
  static Stream<List<Doctor>> listenToDoctors() {
    return FirebaseService.listenToCollection(collection: 'doctors').map((
      snapshot,
    ) {
      if (snapshot.docs.isEmpty) {
        return _demoDoctors;
      }
      return snapshot.docs
          .map(
            (doc) => Doctor.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    });
  }

  Future<List<Doctor>> getDoctors() async {
    return await getAllDoctors();
  }

  Future<Object?> editDoctor(Doctor doctor) async {
    try {
      await FirebaseService.updateDocument(
        collection: 'doctors',
        docId: doctor.id,
        data: doctor.toMap(),
      );
      return true;
    } catch (e) {
      print('[DoctorService] Edit Doctor Error: $e');
      return false;
    }
  }

  Future<void> rateDoctor(String doctorId, double rating) async {
    try {
      final allDoctors = await getAllDoctors();
      final doctor = allDoctors.firstWhere((d) => d.id == doctorId);

      final currentRating = doctor.rating;
      final currentCount = doctor.reviewsCount;
      final newCount = currentCount + 1;
      final newRating = ((currentRating * currentCount) + rating) / newCount;

      await FirebaseService.updateDocument(
        collection: 'doctors',
        docId: doctorId,
        data: {'rating': newRating, 'reviewsCount': newCount},
      );
    } catch (e) {
      print('[DoctorService] Rate Doctor Error: $e');
    }
  }
}
