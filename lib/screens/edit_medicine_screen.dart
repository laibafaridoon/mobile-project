import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/medicine.dart';
import '../../providers/medicine_provider.dart';

class EditMedicineScreen extends StatefulWidget {
  final Medicine medicine;
  const EditMedicineScreen({super.key, required this.medicine});
  @override
  State<EditMedicineScreen> createState() => _EditMedicineScreenState();
}

class _EditMedicineScreenState extends State<EditMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _dosageController;
  late TextEditingController _notesController;
  late bool _morning;
  late bool _afternoon;
  late bool _evening;
  late bool _night;
  late bool _beforeFood;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medicine.name);
    _dosageController = TextEditingController(text: widget.medicine.dosage);
    _notesController = TextEditingController(text: widget.medicine.notes);
    _morning = widget.medicine.morning;
    _afternoon = widget.medicine.afternoon;
    _evening = widget.medicine.evening;
    _night = widget.medicine.night;
    _beforeFood = widget.medicine.beforeFood;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_morning && !_afternoon && !_evening && !_night) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one dosage schedule slot'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    final updatedMedicine = widget.medicine.copyWith(
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      morning: _morning,
      afternoon: _afternoon,
      evening: _evening,
      night: _night,
      beforeFood: _beforeFood,
      notes: _notesController.text.trim(),
    );
    Provider.of<MedicineProvider>(
      context,
      listen: false,
    ).editMedicine(updatedMedicine);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Medicine reminder updated successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _delete() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Reminder'),
          content: Text(
            'Are you sure you want to delete the reminder for ${widget.medicine.name}?',
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
                Provider.of<MedicineProvider>(
                  context,
                  listen: false,
                ).deleteMedicine(widget.medicine.id);
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close edit screen

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Medicine reminder deleted'),
                    backgroundColor: AppColors.error,
                  ),
                );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Medicine Reminder'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
            ),
            onPressed: _delete,
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
              // Medicine Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Medicine Name',
                  prefixIcon: Icon(
                    Icons.medication_rounded,
                    color: AppColors.primary,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter medicine name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Dosage
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage Quantity',
                  prefixIcon: Icon(
                    Icons.scale_rounded,
                    color: AppColors.primary,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter dosage details';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Schedule slots selectors
              const Text(
                'Schedule Timing',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildScheduleChip(
                    'Morning',
                    _morning,
                    (val) => setState(() => _morning = val),
                  ),
                  _buildScheduleChip(
                    'Afternoon',
                    _afternoon,
                    (val) => setState(() => _afternoon = val),
                  ),
                  _buildScheduleChip(
                    'Evening',
                    _evening,
                    (val) => setState(() => _evening = val),
                  ),
                  _buildScheduleChip(
                    'Night',
                    _night,
                    (val) => setState(() => _night = val),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Food intake setting
              const Text(
                'Food Settings',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Before Food')),
                      selected: _beforeFood,
                      selectedColor: AppColors.primaryLight,
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _beforeFood
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: _beforeFood
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        setState(() => _beforeFood = true);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('After Food')),
                      selected: !_beforeFood,
                      selectedColor: AppColors.primaryLight,
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: !_beforeFood
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: !_beforeFood
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        setState(() => _beforeFood = false);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Instructional Notes',
                  prefixIcon: Icon(
                    Icons.notes_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // Submit Button
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleChip(
    String label,
    bool isSelected,
    Function(bool) onSelected,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryLight,
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        fontSize: 12,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: onSelected,
    );
  }
}
