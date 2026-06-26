import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/doctor.dart';
import '../../providers/doctor_provider.dart';

class ManageDoctorsScreen extends StatefulWidget {
  const ManageDoctorsScreen({super.key});
  @override
  State<ManageDoctorsScreen> createState() => _ManageDoctorsScreenState();
}

class _ManageDoctorsScreenState extends State<ManageDoctorsScreen> {
  void _showDoctorForm(BuildContext context, {Doctor? doctor}) {
    final isEdit = doctor != null;
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: doctor?.name ?? 'Dr. ');
    final qualController = TextEditingController(text: doctor?.qualification);
    final hospitalController = TextEditingController(
      text: doctor?.hospitalName ?? 'City General Hospital',
    );
    final feeController = TextEditingController(
      text: doctor?.consultationFee.toString() ?? '80.0',
    );
    final expController = TextEditingController(
      text: doctor?.experience.toString() ?? '8',
    );
    final contactController = TextEditingController(
      text: doctor?.contactInfo ?? '+1 (555) 901-2345',
    );
    String selectedSpec = doctor?.specialization ?? 'General Medicine';
    final specList = [
      'General Medicine',
      'Cardiology',
      'Pediatrics',
      'Dermatology',
      'Neurology',
    ];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isEdit ? 'Edit Doctor Details' : 'Add New Doctor Profile',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Name
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Doctor Full Name',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter name' : null,
                  ),
                  const SizedBox(height: 12),
                  // Specialty Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: selectedSpec,
                    decoration: const InputDecoration(
                      labelText: 'Specialization',
                    ),
                    items: specList.map((s) {
                      return DropdownMenuItem(value: s, child: Text(s));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) selectedSpec = val;
                    },
                  ),
                  const SizedBox(height: 12),
                  // Qualification
                  TextFormField(
                    controller: qualController,
                    decoration: const InputDecoration(
                      labelText: 'Qualifications (e.g. MD, MBBS)',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter qualification' : null,
                  ),
                  const SizedBox(height: 12),
                  // Hospital name
                  TextFormField(
                    controller: hospitalController,
                    decoration: const InputDecoration(
                      labelText: 'Clinic / Hospital Name',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter hospital' : null,
                  ),
                  const SizedBox(height: 12),
                  // Row for experience & fee
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: expController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Experience (Yrs)',
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Enter exp' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: feeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Consult Fee (\$)',
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Enter fee' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Contact
                  TextFormField(
                    controller: contactController,
                    decoration: const InputDecoration(
                      labelText: 'Contact Information',
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (!formKey.currentState!.validate()) return;

                            final docData = Doctor(
                              id: doctor?.id ?? '',
                              name: nameController.text.trim(),
                              qualification: qualController.text.trim(),
                              specialization: selectedSpec,
                              experience:
                                  int.tryParse(expController.text.trim()) ?? 0,
                              hospitalName: hospitalController.text.trim(),
                              consultationFee:
                                  double.tryParse(feeController.text.trim()) ??
                                  0.0,
                              rating: doctor?.rating ?? 5.0,
                              reviewsCount: doctor?.reviewsCount ?? 1,
                              availableDays:
                                  doctor?.availableDays ??
                                  ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
                              availableTimeSlots:
                                  doctor?.availableTimeSlots ??
                                  [
                                    '09:00 AM',
                                    '10:00 AM',
                                    '11:00 AM',
                                    '02:00 PM',
                                    '03:00 PM',
                                  ],
                              contactInfo: contactController.text.trim(),
                              imageUrl: doctor?.imageUrl ?? '',
                            );
                            final provider = Provider.of<DoctorProvider>(
                              context,
                              listen: false,
                            );
                            if (isEdit) {
                              provider.editDoctor(docData);
                            } else {
                              provider.addDoctor(docData);
                            }
                            Navigator.pop(context);
                          },
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DoctorProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Doctors')),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: provider.doctors.length,
              itemBuilder: (context, index) {
                final doc = provider.doctors[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        doc.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      doc.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    subtitle: Text(
                      '${doc.specialization} • ${doc.qualification}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          onPressed: () =>
                              _showDoctorForm(context, doctor: doc),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.error,
                            size: 20,
                          ),
                          onPressed: () {
                            _showDeleteDialog(context, provider, doc);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDoctorForm(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Doctor', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    DoctorProvider provider,
    Doctor doc,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Doctor'),
          content: Text(
            'Are you sure you want to delete the profile of ${doc.name}? This will clear all scheduling configs.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                provider.deleteDoctor(doc.id);
                Navigator.pop(context);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
