import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Screens/FullScreenImage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

class AddDiagnosisScreen extends StatefulWidget {
  final int appointmentId; // Pass the appointment ID

  const AddDiagnosisScreen({Key? key, required this.appointmentId})
      : super(key: key);

  @override
  _AddDiagnosisScreenState createState() => _AddDiagnosisScreenState();
}

class _AddDiagnosisScreenState extends State<AddDiagnosisScreen> {
  final TextEditingController diagnosisController = TextEditingController();
  String? selectedFileType; // Variable to hold the selected file type
  File? _pickedFile; // Variable to hold the picked file
  int? categoryId; // Variable to hold the category ID from the service
  int? medicalRecordId; // Variable to hold the medical record ID
  List<String> uploadedFiles = []; // List to hold uploaded file URLs
  List<String> addedDiagnoses = []; // List to store added diagnoses
  bool _isLoading = false; // Variable to track loading state
  Map<String, dynamic>? diagnosisData; // Variable to hold the diagnosis data
  List<dynamic> diagnosesList = []; // List to hold diagnoses

  // Static list of file types
  static const List<Map<String, String>> FILE_TYPES = [
    {'value': 'xray', 'label': 'X-Ray'},
    {'value': 'analysis', 'label': 'Analysis'},
    {'value': 'prescription', 'label': 'Prescription'},
    {'value': 'other', 'label': 'Other'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchAppointmentDetails(); // Fetch appointment details to get serviceId
    _fetchDiagnoses(); // Fetch diagnoses for the appointment
  }

  // Fetch appointment details to get serviceId
  Future<void> _fetchAppointmentDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access');

      final response = await http.get(
        Uri.parse(
            'http://67.205.166.136/api/appointments/${widget.appointmentId}/'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final serviceId = data['services'][0]; // Get the first service ID
        final patientId = data['patient']; // Get the patient ID
        _fetchServiceDetails(
            serviceId); // Fetch service details to get categoryId
        _fetchMedicalRecordId(patientId); // Fetch medical record ID
      } else {
        print('Failed to load appointment details: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load appointment details');
      }
    } catch (e) {
      print('Error in _fetchAppointmentDetails: $e');
      throw Exception('Error fetching appointment details: $e');
    }
  }

