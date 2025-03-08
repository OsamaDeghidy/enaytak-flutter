import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProviderHospital extends StatefulWidget {
  final Map<String, dynamic> hospitalData;

  const EditProviderHospital({required this.hospitalData, Key? key})
      : super(key: key);

  @override
  State<EditProviderHospital> createState() => _EditProviderHospitalState();
}

class _EditProviderHospitalState extends State<EditProviderHospital> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneNumberController;
  late TextEditingController addressController;
  late TextEditingController bioController;
  late TextEditingController certificationsController;
  late TextEditingController yearsOfExperienceController;
  late TextEditingController averageRatingController;
  late TextEditingController descriptionController;
  late TextEditingController cityController;
  late TextEditingController regionController;
  late TextEditingController degreeController;
  late TextEditingController classificationController;

  bool isActive = false;
  String verificationStatus = "pending";

  String? token;
  int? userId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data passed from widget.labData
    nameController = TextEditingController(text: widget.hospitalData['name']);
    emailController = TextEditingController(text: widget.hospitalData['email']);
    phoneNumberController =
        TextEditingController(text: widget.hospitalData['phone_number']);
    addressController =
        TextEditingController(text: widget.hospitalData['address']);
    bioController = TextEditingController(text: widget.hospitalData['bio']);
    certificationsController =
        TextEditingController(text: widget.hospitalData['certifications']);
    yearsOfExperienceController = TextEditingController(
        text: widget.hospitalData['years_of_experience'].toString());
    averageRatingController = TextEditingController(
        text: widget.hospitalData['average_rating'].toString());
    descriptionController =
        TextEditingController(text: widget.hospitalData['description']);
    cityController = TextEditingController(text: widget.hospitalData['city']);
    regionController =
        TextEditingController(text: widget.hospitalData['region']);
    degreeController =
        TextEditingController(text: widget.hospitalData['degree']);
    classificationController =
        TextEditingController(text: widget.hospitalData['classification']);
    isActive = widget.hospitalData['is_active'] ?? false;
    verificationStatus =
        widget.hospitalData['verification_status'] ?? "pending";
  }

  @override
  void dispose() {
    // Dispose controllers
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    bioController.dispose();
    certificationsController.dispose();
    yearsOfExperienceController.dispose();
    averageRatingController.dispose();
    descriptionController.dispose();
    cityController.dispose();
    regionController.dispose();
    degreeController.dispose();
    classificationController.dispose();
    super.dispose();
  }

  Future<void> updateProviderData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('access');
    userId = prefs.getInt('userId');
    int yearsOfExperience = int.tryParse(yearsOfExperienceController.text) ?? 0;
    int averageRating = int.tryParse(averageRatingController.text) ?? 0;

    final String apiUrl =
        'http://67.205.166.136/api/hospitals/${widget.hospitalData['id']}/';

    // Prepare form data
    final request = http.MultipartRequest('PUT', Uri.parse(apiUrl))
      ..headers.addAll({
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      })
      ..fields.addAll({
        "name": nameController.text,
        "email": emailController.text,
        "phone_number": phoneNumberController.text,
        "address": addressController.text,
        "bio": bioController.text,
        "certifications": certificationsController.text,
        "years_of_experience": yearsOfExperience.toString(),
        "average_rating": averageRating.toString(),
        "description": descriptionController.text,
        "is_active": isActive.toString(),
        "verification_status": verificationStatus,
        "city": cityController.text,
        "region": regionController.text,
        'user': widget.hospitalData['user'].toString(),
        "degree": degreeController.text,
        "classification": classificationController.text,
      });

    // Add the selected license document, if any
    if (_selectedLicenseDocument != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'license_document',
        _selectedLicenseDocument!.path,
      ));
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await request.send();

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: 'Profile updated successfully.');
        print(response);
        Navigator.pop(context, true);
      } else {
        final responseBody = await response.stream.bytesToString();
        Fluttertoast.showToast(msg: 'Error: $responseBody');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'Failed to update profile: $e');
    }
  }

  File? _selectedLicenseDocument;

  Future<void> pickLicenseDocument() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 1080,
        maxWidth: 1080,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedLicenseDocument = File(pickedFile.path);
        });

        Fluttertoast.showToast(msg: "License document selected successfully.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error picking document: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Edit Provider Information",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
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
              const SizedBox(height: 10),
              TextField(
                controller: bioController,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: certificationsController,
                decoration: InputDecoration(
                  labelText: 'Certifications',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.assignment),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: yearsOfExperienceController,
                decoration: InputDecoration(
                  labelText: 'Years of Experience',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: averageRatingController,
                decoration: InputDecoration(
                  labelText: 'Average Rating',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.star),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: cityController,
                decoration: InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: regionController,
                decoration: InputDecoration(
                  labelText: 'Region',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.map),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: degreeController,
                decoration: InputDecoration(
                  labelText: 'Degree',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: classificationController,
                decoration: InputDecoration(
                  labelText: 'Classification',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal, width: 1.5),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "License Document",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_selectedLicenseDocument == null)
                      ElevatedButton.icon(
                        onPressed: pickLicenseDocument,
                        icon: Icon(Icons.image),
                        label: Text("Upload Document"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    const SizedBox(height: 10),
                    if (_selectedLicenseDocument != null)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Selected File: ${_selectedLicenseDocument!.path.split('/').last}",
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _selectedLicenseDocument = null;
                              });
                              Fluttertoast.showToast(
                                  msg: "License document removed.");
                            },
                          ),
                        ],
                      ),
                    const SizedBox(height: 10),
                    if (widget.hospitalData['license_document'] != null)
                      GestureDetector(
                        onTap: () => _viewFileInApp(
                            context, widget.hospitalData['license_document']),
                        child: Card(
                          elevation: 5,
                          child: ListTile(
                            leading: Icon(Icons.image, color: Colors.teal),
                            title: Text("View Uploaded License Document"),
                            subtitle: Text("Tap to open"),
                            trailing:
                                Icon(Icons.visibility, color: Colors.teal),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: Text('Active Status'),
                value: isActive,
                onChanged: (bool value) {
                  setState(() {
                    isActive = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : updateProviderData,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Colors.teal,
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
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

  void _viewFileInApp(BuildContext context, String fileUrl) {
    // Open an image viewer
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('View Image')),
          body: Center(
            child: Image.network(
              fileUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Text('Failed to load image');
              },
            ),
          ),
        ),
      ),
    );
  }
}
