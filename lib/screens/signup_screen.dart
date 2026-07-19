import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}


class _SignupScreenState extends State<SignupScreen> {


  final _formKey = GlobalKey<FormState>();


  //==================================================
  // Controllers
  //==================================================

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final TextEditingController _ageController =
      TextEditingController();

  final TextEditingController _addressController =
      TextEditingController();

  final TextEditingController _emergencyController =
      TextEditingController();


  // Doctor Controllers

  final TextEditingController _qualificationController =
      TextEditingController();

  final TextEditingController _specializationController =
      TextEditingController();

  final TextEditingController _experienceController =
      TextEditingController();

  final TextEditingController _hospitalController =
      TextEditingController();

  final TextEditingController _feeController =
      TextEditingController();

  final TextEditingController _pmdcController =
      TextEditingController();


  final TextEditingController _maxPatientsController =
      TextEditingController(text: "20");



  //==================================================
  // Variables
  //==================================================

  bool _obscurePassword = true;

  bool _obscureConfirmPassword = true;


  String _selectedRole = "patient";

  String _selectedGender = "Male";

  String _selectedBloodGroup = "A+";



  //==================================================
  // Doctor Schedule
  //==================================================

  TimeOfDay? _fromTime;

  TimeOfDay? _toTime;


  int _appointmentDuration = 30;



  //==================================================
  // Days
  //==================================================

  final List<String> _days = [

    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",

  ];


  List<String> _selectedDays = [];



  //==================================================
  // Dropdown Data
  //==================================================


  final List<String> genders = [

    "Male",
    "Female",
    "Other",

  ];


  final List<String> bloodGroups = [

    "A+",
    "A-",
    "B+",
    "B-",
    "AB+",
    "AB-",
    "O+",
    "O-",

  ];



  final List<int> durations = [

    15,
    30,
    45,
    60,

  ];



  //==================================================
  // Dispose
  //==================================================

  @override
  void dispose() {


    _nameController.dispose();

    _emailController.dispose();

    _passwordController.dispose();

    _confirmPasswordController.dispose();

    _ageController.dispose();

    _addressController.dispose();

    _emergencyController.dispose();


    _qualificationController.dispose();

    _specializationController.dispose();

    _experienceController.dispose();

    _hospitalController.dispose();

    _feeController.dispose();

    _pmdcController.dispose();

    _maxPatientsController.dispose();


    super.dispose();

  }




  //==================================================
  // Role Selection Card
  //==================================================


  Widget _roleCard({

    required String title,

    required IconData icon,

    required String value,

  }) {


    final bool selected =
        _selectedRole == value;


    return Expanded(

      child: InkWell(

        borderRadius:
            BorderRadius.circular(16),


        onTap: () {

          setState(() {

            _selectedRole = value;

          });

        },


        child: AnimatedContainer(

          duration:
              const Duration(milliseconds: 250),


          margin:
              const EdgeInsets.symmetric(horizontal: 5),


          padding:
              const EdgeInsets.symmetric(vertical:16),


          decoration: BoxDecoration(

            color: selected
                ? AppColors.primary
                : Colors.grey.shade100,


            borderRadius:
                BorderRadius.circular(16),


            border: Border.all(

              color: selected
                  ? AppColors.primary
                  : Colors.grey.shade300,

            ),

          ),



          child: Column(

            children: [


              Icon(

                icon,

                size:28,

                color: selected
                    ? Colors.white
                    : Colors.grey,

              ),



              const SizedBox(height:8),



              Text(

                title,

                style: TextStyle(

                  color: selected
                      ? Colors.white
                      : Colors.black87,


                  fontWeight:
                      FontWeight.w600,

                ),

              ),


            ],

          ),

        ),

      ),

    );

  }
    //==================================================
  // Premium TextField
  //==================================================


