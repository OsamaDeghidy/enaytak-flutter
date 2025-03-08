import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Screens/FullScreenImage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

class MedicalReportsPage extends StatefulWidget {
  const MedicalReportsPage({super.key});

  @override
  _MedicalReportsPageState createState() => _MedicalReportsPageState();
}

class _MedicalReportsPageState extends State<MedicalReportsPage> {
  bool _isLoading = true;
  bool _isSaving = false;
  String? medicalHistory;
  String? currentMedications;
  String? allergies;
  String? testResults;
  String? medicalNotes;
  bool _isRecordAvailable = false;
  bool _isUploadingFile = false;
  String? file_Type;
  int? medicalRecordId;
  PlatformFile? selectedFile;

  final TextEditingController _medicalHistoryController =
      TextEditingController();
  final TextEditingController _currentMedicationsController =
      TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _testResultsController = TextEditingController();
  final TextEditingController _medicalNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMedicalFile();
    _fetchMedicalRecord();
  }

  Future<void> _fetchMedicalRecord() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse('http://67.205.166.136/api/medical-records/');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));

      if (data['results'] != null && data['results'].isNotEmpty) {
        final record = data['results'].firstWhere(
          (record) => record['user'] == userId,
          orElse: () => null,
        );

        if (record != null) {
          setState(() {
            _isLoading = false;
            _isRecordAvailable = true;
            medicalHistory = record['medical_history'];
            currentMedications = record['current_medications'];
            allergies = record['allergies'];
            testResults = record['test_results'];
            medicalNotes = record['medical_notes'];
            medicalRecordId = record['id'];
          });
        } else {
          setState(() {
            _isLoading = false;
            _isRecordAvailable = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _isRecordAvailable = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<dynamic> results = [];
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

    final response = await http.get(
      url,
      headers: {
        'accept': 'application/json; charset=utf-8',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      results = data['results'];

      if (results != null) {
        results = data['results']
            .where((result) => result['medical_record'] == medicalRecordId)
            .toList();

        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _isRecordAvailable = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadMedicalFile(PlatformFile file) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null ||
        file.path == null ||
        file_Type == null ||
        medicalRecordId == null) {
      return;
    }

    setState(() {
      _isUploadingFile = true;
    });

    final url = Uri.parse('http://67.205.166.136/api/medical-files/');

    final request = http.MultipartRequest('POST', url)
      ..fields['file_type'] = file_Type!
      ..fields['medical_record'] = medicalRecordId.toString()
      ..files.add(await http.MultipartFile.fromPath('file', file.path!));

    final response = await http.Response.fromStream(await request.send());

    setState(() {
      _isUploadingFile = false;
    });

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      String uploadedFilePath = responseData['file'];
      _showSnackbar('File uploaded successfully');
      await _fetchMedicalFile();
      print('Uploaded file path: $uploadedFilePath');
    } else {
      _showSnackbar('Failed to upload file. Please try again.');
      print('Upload error: ${response.body}');
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        selectedFile = file;
      });
    }
  }

  Widget _buildFileTypeDropdown() {
    return DropdownButton<String>(
      value: file_Type,
      hint: Text("Select file type"),
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

  Future<void> _addNewMedicalRecord() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      return;
    }

    if (_medicalHistoryController.text.isEmpty ||
        _currentMedicationsController.text.isEmpty ||
        _allergiesController.text.isEmpty ||
        _testResultsController.text.isEmpty ||
        _medicalNotesController.text.isEmpty) {
      _showSnackbar('Please fill in all fields');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final url = Uri.parse('http://67.205.166.136/api/medical-records/');

    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'medical_history': _medicalHistoryController.text,
      'current_medications': _currentMedicationsController.text,
      'allergies': _allergiesController.text,
      'test_results': _testResultsController.text,
      'medical_notes': _medicalNotesController.text,
      'user': userId,
    });

    final response = await http.post(url, headers: headers, body: body);

    setState(() {
      _isSaving = false;
    });

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      final newRecordId = responseData['id'];

      // حفظ الـ medicalRecordId في SharedPreferences بعد الإنشاء
      await prefs.setInt('medicalRecordId', newRecordId);

      setState(() {
        medicalRecordId = newRecordId;
        _isRecordAvailable = true;
      });

      _fetchMedicalFile();
    } else {
      _showSnackbar('Failed to create record. Please try again');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Medical Reports',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 1, 128, 116),
                const Color.fromARGB(255, 139, 210, 215)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Color.fromARGB(255, 190, 226, 223),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _isRecordAvailable
                ? SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSection(
                            icon: Icons.medical_services,
                            title: 'Medical History',
                            content: medicalHistory,
                          ),
                          _buildSection(
                            icon: Icons.medication,
                            title: 'Current Medications',
                            content: currentMedications,
                          ),
                          _buildSection(
                            icon: Icons.warning,
                            title: 'Allergies',
                            content: allergies,
                          ),
                          _buildSection(
                            icon: Icons.assignment,
                            title: 'Test Results',
                            content: testResults,
                          ),
                          _buildSection(
                            icon: Icons.notes,
                            title: 'Medical Notes',
                            content: medicalNotes,
                          ),
                          const SizedBox(height: 16),
                          _buildUploadSection(),
                          const SizedBox(height: 16),
                          if (results.isNotEmpty) _buildUploadedFilesSection(),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                              'Medical History', _medicalHistoryController),
                          _buildTextField('Current Medications',
                              _currentMedicationsController),
                          _buildTextField('Allergies', _allergiesController),
                          _buildTextField(
                              'Test Results', _testResultsController),
                          _buildTextField(
                              'Medical Notes', _medicalNotesController),
                          const SizedBox(height: 16),
                          Center(
                            child: ElevatedButton(
                              onPressed: _addNewMedicalRecord,
                              child: _isSaving
                                  ? const CircularProgressIndicator()
                                  : const Text('Add New Medical Record'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildSection(
      {required IconData icon, required String title, String? content}) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.teal),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content ?? 'Not available',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.teal.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.upload_file, color: Colors.teal.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Upload Medical File',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.teal.shade900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFileTypeDropdown(),
              const SizedBox(height: 16),
              if (selectedFile != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected file: ${selectedFile!.name}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedFile = null;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Remove File',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickFile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Choose File',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: file_Type != null && selectedFile != null
                    ? () {
                        _uploadMedicalFile(selectedFile!);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isUploadingFile
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Upload File',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadedFilesSection() {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Uploaded Files',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two columns
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1, // Square items
              ),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final fileUrl = results[index]['file'];
                final fileType = results[index]['file_type'];

                // Check if the file is an image
                if (fileType == 'xray' || fileType == 'analysis') {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FullScreenImage(imageUrl: fileUrl),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                fileUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Text('Failed to load image'),
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              fileType,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        fileType ?? 'Unsupported file type',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
