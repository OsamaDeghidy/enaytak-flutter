import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/constant.dart';
import 'package:flutter_sanar_proj/core/widgets/custom_gradiant_icon_widget.dart';
import 'package:flutter_sanar_proj/core/widgets/custom_gradiant_text_widget.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegistirationStaffLab extends StatefulWidget {
  final String staffType;

  const RegistirationStaffLab({super.key, required this.staffType});

  @override
  State<RegistirationStaffLab> createState() => _RegistirationStaffLabState();
}

class _RegistirationStaffLabState extends State<RegistirationStaffLab> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _yearsOfExperienceController =
      TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? selectedUser;
  bool isSubmitting = false;
  String? username;
  String? email;
  Map<String, dynamic> userData = {};
  final List<String> languages = ['English', 'Arabic', 'French'];
  final List<String> countries = ['Saudi Arabia', 'Egypt', 'USA'];
  final List<String> cities = ['Riyadh', 'Jeddah', 'Dammam'];
  final List<String> degrees = ['Bachelor', 'Master', 'PhD'];
  final List<String> specializations = [
    'Cardiology',
    'Dermatology',
    'Pediatrics'
  ];
  final List<String> classifications = ['Specialist', 'Consultant', 'Resident'];

  String? selectedLanguage;
  String? selectedCountry;
  String? selectedCity;
  String? selectedDegree;
  String? selectedSpecialization;
  String? selectedClassification;
  String? token;
  int? userId;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('access');
    username = prefs.getString('userName');
    email = prefs.getString('email');
    userId = prefs.getInt('userId');

    // Print the retrieved data to the terminal
    print('Token: $token');
    print('Username: $username');
    print('Email: $email');
    print('User  ID: $userId');

    if (token == null || userId == null) {
      _showErrorSnackBar("No token or user ID found. Please login first.");
      return;
    }

    final String apiUrl = 'http://67.205.166.136/api/users/$userId/';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = json.decode(response.body);
        });
      } else {
        String errorMsg =
            'Error: Unable to fetch user data. Status code: ${response.statusCode}';
        _showErrorSnackBar(errorMsg);
      }
    } catch (e) {
      String errorMsg = 'Failed to load user data: $e';
      _showErrorSnackBar(errorMsg);
    }
  }

  String? licenseDocument;
  String? photoPath;
  Future<void> _pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      setState(() {
        if (type == 'license') {
          licenseDocument = result.files.single.path; // Save the full path
        } else if (type == 'Photo') {
          photoPath = result.files.single.path; // Save the full path
        }
      });
    }
  }

  Future<void> _submitRegistration() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    // Print the retrieved data to the terminal
    String? token = prefs.getString('access');
    String? username = prefs.getString('userName');
    String? email = prefs.getString('email');

    print('Token: $token');
    print('Username: $username');
    print('Email: $email');
    print('User  ID: $userId');

    if (selectedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill in all fields and upload documents.'),
      ));
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    if (!doesFileExist(licenseDocument)) {
      print('ID card file does not exist at path: $licenseDocument');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('ID card file not found. Please select a valid file.'),
      ));
      return;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://67.205.166.136/api/labs/'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'X-CSRFTOKEN': token!,
      });

      request.fields['user'] = userId.toString();
      request.fields['selected_user'] = selectedUser!;
      request.fields['bio'] = 'Sample Bio';
      request.fields['certifications'] = 'Sample Certifications';
      request.fields['years_of_experience'] = '10';
      request.fields['average_rating'] = '4';
      request.fields['city'] = selectedCity!;
      request.fields['region'] = selectedCountry!;
      request.fields['degree'] = selectedDegree!;
      request.fields['classification'] = selectedClassification!;
      request.fields['verification_status'] = 'pending';
      request.fields['name'] = _nameController.text;
      request.fields['address'] = _addressController.text;
      request.fields['description'] = _descriptionController.text;
      request.fields['years_of_experience'] = _yearsOfExperienceController.text;
      request.fields['phone_number'] = _phoneNumberController.text;
      request.fields['email'] = _emailController.text;
      request.files.add(await http.MultipartFile.fromPath(
        'license_document',
        licenseDocument!,
      ));

      var response = await request.send();

      setState(() {
        isSubmitting = false;
      });

      if (response.statusCode == 201) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Registration Successful'),
              content: const Text('You have been successfully registered.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacementNamed(context, '/Login_Signup');
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        final responseBody = await response.stream.bytesToString();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Registration failed: $responseBody'),
        ));
      }
    } catch (e) {
      setState(() {
        isSubmitting = false;
      });

      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred: $e'),
      ));
    }
  }

  bool doesFileExist(String? path) {
    return path != null && File(path).existsSync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text(
          '${widget.staffType} Registration',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Constant.primaryColor,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              icon: Icons.person,
              title: 'Personal Information',
              children: [
                _buildDropdownField(
                  label: 'User',
                  value: selectedUser,
                  items: userData.isNotEmpty
                      ? [
                          DropdownMenuItem(
                            value: userId.toString(), // Save user ID as value
                            child: Text(userData['email']), // Show email
                          )
                        ]
                      : [],
                  onChanged: (value) => setState(() => selectedUser = value),
                ),
              ],
            ),
            _buildSectionCard(
              icon: Icons.location_city,
              title: 'Additional Information',
              children: [
                _buildTextField(
                  label: 'Name',
                  controller: _nameController,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Address',
                  controller: _addressController,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Description',
                  controller: _descriptionController,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Years of Experience',
                  controller: _yearsOfExperienceController,
                  inputType: TextInputType.number, // Only allow numbers
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Phone Number',
                  controller: _phoneNumberController,
                  inputType: TextInputType.phone, // Only allow phone numbers
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  label: 'Email',
                  controller: _emailController,
                  inputType: TextInputType.emailAddress, // Email input type
                ),
              ],
            ),
            _buildSectionCard(
              icon: Icons.person,
              title: 'Personal Information',
              children: [
                _buildDropdownFieldd(
                  icon: Icons.language,
                  label: 'Native Language',
                  value: selectedLanguage,
                  items: languages,
                  onChanged: (value) =>
                      setState(() => selectedLanguage = value),
                ),
                const SizedBox(height: 12),
                _buildDropdownFieldd(
                  icon: Icons.flag,
                  label: 'Country',
                  value: selectedCountry,
                  items: countries,
                  onChanged: (value) => setState(() => selectedCountry = value),
                ),
                const SizedBox(height: 12),
                _buildDropdownFieldd(
                  icon: Icons.location_city,
                  label: 'City',
                  value: selectedCity,
                  items: cities,
                  onChanged: (value) => setState(() => selectedCity = value),
                ),
              ],
            ),
            _buildSectionCard(
              icon: Icons.school,
              title: 'Education',
              children: [
                _buildDropdownFieldd(
                  icon: Icons.school,
                  label: 'Degree',
                  value: selectedDegree,
                  items: degrees,
                  onChanged: (value) => setState(() => selectedDegree = value),
                ),
                const SizedBox(height: 12),
                _buildDropdownFieldd(
                  icon: Icons.medical_services,
                  label: 'Specialization',
                  value: selectedSpecialization,
                  items: specializations,
                  onChanged: (value) =>
                      setState(() => selectedSpecialization = value),
                ),
                const SizedBox(height: 12),
                _buildDropdownFieldd(
                  icon: Icons.work,
                  label: 'Classification',
                  value: selectedClassification,
                  items: classifications,
                  onChanged: (value) =>
                      setState(() => selectedClassification = value),
                ),
              ],
            ),
            _buildSectionCard(
              icon: Icons.folder,
              title: 'Documents',
              children: [
                _buildUploadButton(
                  label: 'Upload license',
                  filePath: licenseDocument,
                  onPressed: () => _pickFile('license'),
                ),
                const SizedBox(height: 12),
              ],
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submitRegistration,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor:
                      isSubmitting ? Colors.grey : Constant.primaryColor,
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomGradiantIconWidget(icon: icon, iconSize: 24),
                const SizedBox(width: 8),
                CustomGradiantTextWidget(
                    text: title, fontSize: 20, fontWeight: FontWeight.bold),
              ],
            ),
            const Divider(thickness: 1, color: Constant.primaryColor),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.teal, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Constant.primaryColor, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
    );
  }

  Widget _buildDropdownFieldd({
    required IconData icon,
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: CustomGradiantIconWidget(icon: icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Constant.primaryColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Constant.primaryColor, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Constant.primaryColor, width: 1),
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildUploadButton({
    required String label,
    required String? filePath,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Constant.primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: onPressed,
      child: Text(filePath == null ? label : '$label: $filePath'),
    );
  }
}
