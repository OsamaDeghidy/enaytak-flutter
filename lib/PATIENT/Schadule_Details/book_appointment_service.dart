import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppointmentService {
  AppointmentService();

  Future<void> createAppointment({
    required BuildContext context,
    required DateTime selectedDate,
    required int userId,
    required int doctorID,
    required Function onSuccess,
    required Function onFailure,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final appointmentData = {
      "date_time": selectedDate.toIso8601String(),
      "service_type": "teleconsultation",
      "status": "booked",
      "notes": "string",
      "appointment_address": "string",
      "is_follow_up": false,
      "is_confirmed": false,
      "patient": userId,
      "doctor": doctorID,
      "nurse": null,
      "services": [3],
    };

    try {
      final response = await http.post(
        Uri.parse('http://67.205.166.136/api/appointments/'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-CSRFTOKEN':
              'o0Y2YK8sS1VKe1pNcJlrvZ8Gs6Jrf28nnD5xZWtxnDL1EcCnwSnP6XGlTpIoVziW',
          'Authorization': 'Bearer ${prefs.getString('access')}>',
        },
        body: json.encode(appointmentData),
      );

      if (response.statusCode == 201) {
        onSuccess();
      } else {
        onFailure(
            'Another user booked this appointment. Please select another one.');
      }
    } catch (e) {
      onFailure('Failed to create an appointment. Please try again.');
    }
  }
}
