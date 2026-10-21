import 'package:flutter/material.dart';
import 'package:hospital/DoctorDetailScreen.dart';
import 'package:hospital/models/doctor.dart';
import 'package:hospital/services/healthnova_api.dart';
import 'package:hospital/widgets/common.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key, this.initialSearch = ''});

  /// Search text carried over from the Home screen's search box.
  final String initialSearch;

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final searchController = TextEditingController();
  late Future<List<Doctor>> _doctors;

  @override
  void initState() {
    super.initState();
    searchController.text = widget.initialSearch;
    _doctors = HealthNovaApi.doctors(search: widget.initialSearch);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final next = HealthNovaApi.doctors(search: searchController.text);
    setState(() => _doctors = next);
    try {
      await next;
    } catch (_) {
      // Shown by the FutureBuilder
    }
  }

  void _clearSearch() {
    searchController.clear();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    // Opened from Home's search there is a page to go back to; as a tab there
    // is not, and popping would leave the app.
    final canGoBack = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: Colors.blue[100],

      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: canGoBack
            ? IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.chevron_left_sharp,
                  size: 30,
                  color: Colors.white,
                ),
              )
            : null,
        title: const Text("Doctors"),
        centerTitle: true,
        backgroundColor: Colors.blue[300],
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 25),
      ),

      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            const SizedBox(height: 20),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: searchController,
                textInputAction: TextInputAction.search,
                onFieldSubmitted: (_) => _load(),
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "Search by name, speciality or hospital",
                  hintStyle: const TextStyle(color: Colors.white),

                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    tooltip: 'Clear search',
                    onPressed: _clearSearch,
                  ),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ),

            FutureBuilder<List<Doctor>>(
              future: _doctors,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const LoadingView();
                }
                if (snapshot.hasError) {
                  return ErrorView(
                    message: errorText(snapshot.error!),
                    onRetry: _load,
                  );
                }
                final doctors = snapshot.data!;
                if (doctors.isEmpty) {
                  return EmptyView(
                    icon: Icons.person_search,
                    message: searchController.text.trim().isEmpty
                        ? "No doctors have been added yet."
                        : "No doctors match \"${searchController.text.trim()}\".",
                  );
                }
                return Column(
                  children: [
                    for (final doctor in doctors)
                      _DoctorCard(
                        doctor: doctor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DoctorDetailScreen(doctor: doctor),
                            ),
                          );
                        },
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Doctor Card - same look as the original static cards, filled from the API
class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.doctor, required this.onTap});

  final Doctor doctor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 7,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Doctor initials in place of a photo
                InitialsAvatar(initials: doctor.initials, radius: 40),

                const SizedBox(width: 20),

                // Doctor Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        doctor.displayName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        doctor.specialization,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(Icons.work,
                              color: Colors.amber, size: 20),

                          const SizedBox(width: 4),

                          Flexible(
                            child: Text(
                              "${doctor.experience} years | ${doctor.feeLabel}",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),

                      if (doctor.hospital.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          doctor.hospital,
                          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        ),
                      ],

                      const Divider(),

                      const Text(
                        "Available:",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              doctor.availability.isNotEmpty
                                  ? doctor.availability
                                  : "Ask when booking",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(Icons.calendar_month, color: Colors.green[700]),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
