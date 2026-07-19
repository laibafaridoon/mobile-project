import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../models/user_profile.dart';
import '../../services/firebase_service.dart';

class ManagePatientsScreen extends StatefulWidget {
  const ManagePatientsScreen({super.key});

  @override
  State<ManagePatientsScreen> createState() => _ManagePatientsScreenState();
}

class _ManagePatientsScreenState extends State<ManagePatientsScreen> {
  List<UserProfile> _allPatients = [];
  List<UserProfile> _filteredPatients = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPatients() async {
    setState(() => _isLoading = true);
    try {
      final snap = await FirebaseService.getCollection(collection: 'users');
      final users = snap.docs.map((doc) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      // Patients are users with role == 'patient'
      final patients = users.where((u) => u.role == 'patient').toList();

      setState(() {
        _allPatients = patients;
        _filterPatients(_searchQuery);
        _isLoading = false;
      });
    } catch (e) {
      print('[ManagePatientsScreen] Error fetching patients: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterPatients(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredPatients = _allPatients;
      } else {
        _filteredPatients = _allPatients.where((p) {
          return p.name.toLowerCase().contains(query.toLowerCase()) ||
              p.email.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _deletePatient(UserProfile patient) async {
    try {
      await FirebaseService.deleteDocument(collection: 'users', docId: patient.uid);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Patient ${patient.name} deleted successfully.')),
      );
      _fetchPatients();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete patient: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showDeleteDialog(UserProfile patient) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Patient Profile'),
          content: Text('Are you sure you want to permanently delete the profile of ${patient.name}? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deletePatient(patient);
              },
              child: const Text('Delete', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showPatientDetails(UserProfile patient) {
    final historyController = TextEditingController(text: patient.medicalHistory.join(', '));
    final contactController = TextEditingController(text: patient.emergencyContact);
    final addressController = TextEditingController(text: patient.address);
    final formKey = GlobalKey<FormState>();

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
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    patient.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Text(
                    patient.email,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoTag('Age', '${patient.age} yrs'),
                      _buildInfoTag('Gender', patient.gender),
                      _buildInfoTag('Blood Group', patient.bloodGroup),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Emergency Contact
                  TextFormField(
                    controller: contactController,
                    decoration: const InputDecoration(
                      labelText: 'Emergency Contact',
                      prefixIcon: Icon(Icons.phone_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Address
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Medical History
                  TextFormField(
                    controller: historyController,
                    decoration: const InputDecoration(
                      labelText: 'Medical History (comma separated)',
                      prefixIcon: Icon(Icons.history_edu_rounded, size: 20),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final historyList = historyController.text
                                .split(',')
                                .map((s) => s.trim())
                                .where((s) => s.isNotEmpty)
                                .toList();

                            final updated = patient.copyWith(
                              emergencyContact: contactController.text.trim(),
                              address: addressController.text.trim(),
                              medicalHistory: historyList,
                            );

                            try {
                              await FirebaseService.updateDocument(
                                collection: 'users',
                                docId: patient.uid,
                                data: updated.toMap(),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Patient profile updated successfully.')),
                                );
                                Navigator.pop(context);
                                _fetchPatients();
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to update: $e'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text('Save Changes'),
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

  Widget _buildInfoTag(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Patients'),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search patients by name or email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterPatients('');
                        },
                      )
                    : null,
              ),
              onChanged: _filterPatients,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _filteredPatients.isEmpty
                    ? const Center(
                        child: Text(
                          'No patients found.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredPatients.length,
                        itemBuilder: (context, index) {
                          final p = _filteredPatients[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.primaryLight,
                                backgroundImage: p.profilePictureUrl.isNotEmpty
                                    ? NetworkImage(p.profilePictureUrl)
                                    : null,
                                child: p.profilePictureUrl.isEmpty
                                    ? const Icon(Icons.person, color: AppColors.primary)
                                    : null,
                              ),
                              title: Text(
                                p.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              subtitle: Text(p.email),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                                    onPressed: () => _showPatientDetails(p),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                                    onPressed: () => _showDeleteDialog(p),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
