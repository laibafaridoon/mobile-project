import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  final _qualificationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _feeController = TextEditingController();
  final _hospitalController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedBloodGroup = 'O+';
  String _selectedRole = 'patient';
  String _selectedSpecialization = 'General Medicine';
  bool _obscurePassword = true;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
  ];
  final List<String> _roles = ['patient', 'doctor'];
  final List<String> _specializations = [
    'General Medicine',
    'Cardiology',
    'Pediatrics',
    'Dermatology',
    'Neurology',
  ];
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    _qualificationController.dispose();
    _experienceController.dispose();
    _feeController.dispose();
    _hospitalController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final age = int.tryParse(_ageController.text.trim()) ?? 0;
    
    Map<String, dynamic>? docDetails;
    if (_selectedRole == 'doctor') {
      docDetails = {
        'qualification': _qualificationController.text.trim(),
        'specialization': _selectedSpecialization,
        'experience': int.tryParse(_experienceController.text.trim()) ?? 5,
        'consultationFee': double.tryParse(_feeController.text.trim()) ?? 50.0,
        'hospitalName': _hospitalController.text.trim().isNotEmpty
            ? _hospitalController.text.trim()
            : 'City General Hospital',
      };
    }

    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      age: age,
      gender: _selectedGender,
      bloodGroup: _selectedBloodGroup,
      role: _selectedRole,
      doctorDetails: docDetails,
    );
    if (!mounted) return;
    if (success) {
      if (_selectedRole == 'patient') {
          // After patient registration, show login screen
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        } else if (_selectedRole == 'doctor') {
          // After doctor registration, show awaiting approval screen
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.awaitApproval,
            (route) => false,
          );
        }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration failed. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Join Smart Hospital',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 24,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign up to easily book consults and track your queue in real-time.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                // Role Selector
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Register As',
                    prefixIcon: Icon(
                      Icons.assignment_ind_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  items: _roles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role == 'patient' ? 'Patient' : 'Doctor'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedRole = val);
                  },
                ),
                const SizedBox(height: 16),
                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: AppColors.primary,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    if (!value.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Row for Age and Gender
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Age',
                          prefixIcon: Icon(
                            Icons.cake_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter age';
                          }
                          if (int.tryParse(value) == null) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 6,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedGender,
                        decoration: const InputDecoration(
                          labelText: 'Gender',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        items: _genders.map((g) {
                          return DropdownMenuItem(value: g, child: Text(g));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedGender = val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Blood Group Selection
                DropdownButtonFormField<String>(
                  initialValue: _selectedBloodGroup,
                  decoration: const InputDecoration(
                    labelText: 'Blood Group',
                    prefixIcon: Icon(
                      Icons.bloodtype_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  items: _bloodGroups.map((bg) {
                    return DropdownMenuItem(value: bg, child: Text(bg));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedBloodGroup = val);
                  },
                ),
                const SizedBox(height: 16),
                if (_selectedRole == 'doctor') ...[
                  const Text(
                    'Doctor Professional Details',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  // Specialty
                  DropdownButtonFormField<String>(
                    value: _selectedSpecialization,
                    decoration: const InputDecoration(
                      labelText: 'Specialization',
                      prefixIcon: Icon(Icons.star_outline, color: AppColors.primary),
                    ),
                    items: _specializations.map((s) {
                      return DropdownMenuItem(value: s, child: Text(s));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedSpecialization = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  // Qualification
                  TextFormField(
                    controller: _qualificationController,
                    decoration: const InputDecoration(
                      labelText: 'Qualification (e.g. MBBS, MD)',
                      prefixIcon: Icon(Icons.school_outlined, color: AppColors.primary),
                    ),
                    validator: (v) => _selectedRole == 'doctor' && (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  // Experience and Fee Row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _experienceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Experience (Years)',
                            prefixIcon: Icon(Icons.work_history_outlined, color: AppColors.primary),
                          ),
                          validator: (v) => _selectedRole == 'doctor' && (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _feeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Consultation Fee (\$)',
                            prefixIcon: Icon(Icons.attach_money, color: AppColors.primary),
                          ),
                          validator: (v) => _selectedRole == 'doctor' && (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Hospital Name
                  TextFormField(
                    controller: _hospitalController,
                    decoration: const InputDecoration(
                      labelText: 'Hospital/Clinic Name',
                      prefixIcon: Icon(Icons.local_hospital_outlined, color: AppColors.primary),
                    ),
                    validator: (v) => _selectedRole == 'doctor' && (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                ],
                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.primary,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 chars';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                // Register Button
                ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _submit,
                  child: authProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Sign Up'),
                ),
                const SizedBox(height: 24),
                // Redirect to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
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
