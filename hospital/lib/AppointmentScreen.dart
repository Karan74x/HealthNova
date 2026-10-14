import 'package:flutter/material.dart';
import 'package:hospital/models/appointment.dart';
import 'package:hospital/services/healthnova_api.dart';
import 'package:hospital/widgets/common.dart';

/// The patient's own appointments, newest first, with their status.
class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

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
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("My Appointments"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 24),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: FutureBuilder<List<Appointment>>(
          future: _appointments,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const LoadingView();
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  ErrorView(message: errorText(snapshot.error!), onRetry: _load),
                ],
              );
            }
            final appointments = snapshot.data!;
            if (appointments.isEmpty) {
              return ListView(
                children: const [
                  EmptyView(
                    icon: Icons.event_busy,
                    message:
                        'No appointments yet.\nFind a doctor in the Doctors tab to book one.',
                  ),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                return _AppointmentCard(
                  appointment: appointment,
                  cancelling: _cancellingId == appointment.id,
                  onCancel: () => _cancel(appointment),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appointment,
    required this.cancelling,
    required this.onCancel,
  });

  final Appointment appointment;
  final bool cancelling;
  final VoidCallback onCancel;

  String get _statusNote {
    switch (appointment.status) {
      case 'Approved':
        return 'Confirmed by the doctor. Please arrive 10 minutes early.';
      case 'Completed':
        return 'Visit completed.';
      case 'Rejected':
        return 'The doctor could not take this request. Please choose another time.';
      default:
        return 'Waiting for the doctor to confirm.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctor = appointment.doctor;
    final color = statusColor(appointment.status);

    return Card(
      elevation: 7,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InitialsAvatar(initials: doctor?.initials ?? 'DR', radius: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor?.displayName ?? 'Doctor no longer available',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (doctor != null)
                        Text(
                          doctor.specialization,
                          style: const TextStyle(color: Colors.grey),
                        ),
                    ],
                  ),
                ),
                StatusChip(label: appointment.status, color: color),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Icon(Icons.calendar_month, size: 18, color: Colors.green[700]),
                const SizedBox(width: 6),
                Text(
                  formatDate(appointment.date),
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.schedule, size: 18, color: Colors.green[700]),
                const SizedBox(width: 6),
                Text(
                  appointment.time,
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (appointment.reason.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Reason: ${appointment.reason}'),
            ],
            const SizedBox(height: 8),
            Text(
              _statusNote,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            if (appointment.isPending)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: cancelling ? null : onCancel,
                  icon: cancelling
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.close),
                  label: const Text('Cancel request'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red[700]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
