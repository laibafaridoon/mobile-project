import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/appointment.dart';
import '../models/doctor.dart';
import '../services/appointment_service.dart';



class AppointmentProvider with ChangeNotifier {



  final AppointmentService _appointmentService =
      AppointmentService();



  //==================================================
  // Variables
  //==================================================


  List<Appointment> _userAppointments = [];

  List<Appointment> _allAppointments = [];

  List<Appointment> _doctorAppointments = [];


  Doctor? _selectedDoctor;

  DateTime? _selectedDate;

  String? _selectedTimeSlot;


  bool _isLoading = false;

  String? _error;



  StreamSubscription<List<Appointment>>?
      _doctorAptsSubscription;



  //==================================================
  // Getters
  //==================================================


  List<Appointment> get userAppointments =>
      _userAppointments;


  List<Appointment> get allAppointments =>
      _allAppointments;


  List<Appointment> get appointments =>
      _allAppointments;



  List<Appointment> get doctorAppointments =>
      _doctorAppointments;



  List<Appointment> get activeAppointments =>
      _allAppointments
          .where(
            (appointment) =>
                appointment.status != 'Cancelled',
          )
          .toList();



  List<Appointment> get pastAppointments =>
      _userAppointments
          .where(
            (appointment) =>
                appointment.status == 'Completed' ||
                appointment.status == 'Cancelled',
          )
          .toList();



  bool get isLoading =>
      _isLoading;



  bool get hasError =>
      _error != null;



  String? get error =>
      _error;



  DateTime? get selectedDate =>
      _selectedDate;



  String? get selectedTimeSlot =>
      _selectedTimeSlot;



  Doctor? get selectedDoctor =>
      _selectedDoctor;



  bool get isBookingReady =>
      _selectedDoctor != null &&
      _selectedDate != null &&
      _selectedTimeSlot != null;




  //==================================================
  // Constructor
  //==================================================


  AppointmentProvider(){

    _initializeListener();

  }




  //==================================================
  // User Appointment Listener
  //==================================================


  void _initializeListener(){


    final userId =
        FirebaseAuth.instance.currentUser?.uid;



    if(userId != null){


      AppointmentService
          .listenToUserAppointments(userId)
          .listen(


            (appointments){


              _userAppointments =
                  appointments;


              _allAppointments =
                  appointments;


              _error = null;


              notifyListeners();


            },



            onError:(e){


              _error =
                  e.toString();


              notifyListeners();


            },


          );

    }


  }





  //==================================================
  // Book Appointment
  //==================================================


  Future<bool> bookAppointment({


    required String doctorId,

    required String doctorName,

    required String doctorImageUrl,

    required String specialization,

    required DateTime appointmentDate,

    required String timeSlot,


  }) async {



    _setLoading(true);



    try {



      final userId =
          FirebaseAuth.instance.currentUser?.uid;



      final userName =
          FirebaseAuth.instance.currentUser?.email ??
          "Patient";




      if(userId == null){

        throw Exception(
          "User not authenticated",
        );

      }





      await AppointmentService.bookAppointment(



        patientId: userId,



        patientName: userName,



        doctorId: doctorId,



        doctorName: doctorName,



        doctor: Doctor(



          id: doctorId,



          userId: '',



          name: doctorName,



          email: '',



          imageUrl: doctorImageUrl,



          qualification: '',



          specialization:
              specialization,



          experience: 0,



          hospitalName: '',



          consultationFee: 0,



          pmdcNumber: '',



          availableDays: [],



          availableTimeSlots: [],



          fromTime: '',



          toTime: '',



          appointmentDuration: 30,



          maxPatientsPerDay: 20,



          rating: 0,



          reviewsCount: 0,



          contactInfo: '',


        ),



        doctorImageUrl:
            doctorImageUrl,



        doctorSpecialization:
            specialization,



        appointmentDate:
            appointmentDate,



        date:
            appointmentDate,



        timeSlot:
            timeSlot,


      );



      _error = null;


      notifyListeners();



      return true;



    }

    catch(e){


      _error =
          e.toString();


      notifyListeners();


      return false;


    }


    finally{


      _setLoading(false);


    }


  }






  //==================================================
  // Get Appointment
  //==================================================


  Future<Appointment?> getAppointment(
      String appointmentId) async{


    try{


      return await _appointmentService
          .getAppointmentById(
              appointmentId,
          );


    }

    catch(e){


      _error =
          e.toString();


      notifyListeners();


      return null;


    }


  }
  
  //==================================================
  // Update Appointment Status
  //==================================================


