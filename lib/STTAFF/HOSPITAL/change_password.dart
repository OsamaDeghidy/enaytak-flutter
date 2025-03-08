import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _isLoading = false;
  String? token; // To hold the token
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('access'); // Get token
    });
  }

  Future<void> _changePassword() async {
    const String apiUrl = 'http://67.205.166.136/api/password/change/';
    final String oldPassword = _oldPasswordController.text.trim();
    final String newPassword = _newPasswordController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Both fields are required."),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Use the token for authorization

          'X-CSRFTOKEN':
              'P3FjABAEkWU1wc3ikUa0GKXXhY6nbXMgOGMOBNVJPyKiWngSE3cohIvCIh5kRuWP',
        },
        body: json.encode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      setState(() {
        _isLoading = false; // Hide loading indicator
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success: Password changed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Password changed successfully!',
              style: TextStyle(color: Colors.green),
            ),
          ),
        );
        _oldPasswordController.clear();
        _newPasswordController.clear();
      } else {
        // API returned an error
        final responseData = json.decode(response.body);
        print(responseData);
        String errorMessage =
            responseData['detail'] ?? 'Failed to change password.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${responseData}',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        );
      }
    } catch (e) {
      print(e);

      // Network or JSON parsing errors
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An unexpected error occurred: $e',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _oldPasswordController,
                decoration: const InputDecoration(
                  labelText: "Old Password",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your old password.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                decoration: const InputDecoration(
                  labelText: "New Password",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a new password.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _changePassword();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "Change Password",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
