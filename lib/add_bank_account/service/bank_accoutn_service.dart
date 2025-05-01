import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/core/helper/app_helper.dart';
import 'package:http/http.dart' as http;

class ApiServiceForBankAccount {
  static const String baseUrl = 'http://67.205.166.136/api/';

  static Future<void> addBankAccount({
    required String iban,
    required String cardHolderName,
    required String bankName,
    required String userId,
    required String token,
    required BuildContext context,
  }) async {
    try {
      final requestBody = {
        'iban': iban,
        'cardholder_name': cardHolderName,
        'bank_name': bankName,
        'user': userId,
      };

      debugPrint('📤 Request Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('${baseUrl}bank-accounts/'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'X-CSRFTOKEN':
              'TBnER2Sd30Nom2fNH40WwVJoMEWWyJsEEZNB4sXomfYXdTJIHJ7zFRNXr4BtC0EN',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      final decodedBody = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Response: $decodedBody');
        AppHelper.successSnackBar(
            context: context, message: 'Account added successfully!');
        Navigator.of(context).pop();
      } else {
        debugPrint('❌ Status Code: ${response.statusCode}');
        debugPrint('❌ Response Body: $decodedBody');
        AppHelper.errorSnackBar(
            context: context, message: 'Failed to add account: $decodedBody');
        throw Exception('Failed to load services');
      }
    } catch (error) {
      debugPrint('❌ Error in API call: $error');
      throw Exception('Error: $error');
    }
  }
}
