/// A doctor as the patient app sees them: the public profile plus the name
/// from the doctor's account.
class Doctor {
  const Doctor({
    required this.id,
    required this.name,
    required this.email,
    required this.specialization,
    required this.qualification,
    required this.experience,
    required this.hospital,
    required this.fee,
    required this.availability,
  });

  final String id;
  final String name;
  final String email;
  final String specialization;
  final String qualification;
  final int experience;
  final String hospital;
  final num fee;
  final String availability;

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : <String, dynamic>{};
    return Doctor(
      id: _text(json['_id']),
      name: _text(user['name']),
      email: _text(user['email']),
      specialization: _text(json['specialization']),
      qualification: _text(json['qualification']),
      experience: json['experience'] is num
          ? (json['experience'] as num).toInt()
          : 0,
      hospital: _text(json['hospital']),
      fee: json['fee'] is num ? json['fee'] as num : 0,
      availability: _text(json['availability']),
    );
  }

  /// "Dr. Meera Shah"; names already starting with "Dr" are left alone.
  String get displayName {
    final base = name.isNotEmpty ? name : email;
    if (base.isEmpty) return 'Doctor';
    return base.toLowerCase().startsWith('dr') ? base : 'Dr. $base';
  }

  String get initials {
    final source = (name.isNotEmpty ? name : email)
        .replaceFirst(RegExp(r'^dr\.?\s*', caseSensitive: false), '')
        .trim();
    if (source.isEmpty) return 'DR';
    final parts = source.split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return source.substring(0, source.length > 1 ? 2 : 1).toUpperCase();
  }

  String get feeLabel => fee > 0 ? '₹${fee.round()}' : 'Fee not set';

  static String _text(Object? value) => value == null ? '' : value.toString().trim();
}
