class Doctor {
  final String id;
  final String name;
  final String qualification;
  final String specialization;
  final int experience; // in years
  final String hospitalName;
  final double consultationFee;
  final double rating;
  final int reviewsCount;
  final List<String> availableDays; // e.g. ["Mon", "Tue", "Wed", "Thu", "Fri"]
  final List<String> availableTimeSlots; // e.g. ["09:00 AM", "10:00 AM", ...]
  final String contactInfo;
  final String imageUrl;
  Doctor({
    required this.id,
    required this.name,
    required this.qualification,
    required this.specialization,
    required this.experience,
    required this.hospitalName,
    required this.consultationFee,
    required this.rating,
    required this.reviewsCount,
    required this.availableDays,
    required this.availableTimeSlots,
    required this.contactInfo,
    required this.imageUrl,
  });
  // Factory constructor for mock/Firebase conversion if needed
  factory Doctor.fromMap(Map<String, dynamic> map, String docId) {
    return Doctor(
      id: docId,
      name: map['name'] ?? '',
      qualification: map['qualification'] ?? '',
      specialization: map['specialization'] ?? '',
      experience: map['experience'] ?? 0,
      hospitalName: map['hospitalName'] ?? '',
      consultationFee: (map['consultationFee'] ?? 0).toDouble(),
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewsCount: map['reviewsCount'] ?? 0,
      availableDays: List<String>.from(map['availableDays'] ?? []),
      availableTimeSlots: List<String>.from(map['availableTimeSlots'] ?? []),
      contactInfo: map['contactInfo'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'qualification': qualification,
      'specialization': specialization,
      'experience': experience,
      'hospitalName': hospitalName,
      'consultationFee': consultationFee,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'availableDays': availableDays,
      'availableTimeSlots': availableTimeSlots,
      'contactInfo': contactInfo,
      'imageUrl': imageUrl,
    };
  }
}