  Future<bool> updateAppointmentStatus(
      String appointmentId,
      String newStatus,
      ) async {


    _setLoading(true);



    try{


      await _appointmentService
          .updateAppointmentStatus(
            appointmentId,
            newStatus,
          );



      _error = null;


      return true;



    }

    catch(e){


      _error =
          e.toString();


      return false;


    }


    finally{


      _setLoading(false);


    }


  }





  //==================================================
  // Cancel Appointment
  //==================================================


  Future<bool> cancelAppointment(
      String appointmentId,
      ) async{


    _setLoading(true);



    try{


      await AppointmentService
          .cancelAppointment(
            appointmentId,
          );



      _error = null;


      return true;



    }

    catch(e){


      _error =
          e.toString();


      return false;


    }


    finally{


      _setLoading(false);


    }


  }





  //==================================================
  // Confirm Appointment
  //==================================================


  Future<Appointment?> confirmAppointment() async{


    if(
      _selectedDoctor == null ||
      _selectedDate == null ||
      _selectedTimeSlot == null
    ){

      return null;

    }



    _setLoading(true);



    try{


      final userId =
          FirebaseAuth.instance.currentUser?.uid;



      final userName =
          FirebaseAuth.instance.currentUser?.email ??
          "Patient";



      if(userId == null){

        throw Exception(
          "User not authenticated",
        );

      }



      final appointment =
          await AppointmentService.bookAppointment(



        patientId:
            userId,



        patientName:
            userName,



        doctor:
            _selectedDoctor!,



        doctorId:
            _selectedDoctor!.id,



        doctorName:
            _selectedDoctor!.name,



        doctorImageUrl:
            _selectedDoctor!.imageUrl,



        doctorSpecialization:
            _selectedDoctor!.specialization,



        appointmentDate:
            _selectedDate!,



        date:
            _selectedDate!,



        timeSlot:
            _selectedTimeSlot!,


      );



      _error = null;



      notifyListeners();



      return appointment;



    }

    catch(e){


      _error =
          e.toString();


      notifyListeners();


      return null;


    }


    finally{


      _setLoading(false);


    }


  }





  //==================================================
  // Booking Selection
  //==================================================


  void setBookingDate(DateTime date){


    _selectedDate = date;


    notifyListeners();


  }





  void setBookingTimeSlot(String slot){


    _selectedTimeSlot =
        slot;


    notifyListeners();


  }





  void startBookingFlow(Doctor doctor){


    _selectedDoctor =
        doctor;


    _selectedDate =
        null;


    _selectedTimeSlot =
        null;


    notifyListeners();


  }





  void loadAppointments(){


    _initializeListener();


  }





  //==================================================
  // Admin
  //==================================================


  void adminUpdateAppointmentStatus(
      String id,
      String val,
      ){


    updateAppointmentStatus(
      id,
      val,
    );


  }





  //==================================================
  // Doctor Appointment Listener
  //==================================================


  void listenToDoctorAppointments(
      String doctorId,
      ){


    _doctorAptsSubscription?.cancel();



    _doctorAptsSubscription =
        AppointmentService
            .listenToDoctorAppointments(
              doctorId,
            )
            .listen(



          (appointments){


            _doctorAppointments =
                appointments;


            notifyListeners();


          },



          onError:(e){


            _error =
                e.toString();


            notifyListeners();


          },


        );


  }





  //==================================================
  // Accept Appointment
  //==================================================


  Future<bool> acceptAppointmentRequest(
      String appointmentId,
      ) async{


    _setLoading(true);



    try{


      final success =
          await AppointmentService
              .acceptAppointment(
                appointmentId,
              );



      if(success){


        _error = null;


        return true;


      }



      _error =
          "Failed to accept appointment";


      return false;



    }

    catch(e){


      _error =
          e.toString();


      return false;


    }


    finally{


      _setLoading(false);


    }


  }





  //==================================================
  // Reject Appointment
  //==================================================


  Future<bool> rejectAppointmentRequest(
      String appointmentId,
      ) async{


    _setLoading(true);



    try{


      final success =
          await AppointmentService
              .rejectAppointment(
                appointmentId,
              );



      if(success){


        _error = null;


        return true;


      }



      _error =
          "Failed to reject appointment";


      return false;



    }

    catch(e){


      _error =
          e.toString();


      return false;


    }


    finally{


      _setLoading(false);


    }


  }





  //==================================================
  // Loading
  //==================================================


  void _setLoading(bool value){


    _isLoading =
        value;


    notifyListeners();


  }





  //==================================================
  // Dispose
  //==================================================


  @override
  void dispose(){


    _doctorAptsSubscription
        ?.cancel();


    super.dispose();


  }



}