import 'package:flutter/material.dart';
import 'package:hospital/models/appointment.dart';
import 'package:hospital/services/healthnova_api.dart';
import 'package:hospital/widgets/common.dart';

// Appointment Model
class Appointment {
  final String id;
  final String doctorName;
  final String doctorImage;
  final String specialty;
  final DateTime appointmentDate;
  final TimeOfDay appointmentTime;
  final String status; // "Upcoming", "Completed", "Cancelled"
  final String reason;
  final String clinic;
  final int consultationFee;
  final String notes;
  final double doctorRating;

  Appointment({
    required this.id,
    required this.doctorName,
    required this.doctorImage,
    required this.specialty,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    required this.reason,
    required this.clinic,
    required this.consultationFee,
    required this.notes,
    required this.doctorRating,
  });
}

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  String selectedTab = "Upcoming";

  // Sample appointment data
  final List<Appointment> allAppointments = [
    Appointment(
      id: "A001",
      doctorName: "Dr. Sarah Smith",
      doctorImage: "https://randomuser.me/api/portraits/women/1.jpg",
      specialty: "Dermatologist",
      appointmentDate: DateTime.now().add(const Duration(days: 2)),
      appointmentTime: const TimeOfDay(hour: 14, minute: 0),
      status: "Upcoming",
      reason: "Skin Checkup",
      clinic: "Skin Care Center",
      consultationFee: 400,
      notes: "Bring previous reports",
      doctorRating: 4.8,
    ),
    Appointment(
      id: "A002",
      doctorName: "Dr. Michael Brown",
      doctorImage: "https://randomuser.me/api/portraits/men/3.jpg",
      specialty: "Neurologist",
      appointmentDate: DateTime.now().add(const Duration(days: 5)),
      appointmentTime: const TimeOfDay(hour: 10, minute: 30),
      status: "Upcoming",
      reason: "Follow-up",
      clinic: "Neuro Specialist Clinic",
      consultationFee: 550,
      notes: "Discuss test results",
      doctorRating: 4.6,
    ),
    Appointment(
      id: "A003",
      doctorName: "Dr. Alex Doe",
      doctorImage: "https://randomuser.me/api/portraits/men/1.jpg",
      specialty: "Cardiologist",
      appointmentDate: DateTime.now().subtract(const Duration(days: 3)),
      appointmentTime: const TimeOfDay(hour: 12, minute: 30),
      status: "Completed",
      reason: "Heart Checkup",
      clinic: "Heart Care Clinic",
      consultationFee: 500,
      notes: "ECG done",
      doctorRating: 4.5,
    ),
    Appointment(
      id: "A004",
      doctorName: "Dr. Emily Johnson",
      doctorImage: "https://randomuser.me/api/portraits/women/2.jpg",
      specialty: "Pediatrician",
      appointmentDate: DateTime.now().subtract(const Duration(days: 7)),
      appointmentTime: const TimeOfDay(hour: 11, minute: 0),
      status: "Completed",
      reason: "Vaccination",
      clinic: "Child Care Clinic",
      consultationFee: 350,
      notes: "All vaccines given",
      doctorRating: 4.9,
    ),
    Appointment(
      id: "A005",
      doctorName: "Dr. Raj Patel",
      doctorImage: "https://randomuser.me/api/portraits/men/4.jpg",
      specialty: "Dentist",
      appointmentDate: DateTime.now().subtract(const Duration(days: 10)),
      appointmentTime: const TimeOfDay(hour: 15, minute: 0),
      status: "Cancelled",
      reason: "Dental Cleaning",
      clinic: "Dental Excellence",
      consultationFee: 300,
      notes: "Patient requested cancellation",
      doctorRating: 4.7,
    ),
  ];

  List<Appointment> getFilteredAppointments() {
    if (selectedTab == "Upcoming") {
      return allAppointments.where((apt) => apt.status == "Upcoming").toList();
    } else if (selectedTab == "Completed") {
      return allAppointments.where((apt) => apt.status == "Completed").toList();
    } else {
      return allAppointments.where((apt) => apt.status == "Cancelled").toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Appointment> filteredAppointments = getFilteredAppointments();

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        title: const Text(
          "My Appointments",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tab Navigation
          Container(
            color: Colors.blue[300],
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                _buildTabButton("Upcoming", "Upcoming"),
                _buildTabButton("Completed", "Completed"),
                _buildTabButton("Cancelled", "Cancelled"),
              ],
            ),
          ),

          // Appointments List
          Expanded(
            child: filteredAppointments.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredAppointments.length,
                    itemBuilder: (context, index) {
                      return _buildAppointmentCard(filteredAppointments[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, String tabName) {
    bool isSelected = selectedTab == tabName;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = tabName),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue[600] : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            selectedTab == "Upcoming"
                ? Icons.calendar_today
                : selectedTab == "Completed"
                ? Icons.check_circle
                : Icons.cancel,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            selectedTab == "Upcoming"
                ? "No upcoming appointments"
                : selectedTab == "Completed"
                ? "No completed appointments"
                : "No cancelled appointments",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Book an appointment to get started",
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[400],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              // Navigate to book appointment
            },
            icon: const Icon(Icons.add),
            label: const Text("Book Appointment"),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    Color statusColor = appointment.status == "Upcoming"
        ? Colors.blue
        : appointment.status == "Completed"
        ? Colors.green
        : Colors.red;

    IconData statusIcon = appointment.status == "Upcoming"
        ? Icons.schedule
        : appointment.status == "Completed"
        ? Icons.check_circle
        : Icons.cancel;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AppointmentDetailScreen(appointment: appointment),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          child: Column(
            children: [
              // Header with status
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: statusColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          appointment.status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "ID: ${appointment.id}",
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Doctor info and appointment details
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Doctor Image
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(
                            appointment.doctorImage,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Doctor and appointment details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment.doctorName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${appointment.doctorRating}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    appointment.specialty,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: Colors.blue[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${appointment.appointmentDate.day}/${appointment.appointmentDate.month}/${appointment.appointmentDate.year}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: Colors.blue[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${appointment.appointmentTime.hour}:${appointment.appointmentTime.minute.toString().padLeft(2, '0')}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // Clinic and fee info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Clinic",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              appointment.clinic,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Fee",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "₹${appointment.consultationFee}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Action buttons
                    if (appointment.status == "Upcoming")
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _showRescheduleDialog(appointment);
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text("Reschedule"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _showCancelDialog(appointment);
                              },
                              icon: const Icon(Icons.close),
                              label: const Text("Cancel"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (appointment.status == "Completed")
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Rate doctor
                              },
                              icon: const Icon(Icons.star),
                              label: const Text("Rate Doctor"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Book again
                              },
                              icon: const Icon(Icons.add),
                              label: const Text("Book Again"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRescheduleDialog(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reschedule Appointment"),
        content: const Text("Would you like to reschedule this appointment?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Appointment rescheduled successfully"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text("Reschedule"),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Appointment"),
        content: const Text(
          "Are you sure you want to cancel this appointment? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No, Keep it"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Appointment cancelled"),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text(
              "Yes, Cancel",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// Appointment Detail Screen
class AppointmentDetailScreen extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetailScreen({super.key, required this.appointment});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  late Future<List<Appointment>> _appointments;
  String? _cancellingId;

  @override
  void initState() {
    super.initState();
    _appointments = HealthNovaApi.myAppointments();
  }

  Future<void> _load() async {
    final next = HealthNovaApi.myAppointments();
    setState(() => _appointments = next);
    try {
      await next;
    } catch (_) {
      // Shown by the FutureBuilder
    }
  }

  Future<void> _cancel(Appointment appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel this request?'),
        content: Text(
          'Your request with ${appointment.doctor?.displayName ?? 'the doctor'} on '
          '${formatDate(appointment.date)} at ${appointment.time} will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red[700]),
            child: const Text('Cancel request'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _cancellingId = appointment.id);
    try {
      await HealthNovaApi.cancelAppointment(appointment.id);
      if (!mounted) return;
      showMessage(context, 'Appointment request cancelled.');
      await _load();
    } catch (error) {
      if (!mounted) return;
      showMessage(context, errorText(error), error: true);
    } finally {
      if (mounted) setState(() => _cancellingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Appointment Details",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: appointment.status == "Upcoming"
                    ? Colors.blue[50]
                    : appointment.status == "Completed"
                    ? Colors.green[50]
                    : Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: appointment.status == "Upcoming"
                      ? Colors.blue[200]!
                      : appointment.status == "Completed"
                      ? Colors.green[200]!
                      : Colors.red[200]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    appointment.status == "Upcoming"
                        ? Icons.schedule
                        : appointment.status == "Completed"
                        ? Icons.check_circle
                        : Icons.cancel,
                    size: 40,
                    color: appointment.status == "Upcoming"
                        ? Colors.blue
                        : appointment.status == "Completed"
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.status,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: appointment.status == "Upcoming"
                              ? Colors.blue
                              : appointment.status == "Completed"
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Appointment ID: ${appointment.id}",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Doctor Information
            Text(
              "Doctor Information",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(appointment.doctorImage),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.doctorName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment.specialty,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber[600],
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${appointment.doctorRating}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Appointment Details
            Text(
              "Appointment Details",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              "Date",
              "${appointment.appointmentDate.day}/${appointment.appointmentDate.month}/${appointment.appointmentDate.year}",
              Icons.calendar_today,
            ),
            _buildDetailRow(
              "Time",
              "${appointment.appointmentTime.hour}:${appointment.appointmentTime.minute.toString().padLeft(2, '0')}",
              Icons.access_time,
            ),
            _buildDetailRow("Clinic", appointment.clinic, Icons.location_on),
            _buildDetailRow("Reason", appointment.reason, Icons.note),
            _buildDetailRow(
              "Fee",
              "₹${appointment.consultationFee}",
              Icons.currency_rupee,
            ),

            const SizedBox(height: 20),

            // Additional Notes
            if (appointment.notes.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Notes",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(
                      appointment.notes,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 30),

            // Action Buttons
            if (appointment.status == "Upcoming")
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to video consultation
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.videocam),
                      label: const Text("Join Video Call"),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Call doctor
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.phone),
                      label: const Text("Call Doctor"),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
