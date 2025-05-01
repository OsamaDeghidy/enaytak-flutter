import 'dart:convert';

import 'package:flutter_sanar_proj/PATIENT/Screens/call_services/all_services.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://67.205.166.136/api/';

  static Future<AllServices> fetchAllServices() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}services/'),
        headers: {
          'accept': 'application/json',
          'X-CSRFTOKEN':
              'TBnER2Sd30Nom2fNH40WwVJoMEWWyJsEEZNB4sXomfYXdTJIHJ7zFRNXr4BtC0EN',
        },
      );

      if (response.statusCode == 200) {
        // ✅ Decode response body using UTF-8 to correctly handle Arabic text
        final utf8Decoded = utf8.decode(response.bodyBytes);
        return AllServices.fromRawJson(utf8Decoded);
      } else {
        throw Exception('Failed to load services');
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }
}
