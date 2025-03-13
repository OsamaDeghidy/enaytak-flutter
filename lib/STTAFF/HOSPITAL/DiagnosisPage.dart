import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DiagnosisPage extends StatefulWidget {
  final int appointmentId;
  final int patientId;
  final int? hospitalId;
  final int? doctorId;
  final int? nurseId;
  final int? labId;
  final List<dynamic> services;
  final String status; // Include status
  final String? notes;
  final String service_type;
  const DiagnosisPage({
    super.key,
    required this.appointmentId,
    required this.patientId,
    this.hospitalId,
    this.doctorId,
    this.nurseId,
    this.labId,
    required this.services,
    required this.status,
    required this.service_type,
    required this.notes, // Pass the status
  });

  @override
  State<DiagnosisPage> createState() => _DiagnosisPageState();
}

class _DiagnosisPageState extends State<DiagnosisPage> {
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isLoading = false;
  Map<String, dynamic>? _medicalRecord;
  int? _categoryId;
  String? _errorMessage;
  Map<String, dynamic>? _existingDiagnosis;
  String? userType; // Variable to hold the user type

  List<dynamic> results = [];
  final bool _isRecordAvailable = false;
  bool _isUploadingFile = false; // Track file upload state

  String? file_Type;
  PlatformFile? selectedFile;
  @override
  void initState() {
    super.initState();
    _fetchMedicalRecordAndCategory();
    _loadUserType();
    _fetchMedicalFile();
    _fetchDiagnosesByAppointmentId(); // Fetch diagnoses on init
  }

