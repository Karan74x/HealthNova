import 'doctor.dart';

/// One of the patient's appointments. `status` is one of Pending, Approved,
/// Rejected or Completed - the backend's APPOINTMENT_STATUSES.
class Appointment {
  const Appointment({
    required this.id,
    required this.doctor,
    required this.date,
    required this.time,
    required this.reason,
    required this.status,
  });

  final String id;
  final Doctor? doctor;
  final DateTime? date;
  final String time;
  final String reason;
  final String status;

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final doctorJson = json['doctor'];
    return Appointment(
      id: json['_id']?.toString() ?? '',
      doctor: doctorJson is Map
          ? Doctor.fromJson(Map<String, dynamic>.from(doctorJson))
          : null,
      date: DateTime.tryParse(json['date']?.toString() ?? '')?.toLocal(),
      time: json['time']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
    );
  }

  bool get isPending => status == 'Pending';

  /// Today or later, and still going ahead.
  bool get isUpcoming {
    final day = date;
    if (day == null) return false;
    if (status == 'Rejected' || status == 'Completed') return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return !DateTime(day.year, day.month, day.day).isBefore(today);
  }
}
