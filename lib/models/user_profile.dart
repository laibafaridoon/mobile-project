class UserProfile {
  final String uid;
  final String name;
  final String email;
  final int age;
  final String gender;
  final String bloodGroup;
  final List<String> medicalHistory;
  final String emergencyContact;
  final String address;
  final String profilePictureUrl;
  final String role; // 'patient', 'doctor', 'admin'

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.age,
    required this.gender,
    required this.bloodGroup,
    required this.medicalHistory,
    required this.emergencyContact,
    required this.address,
    required this.profilePictureUrl,
    this.role = 'patient',
  });

  UserProfile copyWith({
    String? uid,
    String? name,
    String? email,
    int? age,
    String? gender,
    String? bloodGroup,
    List<String>? medicalHistory,
    String? emergencyContact,
    String? address,
    String? profilePictureUrl,
    String? role,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      address: address ?? this.address,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      role: role ?? this.role,
    );
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String userUid) {
    return UserProfile(
      uid: userUid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      medicalHistory: List<String>.from(map['medicalHistory'] ?? []),
      emergencyContact: map['emergencyContact'] ?? '',
      address: map['address'] ?? '',
      profilePictureUrl: map['profilePictureUrl'] ?? '',
      role: map['role'] ?? 'patient',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'age': age,
      'gender': gender,
      'bloodGroup': bloodGroup,
      'medicalHistory': medicalHistory,
      'emergencyContact': emergencyContact,
      'address': address,
      'profilePictureUrl': profilePictureUrl,
      'role': role,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
}