  Future<void> _loadUserType() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userType = prefs.getString('user_type');
    });
  }

  Future<void> updateAppointmentStatus(String newStatus) async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
        'http://67.205.166.136/api/appointments/${widget.appointmentId}/');
    final body = {
      "date_time": DateTime.now().toIso8601String(),
      "service_type": widget.service_type,
      "status": newStatus,
      "cost": "22",
      "notes": _notesController.text,
      "appointment_address": "string",
      "is_follow_up": true,
      "is_confirmed": newStatus == "confirmed",
      "patient": widget.patientId,
      "doctor": widget.doctorId,
      "nurse": widget.nurseId,
      "hospital": widget.hospitalId,
      "lab": widget.labId,
      "services": widget.services,
    };

    try {
      final response = await http.put(url, body: json.encode(body), headers: {
        "Content-Type": "application/json",
      });

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Appointment updated to $newStatus.")),
        );
        Navigator.pop(context, newStatus); // Return the updated status
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update status: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> updateAppointmentNotes() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
        'http://67.205.166.136/api/appointments/${widget.appointmentId}/');
    final body = {
      "notes": _notesController.text,
      "patient": widget.patientId,
      "doctor": widget.doctorId,
      "nurse": widget.nurseId,
      "hospital": widget.hospitalId,
      "lab": widget.labId,
      "services": widget.services,
      "service_type": widget.service_type,
      // Only update the notes field
    };

    try {
      final response = await http.put(
        url,
        body: json.encode(body),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Notes updated successfully.")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update notes: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

// Fetch medical record, category, and check if diagnosis already exists
  Future<void> _fetchMedicalRecordAndCategory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch category using the first service ID
      if (widget.services.isNotEmpty) {
        final serviceId = widget.services.first;

        // Fetch category from service details
        final serviceResponse = await http.get(
          Uri.parse('http://67.205.166.136/api/services/$serviceId/'),
        );

        if (serviceResponse.statusCode == 200) {
          final serviceData = json.decode(serviceResponse.body);
          _categoryId = serviceData['category'];
        } else {
          _errorMessage = "Failed to load category details.";
        }
      } else {
        _errorMessage = "No services found for this appointment.";
      }

      // Fetch medical records
      final medicalRecordsResponse = await http.get(
        Uri.parse('http://67.205.166.136/api/medical-records/'),
      );

      if (medicalRecordsResponse.statusCode == 200) {
        final data = json.decode(medicalRecordsResponse.body);
        final medicalRecords = data['results'] as List<dynamic>;

        final record = medicalRecords.firstWhere(
          (record) => record['user'] == widget.patientId,
          orElse: () => null,
        );

        if (record != null) {
          _medicalRecord = record;
        }
      } else {
        _errorMessage = "Failed to load medical records.";
      }

      // Fetch existing diagnosis based on appointment ID
      final diagnosisResponse = await http.get(
        Uri.parse('http://67.205.166.136/api/diagnoses/'),
        headers: {"Accept": "application/json; charset=utf-8"},
      );

      if (diagnosisResponse.statusCode == 200) {
        final diagnosisData =
            json.decode(utf8.decode(diagnosisResponse.bodyBytes));
        final diagnoses = diagnosisData['results'] as List<dynamic>;

        final existingDiagnosis = diagnoses.firstWhere(
          (diagnosis) => diagnosis['appointment'] == widget.appointmentId,
          orElse: () => null,
        );

        if (existingDiagnosis != null) {
          _existingDiagnosis = existingDiagnosis;
        }
      } else {
        _errorMessage = "Failed to load diagnoses.";
      }
    } catch (e) {
      _errorMessage = "An error occurred: $e";
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> submitDiagnosis() async {
    if (_existingDiagnosis != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('A diagnosis already exists for this appointment.')),
      );
      return; // Prevent submitting a new diagnosis if one already exists
    }

    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category ID is missing.')),
      );
      return;
    }

    // Prepare request body, conditionally including medical record
    final Map<String, String> body = {
      'diagnosis_text': _diagnosisController.text,
      'appointment': widget.appointmentId.toString(),
      'category': _categoryId.toString(),
      'id': widget.patientId.toString(),
      if (_medicalRecord != null)
        'medical_record': _medicalRecord!['id'].toString(),
      if (widget.hospitalId != null) 'hospital': widget.hospitalId.toString(),
      if (widget.doctorId != null) 'doctor': widget.doctorId.toString(),
      if (widget.nurseId != null) 'nurse': widget.nurseId.toString(),
      if (widget.labId != null) 'lab': widget.labId.toString(),
    };

    final url = Uri.parse('http://67.205.166.136/api/diagnoses/');
    final response = await http.post(url, body: body);
    print(response);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Diagnosis added successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('this user doesnt have a medical record')),
      );
    }
  }

  Future<void> _fetchMedicalFile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse('http://67.205.166.136/api/medical-files/');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      results = data['results'];

      results = data['results']
          .where((result) =>
              result['medical_diagnosis'] == _existingDiagnosis!['id'])
          .toList();

      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to upload a medical file
  Future<void> _uploadMedicalFile(PlatformFile file) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null ||
        file.path == null ||
        file_Type == null ||
        _medicalRecord!['id'] == null ||
        _existingDiagnosis == null) {
      print(
          'something is $userId ${widget.patientId} ${file.path} $file_Type ${_medicalRecord!['id']}');
      return;
    }
    setState(() {
      _isUploadingFile = true; // Start uploading indicator
    });

    final url = Uri.parse('http://67.205.166.136/api/medical-files/');

    final request = http.MultipartRequest('POST', url)
      ..fields['id'] = widget.patientId.toString()
      ..fields['file_type'] = file_Type!
      ..fields['medical_record'] = _medicalRecord!['id'].toString()
      ..fields['diagnosis_id'] = _existingDiagnosis!['id'].toString()
      ..fields['medical_diagnosis'] = _existingDiagnosis!['id'].toString()
      ..files.add(await http.MultipartFile.fromPath('file', file.path!));

    final response = await http.Response.fromStream(await request.send());
    print(selectedFile);
    setState(() {
      _isUploadingFile = false; // Stop uploading indicator
    });

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      print('something is ${file.path} ');

      String uploadedFilePath = responseData['file'];

      _showSnackbar('File uploaded successfully');
      await _fetchMedicalFile();

      print('Uploaded file path: $uploadedFilePath');
    } else {
      _showSnackbar('Failed to upload file. Please try again.');
      print('Upload error: ${response.body}');
    }
  }

  // Pick a file from the user's device
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        selectedFile = file; // Store the selected file
      });
    }
  }

  // Add dropdown for file type selection
  Widget _buildFileTypeDropdown() {
    return DropdownButton<String>(
      value: file_Type,
      hint: const Text("Select file type"),
      onChanged: (String? newValue) {
        setState(() {
          file_Type = newValue;
        });
      },
      items: <String>['analysis', 'xray', 'prescription', 'other']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _fetchDiagnosesByAppointmentId() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'http://67.205.166.136/api/appointments/${widget.appointmentId}/diagnoses/'),
        headers: {
          'accept': 'application/json; charset=utf-8',
          'X-CSRFTOKEN':
              'O26ngwsauFsfukUTX6gEK7ObI4pO4vGX1ytSuW5VJ0MvjozGIbOZFHo6zfHtTWYP',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _existingDiagnosis = data['results'].firstWhere(
            (diagnosis) => diagnosis['appointment'] == widget.appointmentId,
            orElse: () => null,
          );
        });
      } else {
        _errorMessage = 'Failed to fetch diagnoses.';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleMedicalFilesByDiagnosisId(int diagnosisId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'http://67.205.166.136/api/diagnoses/$diagnosisId/medical-files/'),
        headers: {
          'accept': 'application/json; charset=utf-8',
          'X-CSRFTOKEN':
              'O26ngwsauFsfukUTX6gEK7ObI4pO4vGX1ytSuW5VJ0MvjozGIbOZFHo6zfHtTWYP',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          results = data['results'];
        });
      } else {
        _errorMessage = 'Failed to handle medical files.';
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildDiagnosesList() {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final diagnosis = results[index];
        return ListTile(
          title: Text(diagnosis['diagnosis_text']),
          subtitle: Text('Date: ${diagnosis['date']}'),
          onTap: () => _handleMedicalFilesByDiagnosisId(diagnosis['id']),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBooked = widget.status == "booked";
    final isCancelled = widget.status == "cancelled";
    final isConfirmed = widget.status == "confirmed";
    final List<String> statuses = [
      'booked',
      'confirmed',
      'in_progress',
      'completed',
      'dispatched',
      'delivered',
      'cancelled',
      'pending',
      'rejected'
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Diagnosis '),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isCancelled)
                      const Text(
                        "This appointment is cancelled. Diagnosis submission is not allowed.",
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    if (userType == 'lab')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Change Appointment Status:",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: Colors.teal),
                            ),
                            child: ListView.builder(
                              shrinkWrap:
                                  true, // Ensures the list takes up only the required space.
                              physics:
                                  const BouncingScrollPhysics(), // Prevents internal scrolling.
                              itemCount: statuses.length,
                              itemBuilder: (context, index) {
                                final status = statuses[index];
                                final isCurrentStatus = widget.status == status;

                                return GestureDetector(
                                  onTap: isCurrentStatus
                                      ? null
                                      : () => updateAppointmentStatus(status),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical:
                                            4.0), // Add spacing between items.
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: isCurrentStatus
                                          ? Colors.teal
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(color: Colors.teal),
                                      boxShadow: isCurrentStatus
                                          ? [
                                              BoxShadow(
                                                  color: Colors.teal
                                                      .withOpacity(0.3),
                                                  blurRadius: 5)
                                            ]
                                          : [],
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isCurrentStatus
                                              ? Icons.check_circle
                                              : Icons.circle,
                                          color: isCurrentStatus
                                              ? Colors.white
                                              : Colors.teal,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          status
                                              .replaceAll("_", " ")
                                              .toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: isCurrentStatus
                                                ? Colors.white
                                                : Colors.teal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                    if (isBooked && userType != 'lab')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: widget.status == "confirmed"
                                  ? null // Disable if already confirmed
                                  : () => updateAppointmentStatus("confirmed"),
                              child: const Text(
                                'Confirm Appointment',
                                style: TextStyle(fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: widget.status == "cancelled"
                                  ? null // Disable if already cancelled
                                  : () => updateAppointmentStatus("cancelled"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text(
                                'Cancel Appointment',
                                style: TextStyle(fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (_errorMessage != null)
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    // Show medical record details regardless of diagnosis
                    if (!isCancelled) ...[
                      if (_medicalRecord != null) ...[
                        const Text(
                          'Medical Record Details:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Text(
                            'Medical History: ${_medicalRecord!['medical_history']}'),
                        const SizedBox(height: 20),
                      ] else ...[
                        const Text(
                          'No medical record found. ',
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ],
                    if (isBooked || isConfirmed)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Link:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _notesController,
                            maxLines: 3, // Minimum 3 lines
                            readOnly: widget.notes != null &&
                                widget.notes!
                                    .isNotEmpty, // Make read-only if note exists
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              labelText: widget.notes != null &&
                                      widget.notes!.isNotEmpty
                                  ? '${widget.notes}'
                                  : 'Enter link',
                              hintText: widget.notes != null &&
                                      widget.notes!.isNotEmpty
                                  ? '${widget.notes}'
                                  : 'Type your link here...',
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (widget.notes == null ||
                              widget.notes!
                                  .isEmpty) // Show button only if no note exists
                            ElevatedButton(
                              onPressed: () {
                                if (_notesController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text("Notes cannot be empty.")),
                                  );
                                } else {
                                  updateAppointmentNotes();
                                }
                              },
                              child: const Text('Submit Notes'),
                            ),
                        ],
                      ),

                    if (_existingDiagnosis != null) ...[
                      const Text(
                        'Existing Diagnosis:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                          'Diagnosis Text: ${_existingDiagnosis!['diagnosis_text']}'),
                      const SizedBox(height: 20),
                      const Text(
                        'Diagnosis already exists for this appointment. No new diagnosis can be added.',
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      _buildMedicalFileSection()
                    ] else ...[
                      /* if (_medicalRecord != null) ...[ */
                      if (isConfirmed)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Add Diagnosis:',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            TextField(
                              controller: _diagnosisController,
                              decoration: const InputDecoration(
                                  labelText: 'Diagnosis Text'),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                submitDiagnosis();
                              },
                              child: const Text('Submit Diagnosis'),
                            ),
                            _buildMedicalFileSection()
                          ],
                        ),
                    ]
                  ],
                  /* ], */
                ),
              ),
            ),
    );
  }

  Widget _buildMedicalFileSection() {
    if (_medicalRecord == null) {
      return const Text('No medical Files found for the patient.',
          style: TextStyle(color: Colors.red));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Medical File: ${_medicalRecord!['id']} ${widget.patientId}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        _buildFileTypeDropdown(), // Dropdown for file type
        const SizedBox(height: 8),
        selectedFile != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Selected file: ${selectedFile!.name}'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedFile = null; // Remove file
                      });
                    },
                    child: const Text('Remove file'),
                  ),
                ],
              )
            : ElevatedButton(
                onPressed: _pickFile,
                child: const Text('Choose file'),
              ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: file_Type != null && selectedFile != null
              ? () => _uploadMedicalFile(selectedFile!)
              : null,
          child: _isUploadingFile
              ? const CircularProgressIndicator()
              : const Text('Upload File'),
        ),
        const SizedBox(height: 16),
        if (results.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: results.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title:
                      Text(results[index]['file_type'] ?? 'Unknown File Type'),
                  subtitle: Text(results[index]['file'] ?? 'No file available'),
                  trailing: const Icon(Icons.visibility, color: Colors.teal),
                  onTap: results[index]['file'] != null
                      ? () {
                          _viewFileInApp(context, results[index]['file']);
                        }
                      : null,
                ),
              );
            },
          ),
      ],
    );
  }
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
