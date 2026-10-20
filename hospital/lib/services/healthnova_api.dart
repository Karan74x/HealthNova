import '../models/appointment.dart';
import '../models/doctor.dart';
import '../models/prediction.dart';
import 'api_client.dart';
import 'session.dart';

/// Every backend call the patient app makes, in one place.
///
/// The routes and payloads match backend/src/routes. All /api/patient routes
/// require a patient token; doctors and administrators use the web dashboard.
class HealthNovaApi {
  HealthNovaApi._();

  // ------------------------------------------------------------- account

  /// Signs in and saves the session. Only patient accounts are accepted.
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final body = await ApiClient.post(
      '/api/auth/login',
      {'email': email.trim(), 'password': password},
      auth: false,
    );

    final token = body['token'];
    final user = body['user'];
    if (token is! String || user is! Map) {
      throw const ApiException('Unexpected response from the server.');
    }

    final account = Map<String, dynamic>.from(user);
    if (account['role'] != 'patient') {
      throw const ApiException(
        'This app is for patients. Doctors and administrators sign in on the '
        'HealthNova web dashboard.',
      );
    }

    await Session.save(token, account);
    return account;
  }

  /// Creates a patient account. The backend does not sign the new account
  /// in, so the app logs in straight afterwards.
  static Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await ApiClient.post(
      '/api/auth/register',
      {
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'password': password,
      },
      auth: false,
    );
  }

  static Future<Map<String, dynamic>> getMe() async {
    final body = await ApiClient.get('/api/user/me');
    return _object(body);
  }

  /// Updates name, phone, gender ("Male", "Female", "other" or "" to clear)
  /// and date of birth ("YYYY-MM-DD" or "" to clear).
  static Future<Map<String, dynamic>> updateMe(Map<String, dynamic> changes) async {
    final body = await ApiClient.put('/api/user/me', changes);
    final account = _object(body);
    await Session.updateUser({
      'name': account['name'],
      'phone': account['phone'],
    });
    return account;
  }

  // ------------------------------------------------------------- doctors

  static Future<List<Doctor>> doctors({String search = ''}) async {
    final term = search.trim();
    final body = await ApiClient.get(
      '/api/patient/doctors',
      query: term.isEmpty ? null : {'search': term},
    );
    return _list(body).map(Doctor.fromJson).toList();
  }

  static Future<Doctor> doctor(String id) async {
    final body = await ApiClient.get('/api/patient/doctors/$id');
    return Doctor.fromJson(_object(body));
  }

  // -------------------------------------------------------- appointments

  /// Books an appointment for the signed-in patient. It starts as Pending
  /// until the doctor or an administrator approves it.
  static Future<Appointment> bookAppointment({
    required String doctorId,
    required DateTime date,
    required String time,
    String reason = '',
  }) async {
    final body = await ApiClient.post('/api/patient/appointments', {
      'doctor': doctorId,
      // A calendar day; the backend stores it at midday UTC
      'date': dateOnly(date),
      'time': time,
      'reason': reason.trim(),
    });
    return Appointment.fromJson(_object(body));
  }

  static Future<List<Appointment>> myAppointments() async {
    final body = await ApiClient.get('/api/patient/appointments');
    return _list(body).map(Appointment.fromJson).toList();
  }

  /// Only a Pending request can be cancelled; the backend refuses others.
  static Future<void> cancelAppointment(String id) async {
    await ApiClient.delete('/api/patient/appointments/$id');
  }

  // --------------------------------------------------------- predictions

  static Future<List<DiseaseModel>> predictionModels() async {
    final body = await ApiClient.get('/api/patient/prediction-models');
    return _list(body).map(DiseaseModel.fromJson).toList();
  }

  /// Runs the trained model for [diseaseKey] on [inputs] and stores the
  /// result in the patient's history.
  static Future<PredictionOutcome> predict(
    String diseaseKey,
    Map<String, dynamic> inputs,
  ) async {
    final body = await ApiClient.post('/api/patient/predictions', {
      'disease': diseaseKey,
      'inputs': inputs,
    });
    return PredictionOutcome(
      prediction: Prediction.fromJson(_object(body)),
      disclaimer: body['disclaimer']?.toString() ??
          'This is a screening estimate, not a diagnosis. Please consult a doctor.',
    );
  }

  static Future<List<Prediction>> myPredictions() async {
    final body = await ApiClient.get('/api/patient/predictions');
    return _list(body).map(Prediction.fromJson).toList();
  }

  // ------------------------------------------------------------- helpers

  /// "2026-10-21" for a date, ignoring the time of day.
  static String dateOnly(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  static Map<String, dynamic> _object(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const ApiException('Unexpected response from the server.');
  }

  static List<Map<String, dynamic>> _list(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is! List) return const <Map<String, dynamic>>[];
    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
