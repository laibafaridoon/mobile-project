// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import '../../models/doctor.dart';
import '../../models/user_profile.dart';

class ManageDoctorRequestsScreen extends StatefulWidget {
  const ManageDoctorRequestsScreen({super.key});

  @override
  State<ManageDoctorRequestsScreen> createState() => _ManageDoctorRequestsScreenState();
}

class _ManageDoctorRequestsScreenState extends State<ManageDoctorRequestsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    try {
      final snap = await FirebaseService.getCollection(collection: 'doctor_requests');
      final data = snap.docs.map((doc) => {...doc.data() as Map<String, dynamic>, 'uid': doc.id}).toList();
      setState(() {
        _requests = data.where((r) => (r['status'] ?? 'pending') == 'pending').toList();
        _loading = false;
      });
    } catch (e) {
      print('[ManageDoctorRequests] Error fetching requests: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _approve(String uid) async {
    await AuthService().approveDoctorRequest(uid);
    await _fetchRequests();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Doctor request approved'), backgroundColor: Colors.green));
  }

  Future<void> _reject(String uid) async {
    await AuthService().rejectDoctorRequest(uid);
    await _fetchRequests();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Doctor request rejected'), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Sign‑Up Requests'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? const Center(child: Text('No pending doctor requests'))
              : ListView.builder(
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final req = _requests[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(req['name'] ?? 'Unnamed'),
                        subtitle: Text(req['email'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => _approve(req['uid']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _reject(req['uid']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
