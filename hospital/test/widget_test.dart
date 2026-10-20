import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hospital/Login_screen.dart';
import 'package:hospital/models/appointment.dart';
import 'package:hospital/models/doctor.dart';
import 'package:hospital/models/prediction.dart';
import 'package:hospital/services/healthnova_api.dart';
import 'package:hospital/services/session.dart';

/// A token with the given expiry, shaped like the backend's JWTs.
String tokenExpiringAt(DateTime when) {
  String part(Map<String, dynamic> json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  return '${part({'alg': 'HS256', 'typ': 'JWT'})}.'
      '${part({'userId': 'abc', 'role': 'patient', 'exp': when.millisecondsSinceEpoch ~/ 1000})}.'
      'signature';
}

void main() {
  testWidgets('login form asks for email and password', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Please enter email'), findsOneWidget);
    expect(find.text('Please enter password'), findsOneWidget);
  });

  test('a doctor from GET /api/patient/doctors is read correctly', () {
    final doctor = Doctor.fromJson({
      '_id': 'd1',
      'user': {'name': 'Meera Shah', 'email': 'meera@example.com'},
      'specialization': 'Endocrinologist',
      'qualification': 'MBBS, MD',
      'experience': 8,
      'hospital': 'Sunrise Diabetes Centre',
      'fee': 600,
      'availability': 'Mon-Fri 10-2',
    });

    expect(doctor.displayName, 'Dr. Meera Shah');
    expect(doctor.initials, 'MS');
    expect(doctor.feeLabel, '₹600');
    expect(doctor.experience, 8);
  });

  test('an appointment keeps its doctor and status', () {
    final appointment = Appointment.fromJson({
      '_id': 'a1',
      'doctor': {
        '_id': 'd1',
        'user': {'name': 'Dr Alex Doe'},
        'specialization': 'Cardiologist',
      },
      'date': '2099-01-15T12:00:00.000Z',
      'time': '10:30 AM',
      'status': 'Pending',
    });

    expect(appointment.doctor?.displayName, 'Dr Alex Doe');
    expect(appointment.isPending, isTrue);
    expect(appointment.isUpcoming, isTrue);
    expect(appointment.date?.day, 15);
  });

  test('a disease form is built from the prediction service fields', () {
    final model = DiseaseModel.fromJson({
      'key': 'heart',
      'name': 'Heart Disease',
      'metrics': {'accuracy': 0.869},
      'features': [
        {'name': 'age', 'label': 'Age', 'kind': 'number', 'min': 18, 'max': 100, 'step': 1, 'required': true},
        {'name': 'bmi', 'label': 'BMI', 'kind': 'number', 'min': 10, 'max': 70, 'step': 0.1, 'required': false},
        {
          'name': 'sex',
          'label': 'Sex',
          'kind': 'select',
          'required': true,
          'options': [
            {'value': 'male', 'label': 'Male'},
            {'value': 'female', 'label': 'Female'},
          ],
        },
      ],
    });

    expect(model.features.length, 3);
    expect(model.features[0].wholeNumber, isTrue);
    expect(model.features[1].wholeNumber, isFalse);
    expect(model.features[1].required, isFalse);
    expect(model.features[2].isSelect, isTrue);
    expect(model.features[2].options.map((option) => option.value), ['male', 'female']);
  });

  test('booking dates are sent as a plain calendar day', () {
    expect(HealthNovaApi.dateOnly(DateTime(2026, 3, 7, 18, 45)), '2026-03-07');
  });

  test('expired tokens are recognised', () {
    final now = DateTime.now();
    expect(Session.isExpired(tokenExpiringAt(now.add(const Duration(days: 7)))), isFalse);
    expect(Session.isExpired(tokenExpiringAt(now.subtract(const Duration(minutes: 1)))), isTrue);
    expect(Session.isExpired('not-a-token'), isTrue);
  });
}
