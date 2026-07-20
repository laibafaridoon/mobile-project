class Doctor {

  // Basic Information
  final String id;
  final String userId;
  final String name;
  final String email;
  final String imageUrl;


  // Professional Information
  final String qualification;
  final String specialization;
  final int experience;
  final String hospitalName;
  final double consultationFee;
  final String pmdcNumber;


  // Availability
  final List<String> availableDays;
  final List<String> availableTimeSlots;

  final String fromTime;
  final String toTime;

  final int appointmentDuration;
  final int maxPatientsPerDay;


  // Status
  final bool isApproved;
  final bool isOnline;
  final bool acceptsEmergency;


  // Reviews
  final double rating;
  final int reviewsCount;


  // Contact
  final String contactInfo;



  Doctor({

    required this.id,

    this.userId = '',

    required this.name,

    this.email = '',

    this.imageUrl = '',


    this.qualification = '',

    this.specialization = '',

    this.experience = 0,

    this.hospitalName = '',

    this.consultationFee = 0,

    this.pmdcNumber = '',


    this.availableDays = const [],

    this.availableTimeSlots = const [],


    this.fromTime = '',

    this.toTime = '',


    this.appointmentDuration = 30,

    this.maxPatientsPerDay = 20,


    this.isApproved = false,

    this.isOnline = false,

    this.acceptsEmergency = false,


    this.rating = 0,

    this.reviewsCount = 0,


    this.contactInfo = '',

  });





  Doctor copyWith({

    String? id,

    String? userId,

    String? name,

    String? email,

    String? imageUrl,

    String? qualification,

    String? specialization,

    int? experience,

    String? hospitalName,

    double? consultationFee,

    String? pmdcNumber,

    List<String>? availableDays,

    List<String>? availableTimeSlots,

    String? fromTime,

    String? toTime,

    int? appointmentDuration,

    int? maxPatientsPerDay,

    bool? isApproved,

    bool? isOnline,

    bool? acceptsEmergency,

    double? rating,

    int? reviewsCount,

    String? contactInfo,

  }) {


    return Doctor(

      id: id ?? this.id,

      userId: userId ?? this.userId,

      name: name ?? this.name,

      email: email ?? this.email,

      imageUrl: imageUrl ?? this.imageUrl,


      qualification:
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


      availableDays:
          availableDays ?? this.availableDays,


      availableTimeSlots:
          availableTimeSlots ?? this.availableTimeSlots,


      fromTime:
          fromTime ?? this.fromTime,


      toTime:
          toTime ?? this.toTime,


      appointmentDuration:
          appointmentDuration ?? this.appointmentDuration,


      maxPatientsPerDay:
          maxPatientsPerDay ?? this.maxPatientsPerDay,


      isApproved:
          isApproved ?? this.isApproved,


      isOnline:
          isOnline ?? this.isOnline,


      acceptsEmergency:
          acceptsEmergency ?? this.acceptsEmergency,


      rating:
          rating ?? this.rating,


      reviewsCount:
          reviewsCount ?? this.reviewsCount,


      contactInfo:
          contactInfo ?? this.contactInfo,

    );

  }





  factory Doctor.fromMap(
      Map<String,dynamic> map,
      String docId,
      ){

    return Doctor(

      id: docId,

      userId:
          map['userId'] ?? '',

      name:
          map['name'] ?? '',

      email:
          map['email'] ?? '',

      imageUrl:
          map['imageUrl'] ?? '',


      qualification:
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
            map['availableDays'] ?? [],
          ),


      availableTimeSlots:
          List<String>.from(
            map['availableTimeSlots'] ?? [],
          ),


      fromTime:
          map['fromTime'] ?? '',


      toTime:
          map['toTime'] ?? '',


      appointmentDuration:
          map['appointmentDuration'] ?? 30,


      maxPatientsPerDay:
          map['maxPatientsPerDay'] ?? 20,


      isApproved:
          map['isApproved'] ?? false,


      isOnline:
          map['isOnline'] ?? false,


      acceptsEmergency:
          map['acceptsEmergency'] ?? false,


      rating:
          (map['rating'] ?? 0).toDouble(),


      reviewsCount:
          map['reviewsCount'] ?? 0,


      contactInfo:
          map['contactInfo'] ?? '',

    );

  }





  Map<String,dynamic> toMap(){

    return {

      'userId': userId,

      'name': name,

      'email': email,

      'imageUrl': imageUrl,


      'qualification': qualification,

      'specialization': specialization,

      'experience': experience,

      'hospitalName': hospitalName,

      'consultationFee': consultationFee,

      'pmdcNumber': pmdcNumber,


      'availableDays': availableDays,

      'availableTimeSlots': availableTimeSlots,


      'fromTime': fromTime,

      'toTime': toTime,


      'appointmentDuration': appointmentDuration,

      'maxPatientsPerDay': maxPatientsPerDay,


      'isApproved': isApproved,

      'isOnline': isOnline,

      'acceptsEmergency': acceptsEmergency,


      'rating': rating,

      'reviewsCount': reviewsCount,


      'contactInfo': contactInfo,

    };

  }

}