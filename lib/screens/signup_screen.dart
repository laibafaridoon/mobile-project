import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
<<<<<<< HEAD
import 'package:intl/intl.dart';
=======

>>>>>>> 4287e5a3a34ae9ec11359ba797f11fe4c5511acf
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
<<<<<<< HEAD
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  // Doctor Specific Controllers
  final _pmdcController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _feeController = TextEditingController();
  final _hospitalController = TextEditingController();
  final _patientLimitController = TextEditingController(text: '20');

  String _selectedGender = 'Male';
  String _selectedBloodGroup = 'O+';
  String _selectedRole = 'patient';
  String _selectedSpecialization = 'General Medicine';
  String _selectedDuration = '30 Minutes';
=======


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

>>>>>>> 4287e5a3a34ae9ec11359ba797f11fe4c5511acf
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  List<String> _selectedDays = [];
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final List<String> _weekDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

<<<<<<< HEAD
  @override
  void dispose() {
    _nameController.dispose(); _emailController.dispose(); _ageController.dispose();
    _passwordController.dispose(); _confirmPasswordController.dispose();
    _addressController.dispose(); _emergencyContactController.dispose();
    _pmdcController.dispose(); _qualificationController.dispose();
    _experienceController.dispose(); _feeController.dispose();
    _hospitalController.dispose(); _patientLimitController.dispose();
=======
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


>>>>>>> 4287e5a3a34ae9ec11359ba797f11fe4c5511acf
    super.dispose();

  }

<<<<<<< HEAD
  // Generate Slots based on Start, End and Duration
  List<String> _generateTimeSlots() {
    if (_startTime == null || _endTime == null) return [];
    List<String> slots = [];
    int duration = int.parse(_selectedDuration.split(' ')[0]);

    DateTime start = DateTime(2024, 1, 1, _startTime!.hour, _startTime!.minute);
    DateTime end = DateTime(2024, 1, 1, _endTime!.hour, _endTime!.minute);

    while (start.isBefore(end)) {
      slots.add(DateFormat('hh:mm a').format(start)); // Corrected format to AM/PM
      start = start.add(Duration(minutes: duration));
    }
    return slots;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match'); return;
    }
    if (_selectedRole == 'doctor' && (_selectedDays.isEmpty || _startTime == null || _endTime == null)) {
      _showError('Please set your available days and time range'); return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    Map<String, dynamic>? docDetails;
    if (_selectedRole == 'doctor') {
      docDetails = {
        'pmdcNumber': _pmdcController.text.trim(),
        'qualification': _qualificationController.text.trim(),
        'specialization': _selectedSpecialization,
        'experience': int.tryParse(_experienceController.text.trim()) ?? 5,
        'consultationFee': double.tryParse(_feeController.text.trim()) ?? 50.0,
        'hospitalName': _hospitalController.text.trim(),
        'availableDays': _selectedDays,
        'startTime': _startTime?.format(context),
        'endTime': _endTime?.format(context),
        'slotDuration': int.parse(_selectedDuration.split(' ')[0]),
        'availableTimeSlots': _generateTimeSlots(),
        'patientLimit': int.tryParse(_patientLimitController.text) ?? 20,
      };
    }

    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      age: int.tryParse(_ageController.text.trim()) ?? 0,
      gender: _selectedGender,
      bloodGroup: _selectedBloodGroup,
      role: _selectedRole,
      doctorDetails: docDetails,
    );

    if (!mounted) return;
    if (success) {
      Navigator.pushNamedAndRemoveUntil(context, _selectedRole == 'patient' ? AppRoutes.login : AppRoutes.awaitApproval, (route) => false);
    } else {
      _showError(authProvider.errorMessage ?? 'Registration failed');
    }
=======



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

>>>>>>> 4287e5a3a34ae9ec11359ba797f11fe4c5511acf
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


  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    // FIX: Defined authProvider here to avoid getter error
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: () => Navigator.pop(context)
          )
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
=======


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



