import 'dart:typed_data'; // Web compatibility ke liye zaroori hai
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;

  // Nayi images handle karne ka variable
  final ImagePicker _picker = ImagePicker();
  Uint8List? _webImageBytes; // Web par foran preview dikhane ke liye

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _nameController = TextEditingController(text: auth.user?.name);
    _ageController = TextEditingController(text: auth.user?.age.toString());
    _contactController = TextEditingController(
      text: auth.user?.emergencyContact,
    );
    _addressController = TextEditingController(text: auth.user?.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Gallery se image pick karne ka function
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Image size optimize karne ke liye
      );

      if (pickedFile != null) {
        // Web aur mobile dono par smoothly chalane ke liye bytes read karte hain
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint("Image pick karne mein masla aaya: $e");
    }
  }

  void _save(AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saving profile...'),
        backgroundColor: AppColors.primary,
      ),
    );

    String? newImageUrl = auth.user?.profilePictureUrl;

    // Upload image if picked
    if (_webImageBytes != null && _webImageBytes!.isNotEmpty) {
      final uploadedUrl = await auth.authService.uploadProfilePicture(
        auth.user!.uid,
        _webImageBytes!,
      );

      if (uploadedUrl == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture upload failed. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
      newImageUrl = uploadedUrl;
    }

    final updated = auth.user!.copyWith(
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? auth.user!.age,
      emergencyContact: _contactController.text.trim(),
      address: _addressController.text.trim(),
      profilePictureUrl: newImageUrl,
    );

    await auth.updateProfile(updated);

    if (auth.errorMessage != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    setState(() {
      _isEditing = false;
      _webImageBytes = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final profile = auth.user;
    if (profile == null) {
      return const Scaffold(body: Center(child: Text('Please log in.')));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close_rounded : Icons.edit_outlined),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  // Reset fields on cancel
                  _nameController.text = profile.name;
                  _ageController.text = profile.age.toString();
                  _contactController.text = profile.emergencyContact;
                  _addressController.text = profile.address;
                  _webImageBytes = null; // Selection cancel karein
                }
                _isEditing = !_isEditing;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Picture & Name
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _webImageBytes != null
                              ? MemoryImage(_webImageBytes!)
                              : (profile.profilePictureUrl.isNotEmpty
                                        ? NetworkImage(
                                            profile.profilePictureUrl,
                                          )
                                        : null)
                                    as ImageProvider<Object>?,
                          child:
                              _webImageBytes == null &&
                                  profile.profilePictureUrl.isEmpty
                              ? Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                  size: 40,
                                )
                              : null,
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap:
                                  _pickImage, // Camera icon par click karne se gallery khulegi
                              child: CircleAvatar(
                                backgroundColor: AppColors.primary,
                                radius: 18,
                                child: const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!_isEditing) ...[
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        profile.email,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Basic details cards (Grid style)
              if (!_isEditing)
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard('Age', '${profile.age} yrs'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: _buildInfoCard('Gender', profile.gender)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        'Blood Group',
                        profile.bloodGroup,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              // Form fields
              if (_isEditing) ...[
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    prefixIcon: Icon(Icons.cake_outlined),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Enter age' : null,
                ),
                const SizedBox(height: 16),
              ],
              // Address & Contact
              TextFormField(
                controller: _contactController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'Emergency Contact',
                  prefixIcon: Icon(Icons.phone_iphone_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                enabled: _isEditing,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Residential Address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 24),
              // Medical History Card
              if (!_isEditing) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Medical History',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (profile.medicalHistory.isEmpty)
                          const Text(
                            'No medical history logs reported.',
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 13,
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: profile.medicalHistory.map((item) {
                              return Chip(
                                label: Text(item),
                                backgroundColor: AppColors.primaryLight
                                    .withOpacity(0.5),
                                side: BorderSide.none,
                                labelStyle: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              // Action Save Button
              if (_isEditing)
                ElevatedButton(
                  onPressed: () => _save(auth),
                  child: const Text('Save Details'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, {Color? color}) {
    return Card(
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color ?? AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
