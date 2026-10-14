import 'package:flutter/material.dart';
import 'package:hospital/DoctorListScreen.dart';
import 'package:hospital/models/appointment.dart';
import 'package:hospital/pratric.dart';
import 'package:hospital/services/healthnova_api.dart';
import 'package:hospital/services/session.dart';
import 'package:hospital/widgets/common.dart';

/// Tab indexes in bottom_screen, so Home can switch tabs.
const int doctorsTab = 1;
const int appointmentsTab = 2;
const int reportsTab = 3;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onOpenTab});

  final void Function(int index) onOpenTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchcontroller = TextEditingController();
  late Future<List<Appointment>> _appointments;

  @override
  void initState() {
    super.initState();
    _appointments = HealthNovaApi.myAppointments();
  }

  @override
  void dispose() {
    searchcontroller.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final next = HealthNovaApi.myAppointments();
    setState(() => _appointments = next);
    try {
      await next;
    } catch (_) {
      // Shown by the FutureBuilder
    }
  }

  void _search(String text) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorListScreen(initialSearch: text.trim()),
      ),
    );
  }

  String get _initials {
    final source = Session.displayName.trim();
    if (source.isEmpty) return '?';
    final parts = source.split(RegExp(r'\s+'));
    if (parts.length > 1) return (parts[0][0] + parts[1][0]).toUpperCase();
    return source[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const SizedBox(height: 12),
              ListTile(
                leading: InitialsAvatar(initials: _initials, radius: 24),
                title: const Text("Hi, welcome back"),
                titleTextStyle: const TextStyle(color: Colors.blue, fontSize: 20),
                subtitle: Text(Session.displayName),
                subtitleTextStyle:
                    const TextStyle(color: Colors.black, fontSize: 20),
                trailing: IconButton(
                  tooltip: 'My appointments',
                  onPressed: () => widget.onOpenTab(appointmentsTab),
                  icon: const Icon(Icons.notifications_none, color: Colors.black),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: TextFormField(
                    controller: searchcontroller,
                    textInputAction: TextInputAction.search,
                    onFieldSubmitted: _search,
                    decoration: InputDecoration(
                      hintText: "Search for Doctor",
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.arrow_forward, color: Colors.blue),
                        onPressed: () => _search(searchcontroller.text),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const BannerSection(),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    _QuickAction(
                      icon: Icons.medical_services,
                      label: "Find a\ndoctor",
                      onTap: () => widget.onOpenTab(doctorsTab),
                    ),
                    _QuickAction(
                      icon: Icons.calendar_month,
                      label: "My\nappointments",
                      onTap: () => widget.onOpenTab(appointmentsTab),
                    ),
                    _QuickAction(
                      icon: Icons.monitor_heart,
                      label: "Check\ndisease risk",
                      onTap: () => widget.onOpenTab(reportsTab),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Upcoming appointment",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<Appointment>>(
                future: _appointments,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const LoadingView();
                  }
                  if (snapshot.hasError) {
                    return ErrorView(
                      message: errorText(snapshot.error!),
                      onRetry: _refresh,
                    );
                  }
                  final upcoming = snapshot.data!
                      .where((appointment) => appointment.isUpcoming)
                      .toList()
                    ..sort((a, b) => a.date!.compareTo(b.date!));
                  if (upcoming.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Card(
                        child: ListTile(
                          leading: const Icon(Icons.event_available,
                              color: Colors.blue),
                          title: const Text("No upcoming appointments"),
                          subtitle: const Text("Book a doctor in a few taps."),
                          trailing: TextButton(
                            onPressed: () => widget.onOpenTab(doctorsTab),
                            child: const Text("Book"),
                          ),
                        ),
                      ),
                    );
                  }
                  return _NextAppointmentCard(
                    appointment: upcoming.first,
                    onTap: () => widget.onOpenTab(appointmentsTab),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Column(
                children: [
                  Icon(icon, color: Colors.white, size: 30),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NextAppointmentCard extends StatelessWidget {
  const _NextAppointmentCard({required this.appointment, required this.onTap});

  final Appointment appointment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final doctor = appointment.doctor;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        elevation: 7,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                InitialsAvatar(initials: doctor?.initials ?? 'DR'),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor?.displayName ?? 'Doctor',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        doctor?.specialization ?? '',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${formatDate(appointment.date)} · ${appointment.time}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusChip(
                  label: appointment.status,
                  color: statusColor(appointment.status),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
