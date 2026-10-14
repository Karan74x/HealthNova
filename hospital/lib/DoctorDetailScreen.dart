import 'package:flutter/material.dart';
import 'package:hospital/models/doctor.dart';
import 'package:hospital/services/healthnova_api.dart';
import 'package:hospital/widgets/common.dart';

/// A doctor's details and the booking form.
class DoctorDetailScreen extends StatefulWidget {
  const DoctorDetailScreen({super.key, required this.doctor});

  final Doctor doctor;

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  /// Half-hour slots across a normal clinic day. The doctor's availability
  /// text is shown above them; the doctor confirms the slot by approving.
  static const List<String> _slots = [
    '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM',
    '12:00 PM', '12:30 PM', '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM',
    '04:00 PM', '04:30 PM', '05:00 PM', '05:30 PM',
  ];

  final reasonController = TextEditingController();
  DateTime? _date;
  String? _time;
  bool _booking = false;

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? today.add(const Duration(days: 1)),
      firstDate: today,
      lastDate: today.add(const Duration(days: 90)),
      helpText: 'Choose appointment date',
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        // A time chosen earlier may already be over on the new date
        final time = _time;
        if (time != null && _slotPassed(time)) _time = null;
      });
    }
  }

  /// Slots already over today cannot be booked.
  bool _slotPassed(String slot) {
    final date = _date;
    if (date == null) return false;
    final now = DateTime.now();
    if (date.year != now.year || date.month != now.month || date.day != now.day) {
      return false;
    }
    final match = RegExp(r'^(\d{1,2}):(\d{2}) (AM|PM)$').firstMatch(slot);
    if (match == null) return false;
    var hour = int.parse(match.group(1)!) % 12;
    if (match.group(3) == 'PM') hour += 12;
    final minute = int.parse(match.group(2)!);
    return hour * 60 + minute <= now.hour * 60 + now.minute;
  }

  Future<void> _book() async {
    final date = _date;
    final time = _time;
    if (date == null || time == null) {
      showMessage(context, 'Choose a date and a time first.', error: true);
      return;
    }

    setState(() => _booking = true);
    try {
      await HealthNovaApi.bookAppointment(
        doctorId: widget.doctor.id,
        date: date,
        time: time,
        reason: reasonController.text,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: Icon(Icons.check_circle, color: Colors.green[700], size: 48),
          title: const Text('Appointment requested'),
          content: Text(
            'Your request with ${widget.doctor.displayName} on '
            '${formatDate(date)} at $time has been sent. You can follow its '
            'status in the Bookings tab.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      showMessage(context, errorText(error), error: true);
      setState(() => _booking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;

    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left_sharp, size: 30, color: Colors.white),
        ),
        title: const Text("Book Appointment"),
        centerTitle: true,
        backgroundColor: Colors.blue[300],
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 22),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Card(
            elevation: 7,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  InitialsAvatar(initials: doctor.initials, radius: 44),
                  const SizedBox(height: 12),
                  Text(
                    doctor.displayName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    doctor.specialization,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const Divider(height: 28),
                  _InfoRow(icon: Icons.school, label: 'Qualification', value: doctor.qualification),
                  _InfoRow(icon: Icons.work, label: 'Experience', value: '${doctor.experience} years'),
                  _InfoRow(
                    icon: Icons.local_hospital,
                    label: 'Hospital',
                    value: doctor.hospital.isNotEmpty ? doctor.hospital : 'Not listed',
                  ),
                  _InfoRow(icon: Icons.payments, label: 'Consultation fee', value: doctor.feeLabel),
                  _InfoRow(
                    icon: Icons.schedule,
                    label: 'Availability',
                    value: doctor.availability.isNotEmpty ? doctor.availability : 'Not listed',
                    highlight: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 7,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose a date',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(_date == null ? 'Select date' : formatDate(_date)),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Choose a time',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final slot in _slots)
                        ChoiceChip(
                          label: Text(slot),
                          selected: _time == slot,
                          onSelected: _slotPassed(slot)
                              ? null
                              : (selected) =>
                                  setState(() => _time = selected ? slot : null),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    maxLength: 200,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Reason for visit (optional)',
                      hintText: 'e.g. Follow-up for blood pressure',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _booking ? null : _book,
                      child: _booking
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Request appointment'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The doctor confirms the request. Until then it shows as Pending, '
                    'and you can cancel it from the Bookings tab.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: highlight ? Colors.green[700] : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
