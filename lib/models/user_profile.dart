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
// Doctor Information
final String qualification;
final String specialization;
final int experience;
final String hospitalName;
final double consultationFee;
final String pmdcNumber;

// Availability
final List<String> availableDays;
final String startTime;
final String endTime;
final int appointmentDuration;
final int maxPatientsPerDay;

// Approval
final bool isApproved;
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
    this.qualification = '',
this.specialization = '',
this.experience = 0,
this.hospitalName = '',
this.consultationFee = 0,
this.pmdcNumber = '',

this.availableDays = const [],
this.startTime = '',
this.endTime = '',
this.appointmentDuration = 30,
this.maxPatientsPerDay = 20,

this.isApproved = false,
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
    String? qualification,
String? specialization,
int? experience,
String? hospitalName,
double? consultationFee,
String? pmdcNumber,

List<String>? availableDays,
String? startTime,
String? endTime,
int? appointmentDuration,
int? maxPatientsPerDay,

bool? isApproved,
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
      role: role ?? this.role, qualification:
    qualification ?? this.qualification,

specialization:
    specialization ?? this.specialization,

experience:
    experience ?? this.experience,

hospitalName:
    hospitalName ?? this.hospitalName,

consultationFee:
    consultationFee ?? this.consultationFee,

pmdcNumber:
    pmdcNumber ?? this.pmdcNumber,



startTime:
    startTime ?? this.startTime,

endTime:
    endTime ?? this.endTime,

appointmentDuration:
    appointmentDuration ??
        this.appointmentDuration,

maxPatientsPerDay:
    maxPatientsPerDay ??
        this.maxPatientsPerDay,

isApproved:
    isApproved ?? this.isApproved,
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
      role: map['role'] ?? 'patient', qualification:
    map['qualification'] ?? '',

specialization:
    map['specialization'] ?? '',

experience:
    map['experience'] ?? 0,

hospitalName:
    map['hospitalName'] ?? '',

consultationFee:
    (map['consultationFee'] ?? 0).toDouble(),

pmdcNumber:
    map['pmdcNumber'] ?? '',

availableDays:
    List<String>.from(
        map['availableDays'] ?? []),

startTime:
    map['startTime'] ?? '',

endTime:
    map['endTime'] ?? '',

appointmentDuration:
    map['appointmentDuration'] ?? 30,

maxPatientsPerDay:
    map['maxPatientsPerDay'] ?? 20,

isApproved:
    map['isApproved'] ?? false,
      
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
      'qualification': qualification,

'specialization': specialization,

'experience': experience,

'hospitalName': hospitalName,

'consultationFee': consultationFee,

'pmdcNumber': pmdcNumber,

'availableDays': availableDays,

'startTime': startTime,

'endTime': endTime,

'appointmentDuration': appointmentDuration,

'maxPatientsPerDay': maxPatientsPerDay,

'isApproved': isApproved,
    };
  }
}
