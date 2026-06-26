import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../routes/app_routes.dart';
import '../../models/doctor.dart';

class SearchDoctorScreen extends StatefulWidget {
  const SearchDoctorScreen({super.key});
  @override
  State<SearchDoctorScreen> createState() => _SearchDoctorScreenState();
}

class _SearchDoctorScreenState extends State<SearchDoctorScreen> {
  final _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // Reset search query on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DoctorProvider>(context, listen: false).setSearchQuery('');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doctorProvider = Provider.of<DoctorProvider>(context);
    final aptProvider = Provider.of<AppointmentProvider>(
      context,
      listen: false,
    );
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search doctor, specialty, clinic...',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.primary,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear_rounded,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        doctorProvider.setSearchQuery('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
            style: const TextStyle(fontSize: 14),
            onChanged: (val) {
              doctorProvider.setSearchQuery(val);
              setState(() {}); // refresh suffix clear icon
            },
          ),
        ),
      ),
      body: doctorProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : doctorProvider.filteredDoctors.isEmpty
          ? _buildNoResults()
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: doctorProvider.filteredDoctors.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final doc = doctorProvider.filteredDoctors[index];
                return _buildSearchResultTile(context, doc, aptProvider);
              },
            ),
    );
  }

  Widget _buildSearchResultTile(
    BuildContext context,
    Doctor doc,
    AppointmentProvider aptProvider,
  ) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            doc.imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          doc.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${doc.specialization} • ${doc.qualification}',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              doc.hospitalName,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: AppColors.primary.withOpacity(0.7),
        ),
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.doctorDetail, arguments: doc);
        },
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 72,
              color: AppColors.textLight,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Matches Found',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We couldn\'t find any doctors matching "${_searchController.text}". Check spelling or try a different term.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
