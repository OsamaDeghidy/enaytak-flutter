import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Login-Signup/Login-Signup/login.dart';
import 'dart:io';
import 'package:flutter_sanar_proj/PATIENT/Login-Signup/Login-Signup/login_signup.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Constant_Widgets/CustomInputField.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

// import 'medicalRegistration.dart';

class PersonalRegistrationPage extends StatefulWidget {
  const PersonalRegistrationPage({super.key});

  @override
  _PersonalRegistrationPageState createState() =>
      _PersonalRegistrationPageState();
}

class _PersonalRegistrationPageState extends State<PersonalRegistrationPage> {
  final _nameController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _addressController = TextEditingController();
  DateTime? _birthDate;
  String? _profilePhoto = '';
  String? _selectedGender;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profilePhoto = pickedFile.path;
      });
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _profilePhoto = result.files.single.path!;
      });
    }
  }

  Future<void> _submitDetails() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Passwords do not match!');
      return;
    }

    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    const String apiUrl = 'http://67.205.166.136/api/users/';
    const String csrfToken =
        'xAlrLaDpKciN0UVRkC4S0SOHKoZcKxhkiYLoYAIA3rtmRLpMkhbv9OSgpOEJOOtt';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({
        'accept': 'application/json',
        'X-CSRFTOKEN': csrfToken,
      });

      // Add text fields
      request.fields.addAll({
        'password': _passwordController.text,
        'password_confirm': _confirmPasswordController.text,
        'username': _nameController.text,
        'email': _emailController.text,
        'full_name': _fullnameController.text,
        'phone_number': _phoneController.text,
        'birth_date': _birthDateController.text,
        'gender': _selectedGender ?? '',
        'address': _addressController.text,
        'user_type': 'patient',
        'is_verified': 'true',
        'is_active': 'true',
        'is_superuser': 'false',
        'is_staff': 'false',
      });

      // Add file if selected
      if (_profilePhoto != null && _profilePhoto!.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath(
          'profile_image',
          _profilePhoto!,
        ));
      }

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar('Registration Successful', success: true);
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: const Login(),
          ),
        );
      } else {
        final responseBody = await response.stream.bytesToString();
        _showSnackBar('Error (${response.statusCode}): $responseBody');
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _selectBirthDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _birthDate = pickedDate;
        _birthDateController.text =
            DateFormat('yyyy-MM-dd').format(_birthDate!);
      });
    }
  }

  void _showSnackBar(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: success ? Colors.green : Colors.red),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          titleSpacing: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: const Color(0xFF52A0AE), // Use the color #52A0AE
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginSignup()),
              );
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Image.asset(
                  "assets/images/Enayatak.png",
                  height: 80,
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 75,
                      backgroundColor: const Color.fromARGB(255, 247, 247, 247),
                      backgroundImage:
                          _profilePhoto != null && _profilePhoto!.isNotEmpty
                              ? FileImage(File(_profilePhoto!))
                              : null,
                      child: _profilePhoto == null || _profilePhoto!.isEmpty
                          ? const Icon(Icons.camera_alt,
                              size: 55, color: Color(0xFF52A0AE))
                          : null,
                    ),
                    FloatingActionButton(
                      onPressed: _pickImage,
                      mini: true,
                      backgroundColor: Color(0xFF52A0AE),
                      child: const Icon(Icons.edit, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                CustomInputField(
                  controller: _nameController,
                  labelText: "UserName",
                  hintText: "Enter your UserName",
                  keyboardType: TextInputType.name,
                  icon: Icons.person,
                  inputDecoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    labelStyle: TextStyle(color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                CustomInputField(
                  controller: _fullnameController,
                  labelText: "Name",
                  hintText: "Enter your FullName",
                  keyboardType: TextInputType.name,
                  icon: Icons.person,
                  inputDecoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    labelStyle: TextStyle(color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                CustomInputField(
                  controller: _emailController,
                  labelText: "Email",
                  hintText: "Enter your Email",
                  keyboardType: TextInputType.emailAddress,
                  icon: Icons.email,
                  inputDecoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    labelStyle: TextStyle(color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                CustomInputField(
                  controller: _phoneController,
                  labelText: "Phone",
                  hintText: "Enter your Phone Number",
                  keyboardType: TextInputType.phone,
                  icon: Icons.phone,
                  inputDecoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    labelStyle: TextStyle(color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                CustomInputField(
                  controller: _passwordController,
                  labelText: "Password",
                  hintText: "Enter your Password",
                  obscureText: true,
                  icon: Icons.lock,
                  inputDecoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    labelStyle: TextStyle(color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                CustomInputField(
                  controller: _confirmPasswordController,
                  labelText: "Confirm Password",
                  hintText: "Confirm your Password",
                  obscureText: true,
                  icon: Icons.lock,
                  inputDecoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    labelStyle: TextStyle(color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                CustomInputField(
                  controller: _addressController,
                  labelText: "Address",
                  hintText: "Enter your Address",
                  keyboardType: TextInputType.streetAddress,
                  icon: Icons.location_city,
                  inputDecoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    labelStyle: TextStyle(color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                CustomInputField(
                  controller: _birthDateController,
                  labelText: "Birth Date",
                  hintText: "Select your Birth Date",
                  icon: Icons.calendar_today,
                  inputDecoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    labelStyle: TextStyle(color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onTap: _selectBirthDate,
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Male')),
                    DropdownMenuItem(value: 'female', child: Text('Female')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    labelStyle: TextStyle(color: Colors.teal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon:
                        const Icon(Icons.transgender, color: Color(0xFF52A0AE)),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _submitDetails,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF52A0AE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 60),
                  ),
                  child: const Text(
                    "Register",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