  Widget _textField({

    required TextEditingController controller,

    required String hint,

    required IconData icon,

    bool isPassword = false,

    TextInputType keyboard = TextInputType.text,

  }) {


    return TextFormField(


      controller: controller,


      keyboardType: keyboard,


      obscureText: isPassword
          ? _obscurePassword
          : false,



      validator: (value) {


        if(value == null || value.trim().isEmpty){

          return "Required";

        }



        // Email Validation

        if(controller == _emailController){


          final emailRegex =
              RegExp(r'^[^@]+@[^@]+\.[^@]+$');


          if(!emailRegex.hasMatch(value.trim())){

            return "Enter valid email";

          }

        }



        // Password Validation

        if(controller == _passwordController){


          if(value.length < 6){

            return "Password must be at least 6 characters";

          }

        }



        // Confirm Password

        if(controller == _confirmPasswordController){


          if(value != _passwordController.text){

            return "Passwords do not match";

          }

        }


        return null;


      },



      decoration: InputDecoration(


        hintText: hint,


        prefixIcon: Icon(

          icon,

          color: AppColors.primary,

        ),



        suffixIcon: isPassword

            ? IconButton(

                icon: Icon(

                  _obscurePassword

                      ? Icons.visibility

                      : Icons.visibility_off,

                ),



                onPressed: () {


                  setState(() {


                    _obscurePassword =
                        !_obscurePassword;


                  });


                },

              )

            : null,



        filled: true,


        fillColor: Colors.grey.shade100,



        border: OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(16),


          borderSide:
              BorderSide.none,

        ),



        enabledBorder: OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(16),


          borderSide: BorderSide(

            color: Colors.grey.shade300,

          ),

        ),



        focusedBorder: OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(16),


          borderSide: BorderSide(

            color: AppColors.primary,

            width:2,

          ),

        ),

      ),

    );

  }





  //==================================================
  // Day Chip
  //==================================================


  Widget _dayChip(String day){


    final bool selected =
        _selectedDays.contains(day);



    return FilterChip(


      label: Text(day),


      selected: selected,


      selectedColor:
          AppColors.primary.withOpacity(.15),



      checkmarkColor:
          AppColors.primary,



      onSelected: (value){


        setState((){


          if(value){

            _selectedDays.add(day);

          }

          else{

            _selectedDays.remove(day);

          }


        });


      },


    );


  }






  //==================================================
  // Pick Time
  //==================================================


  Future<void> _pickTime(bool isFrom) async{


    final TimeOfDay? picked =
        await showTimePicker(


          context: context,


          initialTime:
              TimeOfDay.now(),


        );



    if(picked == null) return;



    setState((){


      if(isFrom){

        _fromTime = picked;

      }

      else{

        _toTime = picked;

      }


    });


  }





  //==================================================
  // Time Tile
  //==================================================


  Widget _timeTile({

    required String title,

    required TimeOfDay? time,

    required VoidCallback onTap,

  }){


    return Expanded(


      child: InkWell(


        onTap: onTap,


        borderRadius:
            BorderRadius.circular(16),



        child: Container(


          padding:
              const EdgeInsets.all(16),



          decoration: BoxDecoration(


            color:
                Colors.grey.shade100,


            borderRadius:
                BorderRadius.circular(16),


          ),



          child: Column(


            children: [


              Text(

                title,

                style:
                    const TextStyle(

                      fontWeight:
                          FontWeight.bold,

                    ),

              ),



              const SizedBox(height:8),



              Text(

                time == null

                    ? "--:--"

                    : time.format(context),

              ),


            ],


          ),


        ),


      ),


    );


  }
    //==================================================
  // BUILD UI
  //==================================================


  @override
  Widget build(BuildContext context) {


    final authProvider =
        Provider.of<AuthProvider>(context);



    return Scaffold(


      backgroundColor:
          const Color(0xffF5F7FA),



      body: SafeArea(


        child: Form(


          key: _formKey,



          child: SingleChildScrollView(


            padding:
                const EdgeInsets.symmetric(

                  horizontal:24,

                  vertical:20,

                ),



            child: Column(


              crossAxisAlignment:
                  CrossAxisAlignment.start,



              children: [




                // Back Button

                IconButton(

                  onPressed:(){

                    Navigator.pop(context);

                  },


                  icon:
                      const Icon(Icons.arrow_back_ios),


                ),




                const SizedBox(height:10),





                const Text(


                  "Create Account",


                  style: TextStyle(


                    fontSize:30,


                    fontWeight:
                        FontWeight.bold,


                  ),


                ),




                const SizedBox(height:8),





                const Text(


                  "Join Smart Hospital and book appointments easily.",


                  style: TextStyle(


                    color:Colors.grey,


                    fontSize:15,


                  ),


                ),




                const SizedBox(height:30),





                const Text(


                  "Register As",


                  style:TextStyle(


                    fontWeight:
                        FontWeight.bold,


                    fontSize:16,


                  ),


                ),




                const SizedBox(height:12),





                Row(


                  children:[



                    _roleCard(


                      title:"Patient",


                      icon:Icons.person,


                      value:"patient",


                    ),




                    _roleCard(


                      title:"Doctor",


                      icon:Icons.local_hospital,


                      value:"doctor",


                    ),



                  ],


                ),





                const SizedBox(height:25),





                //==============================
                // Basic Information
                //==============================



                _textField(

                  controller:_nameController,

                  hint:"Full Name",

                  icon:Icons.person_outline,

                ),




                const SizedBox(height:18),




                _textField(

                  controller:_emailController,

                  hint:"Email",

                  icon:Icons.email_outlined,

                  keyboard:
                      TextInputType.emailAddress,

                ),




                const SizedBox(height:18),





                _textField(

                  controller:_passwordController,

                  hint:"Password",

                  icon:Icons.lock_outline,

                  isPassword:true,

                ),





                const SizedBox(height:18),




                TextFormField(


                  controller:
                      _confirmPasswordController,



                  obscureText:
                      _obscureConfirmPassword,



                  validator:(value){



                    if(value == null ||
                       value.isEmpty){


                      return "Required";


                    }



                    if(value !=
                       _passwordController.text){


                      return "Passwords do not match";


                    }



                    return null;


                  },




                  decoration:InputDecoration(


                    hintText:
                        "Confirm Password",



                    prefixIcon:
                        const Icon(

                          Icons.lock_outline,

                          color:
                              AppColors.primary,

                        ),




                    suffixIcon:
                        IconButton(


                          icon:Icon(


                            _obscureConfirmPassword

                                ? Icons.visibility

                                : Icons.visibility_off,


                          ),




                          onPressed:(){


                            setState((){


                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;


                            });


                          },


                        ),





                    filled:true,


                    fillColor:
                        Colors.grey.shade100,




                    border:
                        OutlineInputBorder(


                          borderRadius:
                              BorderRadius.circular(16),


                          borderSide:
                              BorderSide.none,


                        ),



                  ),



                ),





                const SizedBox(height:18),




                _textField(

                  controller:_ageController,

                  hint:"Age",

                  icon:Icons.cake_outlined,

                  keyboard:
                      TextInputType.number,

                ),




                const SizedBox(height:18),




                // Gender Dropdown


                DropdownButtonFormField<String>(


                  value:_selectedGender,



                  decoration:InputDecoration(


                    prefixIcon:
                        const Icon(

                          Icons.people_outline,

                          color:
                              AppColors.primary,

                        ),



                    filled:true,


                    fillColor:
                        Colors.grey.shade100,



                    border:
                        OutlineInputBorder(


                          borderRadius:
                              BorderRadius.circular(16),


                          borderSide:
                              BorderSide.none,


                        ),


                  ),




                  items:genders.map((gender){


                    return DropdownMenuItem(


                      value:gender,


                      child:
                          Text(gender),


                    );


                  }).toList(),





                  onChanged:(value){


                    setState((){


                      _selectedGender=value!;


                    });


                  },



                ),





                const SizedBox(height:18),





                // Blood Group


                DropdownButtonFormField<String>(


                  value:_selectedBloodGroup,



                  decoration:InputDecoration(


                    prefixIcon:
                        const Icon(

                          Icons.bloodtype,

                          color:
                              AppColors.primary,

                        ),




                    filled:true,


                    fillColor:
                        Colors.grey.shade100,




                    border:
                        OutlineInputBorder(


                          borderRadius:
                              BorderRadius.circular(16),


                          borderSide:
                              BorderSide.none,


                        ),



                  ),




                  items:bloodGroups.map((group){


                    return DropdownMenuItem(


                      value:group,


                      child:
                          Text(group),


                    );


                  }).toList(),




                  onChanged:(value){


                    setState((){


                      _selectedBloodGroup=value!;


                    });


                  },


                ),





                const SizedBox(height:18),





                _textField(

                  controller:_addressController,

                  hint:"Address",

                  icon:Icons.home_outlined,

                ),




                const SizedBox(height:18),





                _textField(

                  controller:_emergencyController,

                  hint:"Emergency Contact",

                  icon:Icons.phone,

                  keyboard:
                      TextInputType.phone,

                ),



                const SizedBox(height:25),
                                //==================================================
                // DOCTOR INFORMATION
                //==================================================


                if (_selectedRole == "doctor") ...[



                  const Divider(),


                  const SizedBox(height:20),




                  const Text(


                    "Doctor Information",


                    style:TextStyle(


                      fontSize:20,


                      fontWeight:
                          FontWeight.bold,


                    ),


                  ),




                  const SizedBox(height:20),





                  _textField(

                    controller:_pmdcController,

                    hint:"PMDC Number",

                    icon:Icons.badge_outlined,


                  ),




                  const SizedBox(height:18),





                  _textField(

                    controller:_qualificationController,

                    hint:"Qualification",

                    icon:Icons.school_outlined,


                  ),




                  const SizedBox(height:18),





                  _textField(

                    controller:_specializationController,

                    hint:"Specialization",

                    icon:
                        Icons.medical_services_outlined,


                  ),




                  const SizedBox(height:18),





                  _textField(

                    controller:_experienceController,

                    hint:"Experience (Years)",

                    icon:Icons.work_outline,


                    keyboard:
                        TextInputType.number,


                  ),





                  const SizedBox(height:18),




                  _textField(

                    controller:_hospitalController,

                    hint:"Hospital Name",

                    icon:
                        Icons.local_hospital_outlined,


                  ),




                  const SizedBox(height:18),





                  _textField(

                    controller:_feeController,

                    hint:"Consultation Fee (PKR)",

                    icon:
                        Icons.currency_rupee,


                    keyboard:
                        TextInputType.number,


                  ),





                  const SizedBox(height:20),




                  const Text(


                    "Available Days",


                    style:TextStyle(


                      fontWeight:
                          FontWeight.bold,


                    ),


                  ),




                  const SizedBox(height:10),





                  Wrap(


                    spacing:8,


                    runSpacing:8,


                    children:_days

                        .map(

                          (day)=>

                              _dayChip(day),

                        )

                        .toList(),


                  ),





                  const SizedBox(height:20),





                  Row(


                    children:[




                      _timeTile(


                        title:"From",

                        time:_fromTime,


                        onTap:()=>_pickTime(true),


                      ),




                      const SizedBox(width:12),




                      _timeTile(


                        title:"To",

                        time:_toTime,


                        onTap:()=>_pickTime(false),


                      ),



                    ],


                  ),





                  const SizedBox(height:20),





                  // Appointment Duration


                  DropdownButtonFormField<int>(


                    value:_appointmentDuration,



                    decoration:InputDecoration(


                      labelText:
                          "Appointment Duration",




                      prefixIcon:
                          const Icon(


                            Icons.schedule,


                            color:
                                AppColors.primary,


                          ),




                      filled:true,


                      fillColor:
                          Colors.grey.shade100,




                      border:
                          OutlineInputBorder(


                            borderRadius:
                                BorderRadius.circular(16),


                            borderSide:
                                BorderSide.none,


                          ),


                    ),




                    items:durations.map((duration){



                      return DropdownMenuItem(


                        value:duration,


                        child:
                            Text(

                              "$duration Minutes",

                            ),


                      );



                    }).toList(),





                    onChanged:(value){


                      setState((){


                        _appointmentDuration =
                            value!;


                      });


                    },


                  ),




                  const SizedBox(height:18),





                  _textField(


                    controller:
                        _maxPatientsController,


                    hint:
                        "Maximum Patients Per Day",



                    icon:
                        Icons.people_alt_outlined,



                    keyboard:
                        TextInputType.number,


                  ),





                  const SizedBox(height:25),



                ],
                                //==================================================
                // CREATE ACCOUNT BUTTON
                //==================================================


                SizedBox(

                  width: double.infinity,


                  height:55,


                  child: ElevatedButton(


                    style: ElevatedButton.styleFrom(


                      backgroundColor:
                          AppColors.primary,



                      shape:
                          RoundedRectangleBorder(


                            borderRadius:
                                BorderRadius.circular(16),


                          ),


                    ),





                    onPressed: () async {



                      // Basic Validation

                      if(!_formKey.currentState!.validate()){

                        return;

                      }



                      // Doctor Validation


                      if(_selectedRole == "doctor"){



                        if(_pmdcController.text.trim().isEmpty){


                          ScaffoldMessenger.of(context)
                              .showSnackBar(

                            const SnackBar(

                              content:
                                  Text("Please enter PMDC Number"),

                            ),

                          );

                          return;

                        }




                        if(_selectedDays.isEmpty){


                          ScaffoldMessenger.of(context)
                              .showSnackBar(

                            const SnackBar(

                              content:
                                  Text("Please select available days"),

                            ),

                          );


                          return;


                        }





                        if(_fromTime == null ||
                           _toTime == null){


                          ScaffoldMessenger.of(context)
                              .showSnackBar(

                            const SnackBar(

                              content:
                                  Text("Please select available time"),

                            ),

                          );


                          return;


                        }





                        final fromMinutes =
                            _fromTime!.hour * 60 +
                            _fromTime!.minute;



                        final toMinutes =
                            _toTime!.hour * 60 +
                            _toTime!.minute;




                        if(fromMinutes >= toMinutes){


                          ScaffoldMessenger.of(context)
                              .showSnackBar(

                            const SnackBar(

                              content:
                                  Text(
                                    "From time must be before To time",
                                  ),

                            ),

                          );


                          return;


                        }



                      }





                      Map<String,dynamic>? doctorDetails;




                      if(_selectedRole == "doctor"){



                        doctorDetails = {


                          "qualification":
                              _qualificationController.text.trim(),



                          "specialization":
                              _specializationController.text.trim(),



                          "experience":
                              int.tryParse(
                                _experienceController.text,
                              ) ?? 0,



                          "hospitalName":
                              _hospitalController.text.trim(),



                          "consultationFee":
                              double.tryParse(
                                _feeController.text,
                              ) ?? 0,



                          "pmdcNumber":
                              _pmdcController.text.trim(),




                          "availableDays":
                              _selectedDays,




                          "fromTime":
                              _fromTime!.format(context),




                          "toTime":
                              _toTime!.format(context),




                          "appointmentDuration":
                              _appointmentDuration,




                          "maxPatients":
                              int.tryParse(
                                _maxPatientsController.text,
                              ) ?? 20,

                        };

                      }





                      bool success =
                          await authProvider.register(



                            name:
                                _nameController.text.trim(),




                            email:
                                _emailController.text.trim(),




                            password:
                                _passwordController.text.trim(),




                            age:
                                int.tryParse(
                                  _ageController.text,
                                ) ?? 0,




                            gender:
                                _selectedGender,




                            bloodGroup:
                                _selectedBloodGroup,




                            role:
                                _selectedRole,




                            doctorDetails:
                                doctorDetails,


                          );






                      if(!mounted) return;






                      if(success){



                        ScaffoldMessenger.of(context)
                            .showSnackBar(



                          SnackBar(


                            backgroundColor:
                                Colors.green,



                            content:Text(


                              _selectedRole == "doctor"


                                  ? "Doctor account created. Waiting for Admin Approval."

                                  : "Registration Successful",


                            ),


                          ),



                        );





                        Navigator.pushReplacementNamed(

                          context,

                          AppRoutes.login,

                        );



                      }





                      else{



                        ScaffoldMessenger.of(context)
                            .showSnackBar(



                          SnackBar(


                            backgroundColor:
                                Colors.red,



                            content:Text(


                              authProvider.errorMessage ??

                              "Registration Failed",


                            ),


                          ),



                        );


                      }



                    },





                    child:
                        authProvider.isLoading



                        ? const CircularProgressIndicator(

                            color:
                                Colors.white,

                          )



                        : const Text(


                            "Create Account",



                            style:TextStyle(


                              color:
                                  Colors.white,


                              fontSize:17,


                              fontWeight:
                                  FontWeight.bold,


                            ),



                          ),


                  ),

                ),




                const SizedBox(height:20),





                //==================================================
                // LOGIN
                //==================================================



                Row(


                  mainAxisAlignment:
                      MainAxisAlignment.center,



                  children:[



                    const Text(

                      "Already have an account?",

                    ),





                    TextButton(


                      onPressed:(){


                        Navigator.pushReplacementNamed(

                          context,

                          AppRoutes.login,

                        );


                      },



                      child:const Text(


                        "Login",



                        style:TextStyle(


                          color:
                              AppColors.primary,


                          fontWeight:
                              FontWeight.bold,


                        ),


                      ),


                    ),


                  ],


                ),




              ],

            ),

          ),

        ),

      ),

    );


  }


}