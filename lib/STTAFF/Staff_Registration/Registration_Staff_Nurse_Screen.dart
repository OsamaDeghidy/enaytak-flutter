import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationNurseScreen extends StatefulWidget {
  final String staffType;

  const RegistrationNurseScreen({super.key, required this.staffType});

  @override
  _RegistrationNurseScreenState createState() =>
      _RegistrationNurseScreenState();
}

class _RegistrationNurseScreenState extends State<RegistrationNurseScreen> {
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
  String? idCardPath;
  String? photoPath;

  bool isSubmitting = false;
  int? userId;

  Future<void> _pickFile(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      setState(() {
        if (type == 'ID Card') {
          idCardPath = result.files.single.path; // Save the full path
        } else if (type == 'Photo') {
          photoPath = result.files.single.path; // Save the full path
        }
      });
    }
  }

  Future<void> _submitRegistration() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (selectedLanguage == null ||
        selectedCountry == null ||
        selectedCity == null ||
        selectedDegree == null ||
        selectedClassification == null ||
        idCardPath == null ||
        photoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill in all fields and upload documents.'),
      ));
      return;
    }

    // Check if files exist
    if (!doesFileExist(idCardPath)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('ID card file not found. Please select a valid file.'),
      ));
      return;
    }

    if (!doesFileExist(photoPath)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Photo file not found. Please select a valid file.'),
      ));
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://67.205.166.136/api/nurses/'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'X-CSRFTOKEN':
            'wzKXgSD2kFjamEHNgVBhCvTmKMvXdbDehXaUtiIdDUuJdvbIgAIULrXVpcauhsPn',
      });

      request.fields['bio'] = 'dhdhdjdj';
      request.fields['certifications'] = 'sjsjskksks';
      request.fields['years_of_experience'] = '11';
      request.fields['city'] = selectedCity!;
      request.fields['region'] = selectedCountry!;
      request.fields['degree'] = selectedDegree!;
      request.fields['classification'] = selectedClassification!;
      request.fields['verification_status'] = 'pending';
      request.fields['user'] = userId.toString();
      // request.fields['hospital'] = ''; // Add hospital if needed
      // request.fields['specializations'] =
      //     '[]'; // Adjust for any specializations
      // request.fields['services'] = '[]'; // Adjust for any services

      // Add files
      request.files.add(await http.MultipartFile.fromPath(
        'id_card_image',
        idCardPath!,
      ));
      request.files.add(await http.MultipartFile.fromPath(
        'personal_photo',
        photoPath!,
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
        backgroundColor: Colors.teal,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: 'Personal Information',
              icon: Icons.person,
              children: [
                _buildDropdownField(
                  label: 'Native Language',
                  value: selectedLanguage,
                  items: languages,
                  onChanged: (value) =>
                      setState(() => selectedLanguage = value),
                ),
                const SizedBox(height: 12),
                _buildDropdownField(
                  label: 'Country',
                  value: selectedCountry,
                  items: countries,
                  onChanged: (value) => setState(() => selectedCountry = value),
                ),
                const SizedBox(height: 12),
                _buildDropdownField(
                  label: 'City',
                  value: selectedCity,
                  items: cities,
                  onChanged: (value) => setState(() => selectedCity = value),
                ),
              ],
            ),
            _buildSectionCard(
              title: 'Education',
              icon: Icons.school,
              children: [
                _buildDropdownField(
                  label: 'Degree',
                  value: selectedDegree,
                  items: degrees,
                  onChanged: (value) => setState(() => selectedDegree = value),
                ),
                const SizedBox(height: 12),
                _buildDropdownField(
                  label: 'Specialization',
                  value: selectedSpecialization,
                  items: specializations,
                  onChanged: (value) =>
                      setState(() => selectedSpecialization = value),
                ),
                const SizedBox(height: 12),
                _buildDropdownField(
                  label: 'Classification',
                  value: selectedClassification,
                  items: classifications,
                  onChanged: (value) =>
                      setState(() => selectedClassification = value),
                ),
              ],
            ),
            _buildSectionCard(
              title: 'Documents',
              icon: Icons.folder,
              children: [
                _buildUploadButton(
                  label: 'Upload ID Card',
                  filePath: idCardPath,
                  onPressed: () => _pickFile('ID Card'),
                ),
                const SizedBox(height: 12),
                _buildUploadButton(
                  label: 'Upload Photo in Uniform',
                  filePath: photoPath,
                  onPressed: () => _pickFile('Photo'),
                ),
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
                  backgroundColor: isSubmitting ? Colors.grey : Colors.teal,
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
    required IconData icon,
    required List<Widget> children,
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
                Icon(icon, color: Colors.teal, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1, color: Colors.teal),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(Icons.arrow_drop_down, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.teal, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.teal, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
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

  Widget _buildUploadButton({
    required String label,
    required String? filePath,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(Icons.upload, color: Colors.white),
      label: Text(
        filePath == null ? label : 'File Selected',
        style: TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
