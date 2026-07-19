import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/doctor_service.dart';
import '../constants/colors.dart';
import '../models/doctor.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({Key? key}) : super(key: key);

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = true;
  Doctor? _doctor;

  // Controllers
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _qualificationCtrl = TextEditingController();
  final TextEditingController _specializationCtrl = TextEditingController();
  final TextEditingController _experienceCtrl = TextEditingController();
  final TextEditingController _hospitalCtrl = TextEditingController();
  final TextEditingController _feeCtrl = TextEditingController();
  final TextEditingController _contactCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDoctor();
  }

  Future<void> _loadDoctor() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final uid = auth.user?.uid;
    if (uid == null) return;
    final doc = await DoctorService.getDoctorById(uid);
        if (doc == null) return;
        if (!mounted) return;
        setState(() {
          _doctor = doc;
          _nameCtrl.text = doc.name;
          _qualificationCtrl.text = doc.qualification;
          _specializationCtrl.text = doc.specialization;
          _experienceCtrl.text = doc.experience.toString();
          _hospitalCtrl.text = doc.hospitalName;
          _feeCtrl.text = doc.consultationFee.toString();
          _contactCtrl.text = doc.contactInfo;
          _loading = false;
        });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final updated = Doctor(
      id: _doctor!.id,
      name: _nameCtrl.text,
      qualification: _qualificationCtrl.text.isNotEmpty ? _qualificationCtrl.text : _doctor!.qualification,
      specialization: _specializationCtrl.text.isNotEmpty ? _specializationCtrl.text : _doctor!.specialization,
      experience: int.tryParse(_experienceCtrl.text) ?? _doctor!.experience,
      hospitalName: _hospitalCtrl.text.isNotEmpty ? _hospitalCtrl.text : _doctor!.hospitalName,
      consultationFee: double.tryParse(_feeCtrl.text) ?? _doctor!.consultationFee,
      rating: _doctor!.rating,
      reviewsCount: _doctor!.reviewsCount,
      availableDays: _doctor!.availableDays,
      availableTimeSlots: _doctor!.availableTimeSlots,
      contactInfo: _contactCtrl.text.isNotEmpty ? _contactCtrl.text : _doctor!.contactInfo,
      imageUrl: _doctor!.imageUrl,
    );
    final success = await DoctorService.updateDoctor(doctorId: updated.id, updatedData: updated.toMap());
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated'), backgroundColor: AppColors.primary),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update failed'), backgroundColor: AppColors.error),
      );
    }
// Duplicate stray code removed
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qualificationCtrl.dispose();
    _specializationCtrl.dispose();
    _experienceCtrl.dispose();
    _hospitalCtrl.dispose();
    _feeCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildTextField('Name', _nameCtrl, required: true),
                    _buildTextField('Qualification', _qualificationCtrl),
                    _buildTextField('Specialization', _specializationCtrl),
                    _buildTextField('Experience (years)', _experienceCtrl, isNumber: true),
                    _buildTextField('Hospital', _hospitalCtrl),
                    _buildTextField('Consultation Fee', _feeCtrl, isNumber: true),
                    _buildTextField('Contact Info', _contactCtrl),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl,
      {bool required = false, bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }
}
