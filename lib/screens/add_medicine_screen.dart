import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../models/medicine.dart';
import '../../providers/medicine_provider.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});
  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();
  bool _morning = true;
  bool _afternoon = false;
  bool _evening = false;
  bool _night = false;
  bool _beforeFood = false; // default After Food
  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // Check if at least one slot is selected
    if (!_morning && !_afternoon && !_evening && !_night) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one dosage schedule slot'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    final newMedicine = Medicine(
      id: '',
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
    ).addMedicine(newMedicine);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Medicine reminder added successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Medicine Reminder')),
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
                  hintText: 'e.g. Paracetamol',
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
                  hintText: 'e.g. 1 Tablet or 5ml',
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
                  labelText: 'Instructional Notes (Optional)',
                  hintText: 'Take with warm water, keep in fridge, etc.',
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
                child: const Text('Save Reminder'),
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