>>>>>>> 4287e5a3a34ae9ec11359ba797f11fe4c5511acf
            child: Column(


              crossAxisAlignment:
                  CrossAxisAlignment.start,



              children: [
<<<<<<< HEAD
                const Text('Create Account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4A5A5C))),
                const SizedBox(height: 8),
                const Text('Join Smart Hospital and book appointments easily.', style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 32),

                const Text('Register As', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildRoleCard('Patient', Icons.person_rounded, 'patient')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildRoleCard('Doctor', Icons.medical_services_rounded, 'doctor')),
                  ],
                ),
                const SizedBox(height: 32),

                _inputField(_nameController, Icons.person_outline, 'Full Name'),
                const SizedBox(height: 16),
                _inputField(_emailController, Icons.email_outlined, 'Email', keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _inputField(_passwordController, Icons.lock_outline, 'Password', isPassword: true, obscure: _obscurePassword, onObscure: () => setState(() => _obscurePassword = !_obscurePassword)),
                const SizedBox(height: 16),
                _inputField(_confirmPasswordController, Icons.lock_outline, 'Confirm Password', isPassword: true, obscure: _obscureConfirm, onObscure: () => setState(() => _obscureConfirm = !_obscureConfirm)),
                const SizedBox(height: 16),
                _inputField(_ageController, Icons.cake_outlined, 'Age', keyboardType: TextInputType.number),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: _inputDecoration(Icons.wc_rounded, 'Gender'),
                  items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (val) => setState(() => _selectedGender = val!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedBloodGroup,
                  decoration: _inputDecoration(Icons.bloodtype_outlined, 'Blood Group'),
                  items: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'].map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                  onChanged: (val) => setState(() => _selectedBloodGroup = val!),
                ),
                const SizedBox(height: 16),
                _inputField(_addressController, Icons.home_outlined, 'Address'),
                const SizedBox(height: 16),
                _inputField(_emergencyContactController, Icons.phone_outlined, 'Emergency Contact', keyboardType: TextInputType.phone),

                if (_selectedRole == 'doctor') ...[
                  const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider()),
                  const Text('Doctor Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A5A5C))),
                  const SizedBox(height: 20),
                  _inputField(_pmdcController, Icons.badge_outlined, 'PMDC Number'),
                  const SizedBox(height: 16),
                  _inputField(_qualificationController, Icons.school_outlined, 'Qualification'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedSpecialization,
                    decoration: _inputDecoration(Icons.add_box_outlined, 'Specialization'),
                    items: ['General Medicine', 'Cardiology', 'Pediatrics', 'Dermatology', 'Neurology'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) => setState(() => _selectedSpecialization = val!),
                  ),
                  const SizedBox(height: 16),
                  _inputField(_experienceController, Icons.work_outline, 'Experience (Years)', keyboardType: TextInputType.number),
                  const SizedBox(height: 16),
                  _inputField(_hospitalController, Icons.local_hospital_outlined, 'Hospital Name'),
                  const SizedBox(height: 16),
                  _inputField(_feeController, Icons.attach_money, 'Consultation Fee (PKR)', keyboardType: TextInputType.number),
                  const SizedBox(height: 24),

                  const Text('Available Days', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _weekDays.map((day) {
                      bool isDaySelected = _selectedDays.contains(day);
                      return ChoiceChip(
                        label: Text(day), selected: isDaySelected,
                        selectedColor: AppColors.primary, labelStyle: TextStyle(color: isDaySelected ? Colors.white : Colors.black),
                        onSelected: (selected) {
                          setState(() => selected ? _selectedDays.add(day) : _selectedDays.remove(day));
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(child: _timePicker('From', _startTime, () async {
                        final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                        if (time != null) setState(() => _startTime = time);
                      })),
                      const SizedBox(width: 16),
                      Expanded(child: _timePicker('To', _endTime, () async {
                        final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                        if (time != null) setState(() => _endTime = time);
                      })),
                    ],
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    value: _selectedDuration,
                    decoration: _inputDecoration(Icons.access_time, 'Appointment Duration'),
                    items: ['15 Minutes', '30 Minutes', '45 Minutes', '60 Minutes'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                    onChanged: (val) => setState(() => _selectedDuration = val!),
                  ),
                  const SizedBox(height: 16),
                  _inputField(_patientLimitController, Icons.people_outline, 'Daily Patient Limit', keyboardType: TextInputType.number),
                ],

                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                  ),
                  child: authProvider.isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Create Account', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(height: 32),
=======




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




>>>>>>> 4287e5a3a34ae9ec11359ba797f11fe4c5511acf
              ],

            ),

          ),

        ),

      ),

    );


  }

<<<<<<< HEAD
  Widget _buildRoleCard(String label, IconData icon, String role) {
    bool isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: isSelected ? AppColors.primary : const Color(0xFFF5F7F7), borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 28),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87)),
        ]),
      ),
    );
  }

  Widget _inputField(TextEditingController controller, IconData icon, String hint, {bool isPassword = false, bool obscure = false, VoidCallback? onObscure, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller, obscureText: obscure, keyboardType: keyboardType,
      decoration: _inputDecoration(icon, hint, suffixIcon: isPassword ? IconButton(icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey), onPressed: onObscure) : null),
      validator: (v) => v!.isEmpty ? 'Required' : null,
    );
  }

  InputDecoration _inputDecoration(IconData icon, String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint, prefixIcon: Icon(icon, color: AppColors.primary, size: 22), suffixIcon: suffixIcon,
      fillColor: const Color(0xFFF5F7F7), filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }

  Widget _timePicker(String label, TimeOfDay? time, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF5F7F7), borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(time?.format(context) ?? '--:--', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
=======

>>>>>>> 4287e5a3a34ae9ec11359ba797f11fe4c5511acf
}