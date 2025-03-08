import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditProfile extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfile({required this.userData, Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController fullNameController;
  late TextEditingController phoneNumberController;
  late TextEditingController addressController;

  String? token;
  int? userId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    usernameController =
        TextEditingController(text: widget.userData['username']);
    emailController = TextEditingController(text: widget.userData['email']);
    fullNameController =
        TextEditingController(text: widget.userData['full_name']);
    phoneNumberController =
        TextEditingController(text: widget.userData['phone_number']);
    addressController = TextEditingController(text: widget.userData['address']);
  }

  @override
  void dispose() {
    // Dispose controllers
    usernameController.dispose();
    emailController.dispose();

    fullNameController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> updateUserData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('access');
    userId = prefs.getInt('userId');

    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        fullNameController.text.isEmpty ||
        phoneNumberController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please fill in all fields');
      return;
    }

    final String apiUrl = 'http://67.205.166.136/api/profile/update/';
    final requestBody = json.encode({
      "username": usernameController.text,
      "email": emailController.text,
      "full_name": fullNameController.text,
      "phone_number": phoneNumberController.text,
      "user_type": widget.userData['user_type'],
      "address": addressController.text,
    });

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.put(Uri.parse(apiUrl),
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: requestBody);

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: 'Profile updated successfully.');
        Navigator.pop(
            context, true); // Pass `true` when data is updated successfully
      } else {
        print(response.body);
        Fluttertoast.showToast(msg: 'Error: ${response.body}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'Failed to update profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile '),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Edit Your Profile",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_circle),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : updateUserData,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.teal,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