  // Fetch service details to get categoryId
  Future<void> _fetchServiceDetails(int serviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access');

      final response = await http.get(
        Uri.parse('http://67.205.166.136/api/services/$serviceId/'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          categoryId = data['category']; // Set the category ID
        });
      } else {
        print('Failed to load service details: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load service details');
      }
    } catch (e) {
      print('Error in _fetchServiceDetails: $e');
      throw Exception('Error fetching service details: $e');
    }
  }

  // Fetch medical record ID for the patient
  Future<void> _fetchMedicalRecordId(int patientId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access');

      final response = await http.get(
        Uri.parse('http://67.205.166.136/api/medical-records/'),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final medicalRecords = data['results'] as List<dynamic>;
        final record = medicalRecords.firstWhere(
          (record) => record['user'] == patientId,
          orElse: () => null,
        );

        if (record != null) {
          setState(() {
            medicalRecordId = record['id']; // Set the medical record ID
          });
          _loadUploadedFiles(); // Load uploaded files after fetching medical record ID
        } else {
          throw Exception('Medical record not found for the patient');
        }
      } else {
        print('Failed to load medical records: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load medical records');
      }
    } catch (e) {
      print('Error in _fetchMedicalRecordId: $e');
      throw Exception('Error fetching medical record ID: $e');
    }
  }

  // Load previously uploaded files based on medical record ID
  Future<void> _loadUploadedFiles() async {
    if (medicalRecordId == null) return; // Ensure medicalRecordId is set

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access');

      final response = await http.get(
        Uri.parse(
            'http://67.205.166.136/api/medical-files/?medical_record=$medicalRecordId'), // Filter by medical record ID
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final files = data['results'] as List<dynamic>;

        setState(() {
          uploadedFiles = files
              .map((fileData) => fileData['file'] as String) // Cast to String
              .toList();
        });
      } else {
        print('Failed to load uploaded files: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error in _loadUploadedFiles: $e');
    }
  }

  // Fetch diagnoses for the appointment
  Future<void> _fetchDiagnoses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access');

      final response = await http.get(
        Uri.parse(
            'http://67.205.166.136/api/appointments/${widget.appointmentId}/diagnoses/'),
        headers: {
          'accept': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          diagnosesList = data['results'];
        });
      } else {
        print('Failed to load diagnoses: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load diagnoses');
      }
    } catch (e) {
      print('Error in _fetchDiagnoses: $e');
      throw Exception('Error fetching diagnoses: $e');
    }
  }

  // Submit diagnosis and file
  Future<void> _submitDiagnosisAndFile() async {
    final String diagnosisText = diagnosisController.text;

    if (diagnosisText.isEmpty ||
        selectedFileType == null ||
        _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please fill in all fields and select a file")),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      // Add diagnosis and get the response
      final diagnosisResponse = await _addDiagnosis(diagnosisText);

      if (diagnosisResponse.statusCode == 201) {
        final diagnosisData = json.decode(diagnosisResponse.body);
        final diagnosisId = diagnosisData['id']; // Get the diagnosis ID

        // Upload the file with the diagnosis ID
        final fileResponse = await _uploadFile(diagnosisId);

        if (fileResponse.statusCode == 201) {
          setState(() {
            uploadedFiles.add(
                _pickedFile!.path); // Add the uploaded file URL to the list
            addedDiagnoses.add(diagnosisText); // Add the diagnosis to the list
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Diagnosis and file uploaded successfully")),
          );
          // Clear the text field after successful submission
          diagnosisController.clear();
        } else {
          print('Error uploading file');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error uploading file")),
          );
        }
      } else {
        print('Error adding diagnosis');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error adding diagnosis")),
        );
      }
    } catch (e) {
      print('Error in _submitDiagnosisAndFile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  // Function to add diagnosis
  Future<http.Response> _addDiagnosis(String diagnosisText) async {
    try {
      final String apiUrl = 'http://67.205.166.136/api/diagnoses/';
      const String csrfToken =
          'lX0YOPw2ElVkeYlf1B7vKBNUErJBDc5jqRXc23Fzf9qRWa8VM3ivKI6PVDS38qHM';

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access');
      final specificId = prefs.getInt('specificId');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'X-CSRFTOKEN': csrfToken,
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'diagnosis_text': diagnosisText,
          'appointment': widget.appointmentId,
          'doctor': specificId,
          'medical_record':
              medicalRecordId, // Use the fetched medical record ID
          'category': categoryId, // Use the fetched category ID
        }),
      );

      print('Diagnosis API Response: ${response.statusCode}');
      print('Diagnosis API Response Body: ${response.body}');
      return response;
    } catch (e) {
      print('Error in _addDiagnosis: $e');
      rethrow;
    }
  }

  // Function to upload file using multipart/form-data
  Future<http.Response> _uploadFile(int diagnosisId) async {
    try {
      final String apiUrl = 'http://67.205.166.136/api/medical-files/';
      const String csrfToken =
          'lX0YOPw2ElVkeYlf1B7vKBNUErJBDc5jqRXc23Fzf9qRWa8VM3ivKI6PVDS38qHM';

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access');

      // Create a multipart request
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Add headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['X-CSRFTOKEN'] = csrfToken;
      request.headers['accept'] = 'application/json';

      // Add file to the request
      var fileStream = http.ByteStream(_pickedFile!.openRead());
      var fileLength = await _pickedFile!.length();

      var multipartFile = http.MultipartFile(
        'file', // Field name for the file
        fileStream,
        fileLength,
        filename: _pickedFile!.path.split('/').last, // File name
      );
      request.files.add(multipartFile);

      // Add other fields
      request.fields['file_type'] = selectedFileType!;
      request.fields['medical_record'] =
          medicalRecordId.toString(); // Medical record ID
      request.fields['diagnosis_id'] = diagnosisId.toString(); // Diagnosis ID
      request.fields['medical_diagnosis'] =
          diagnosisId.toString(); // Use the diagnosis ID instead of text

      // Send the request
      var response = await request.send();

      // Get the response
      var responseData = await response.stream.bytesToString();
      var statusCode = response.statusCode;

      print('File Upload API Response: $statusCode');
      print('File Upload API Response Body: $responseData');

      return http.Response(responseData, statusCode);
    } catch (e) {
      print('Error in _uploadFile: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Diagnosis'),
        backgroundColor: Colors.teal.shade700,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Diagnosis Text Field
              TextField(
                controller: diagnosisController,
                decoration: const InputDecoration(
                  labelText: 'Diagnosis Text',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // File Type Dropdown
              DropdownButtonFormField<String>(
                value: selectedFileType,
                hint: const Text('Select File Type'),
                items: FILE_TYPES.map((fileType) {
                  return DropdownMenuItem<String>(
                    value: fileType['value'],
                    child: Text(fileType['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFileType = value;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // File Upload Button
              ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();
                  if (result != null) {
                    setState(() {
                      _pickedFile = File(result.files.single.path!);
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Upload File',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),

              // Display Selected File Preview
              if (_pickedFile != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected file: ${_pickedFile!.path.split('/').last}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Display Image if the file is an image
                    if (selectedFileType == 'xray' ||
                        selectedFileType == 'analysis')
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.teal.shade700),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _pickedFile!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                    // Display a placeholder for non-image files
                    if (selectedFileType != 'xray' &&
                        selectedFileType != 'analysis')
                      Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.teal.shade700),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.insert_drive_file,
                            size: 50,
                            color: Colors.teal.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitDiagnosisAndFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text(
                        'Add Diagnosis',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
              const SizedBox(height: 20),

              // Display Diagnosis Text and Medical Files
              if (diagnosesList.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Diagnoses:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...diagnosesList.map((diagnosis) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            diagnosis['diagnosis_text'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.teal.shade800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (diagnosis['medical_files'].isNotEmpty)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: diagnosis['medical_files'].length,
                              itemBuilder: (context, index) {
                                final file = diagnosis['medical_files'][index];
                                return GestureDetector(
                                  onTap: () {
                                    // Navigate to FullScreenImage with the file URL
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FullScreenImage(
                                          imageUrl: file['file'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.teal.shade700),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        file['file'],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }).toList(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
