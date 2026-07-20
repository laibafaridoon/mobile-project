import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
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
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  List<String> _selectedDays = [];
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final List<String> _weekDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  void dispose() {
    _nameController.dispose(); _emailController.dispose(); _ageController.dispose();
    _passwordController.dispose(); _confirmPasswordController.dispose();
    _addressController.dispose(); _emergencyContactController.dispose();
    _pmdcController.dispose(); _qualificationController.dispose();
    _experienceController.dispose(); _feeController.dispose();
    _hospitalController.dispose(); _patientLimitController.dispose();
    super.dispose();
  }

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
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppColors.error));

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
              ],
            ),
          ),
        ),
      ),
    );
  }

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
}