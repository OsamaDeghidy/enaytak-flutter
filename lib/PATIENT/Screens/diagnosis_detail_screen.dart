import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Screens/FullScreenImage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photo_view/photo_view.dart';

class DiagnosisDetailScreen extends StatefulWidget {
  final int diagnosisId;

  const DiagnosisDetailScreen({Key? key, required this.diagnosisId})
      : super(key: key);

  @override
  _DiagnosisDetailScreenState createState() => _DiagnosisDetailScreenState();
}

class _DiagnosisDetailScreenState extends State<DiagnosisDetailScreen> {
  bool isLoading = true;
  Map<String, dynamic> diagnosisDetail = {};
  List<dynamic> medicalFiles = [];
  String? doctorPhoto, doctorName, doctorEmail;
  String? nursePhoto, nurseName, nurseEmail;
  String? medicalFileUrl;
  String? labName, labEmail, labProfileImage;
  String? hospitalPhoto, hospitalName, hospitalEmail;
  Map<String, dynamic>? hospitalDetails;
  Map<String, dynamic>? hospitalUserDetails;

  @override
  void initState() {
    super.initState();
    fetchDiagnosisDetail();
  }

  Future<void> saveMedicalRecord(int medicalRecord) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('medical_record', medicalRecord);
  }

  Future<void> fetchDiagnosisDetail() async {
    final url = 'http://67.205.166.136/api/diagnoses/${widget.diagnosisId}/';
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'accept': 'application/json',
        'X-CSRFTOKEN':
            'YiG7ooE3NLbz9ve3ZTEL4O0PQYPdFwFIbO3CCOhO26vPYzTQKYc6ZoAKH97SuXXA',
      });

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          diagnosisDetail = data;
        });

        // Save medical_record in SharedPreferences
        if (data.containsKey('medical_record') &&
            data['medical_record'] != null) {
          saveMedicalRecord(data['medical_record']);
        }

        // Fetch lab details
        if (data['lab'] != null) {
          fetchLabDetails(data['lab']);
        }

        // Fetch doctor details
        if (data['doctor'] != null) {
          fetchDoctorDetails(data['doctor']);
        }

        // Fetch nurse details
        if (data['nurse'] != null) {
          fetchNurseDetails(data['nurse']);
        }

        // Fetch hospital details if available
        if (data['hospital'] != null) {
          fetchHospitalDetails(data['hospital']);
        }

        fetchMedicalFiles();
      } else {
        throw Exception('Failed to load diagnosis details');
      }
    } catch (e) {
      print('Error fetching diagnosis detail: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchMedicalFiles() async {
    final url =
        'http://67.205.166.136/api/diagnoses/${widget.diagnosisId}/medical-files/';
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'accept': 'application/json',
        'X-CSRFTOKEN':
            'YiG7ooE3NLbz9ve3ZTEL4O0PQYPdFwFIbO3CCOhO26vPYzTQKYc6ZoAKH97SuXXA',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          medicalFiles = data['results'];
          if (medicalFiles.isNotEmpty) {
            medicalFileUrl = medicalFiles[0]['file'];
          }
        });
      }
    } catch (e) {
      print('Error fetching medical files: $e');
    }
  }

  Future<void> fetchDoctorDetails(int doctorId) async {
    final url = 'http://67.205.166.136/api/doctors/$doctorId/';
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'accept': 'application/json',
        'X-CSRFTOKEN':
            'YiG7ooE3NLbz9ve3ZTEL4O0PQYPdFwFIbO3CCOhO26vPYzTQKYc6ZoAKH97SuXXA',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          doctorPhoto = data['personal_photo'];
        });

        if (data['user'] != null) {
          fetchUserDetails(data['user'], isDoctor: true);
        }
      }
    } catch (e) {
      print('Error fetching doctor details: $e');
    }
  }

  Future<void> fetchNurseDetails(int nurseId) async {
    final url = 'http://67.205.166.136/api/nurses/$nurseId/';
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'accept': 'application/json',
        'X-CSRFTOKEN':
            'YiG7ooE3NLbz9ve3ZTEL4O0PQYPdFwFIbO3CCOhO26vPYzTQKYc6ZoAKH97SuXXA',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          nursePhoto = data['personal_photo'];
        });

        if (data['user'] != null) {
          fetchUserDetails(data['user'], isDoctor: false);
        }
      }
    } catch (e) {
      print('Error fetching nurse details: $e');
    }
  }

  Future<void> fetchLabDetails(int labId) async {
    final url = 'http://67.205.166.136/api/labs/$labId/';
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'accept': 'application/json',
        'X-CSRFTOKEN':
            'YiG7ooE3NLbz9ve3ZTEL4O0PQYPdFwFIbO3CCOhO26vPYzTQKYc6ZoAKH97SuXXA',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          labName = data['name'];
          labEmail = data['email'];
          if (data['user'] != null) {
            fetchUserDetails(data['user'], isDoctor: false);
          }
        });
      }
    } catch (e) {
      print('Error fetching lab details: $e');
    }
  }

  Future<void> fetchHospitalDetails(int hospitalId) async {
    final url = 'http://67.205.166.136/api/hospitals/$hospitalId/';
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'accept': 'application/json',
        'X-CSRFTOKEN':
            'YiG7ooE3NLbz9ve3ZTEL4O0PQYPdFwFIbO3CCOhO26vPYzTQKYc6ZoAKH97SuXXA',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          hospitalDetails = data;
          hospitalName = data['name'];
          hospitalEmail = data['email'];
          hospitalPhoto = data[
              'profile_image']; // Assuming the hospital has a profile image
        });

        if (data['user'] != null) {
          fetchHospitalUserDetails(data['user']);
        }
      }
    } catch (e) {
      print('Error fetching hospital details: $e');
    }
  }

  Future<void> fetchHospitalUserDetails(int userId) async {
    final url = 'http://67.205.166.136/api/users/$userId/';
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'accept': 'application/json',
        'X-CSRFTOKEN':
            'YiG7ooE3NLbz9ve3ZTEL4O0PQYPdFwFIbO3CCOhO26vPYzTQKYc6ZoAKH97SuXXA',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          hospitalUserDetails = data;
          hospitalPhoto =
              data['profile_image']; // Update the hospital photo URL
        });
      }
    } catch (e) {
      print('Error fetching hospital user details: $e');
    }
  }

  Future<void> fetchUserDetails(int userId, {required bool isDoctor}) async {
    final url = 'http://67.205.166.136/api/users/$userId/';
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'accept': 'application/json',
        'X-CSRFTOKEN':
            'YiG7ooE3NLbz9ve3ZTEL4O0PQYPdFwFIbO3CCOhO26vPYzTQKYc6ZoAKH97SuXXA',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          if (isDoctor) {
            doctorName = data['full_name'];
            doctorEmail = data['email'];
          } else {
            nurseName = data['full_name'];
            nurseEmail = data['email'];
            labProfileImage = data['profile_image'];
          }
        });
      }
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Diagnosis Detail', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF018074), Color(0xFF8BD2D7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xFFBEE2DF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Content
          isLoading
              ? Center(
                  child: CircularProgressIndicator(color: Color(0xFF004740)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('Diagnosis Details'),
                      _buildDetailCard(
                        children: [
                          _buildDetailItem(
                            icon: Icons.medical_services,
                            label: 'Diagnosis',
                            value: diagnosisDetail['diagnosis_text'] ??
                                'No diagnosis text available',
                          ),
                          _buildDivider(),
                          _buildDetailItem(
                            icon: Icons.calendar_today,
                            label: 'Date',
                            value: diagnosisDetail['date'] != null
                                ? DateFormat('dd/MM/yyyy').format(
                                    DateTime.parse(diagnosisDetail['date']))
                                : 'N/A',
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      if (doctorName != null) ...[
                        _buildSectionHeader('Doctor Information'),
                        _buildDetailCard(
                          children: [
                            if (doctorPhoto != null)
                              CircleAvatar(
                                backgroundImage: NetworkImage(doctorPhoto!),
                                radius: 40,
                              ),
                            SizedBox(height: 10),
                            _buildDetailItem(
                              icon: Icons.person,
                              label: 'Name',
                              value: doctorName ?? 'N/A',
                            ),
                            _buildDivider(),
                            _buildDetailItem(
                              icon: Icons.email,
                              label: 'Email',
                              value: doctorEmail ?? 'N/A',
                            ),
                          ],
                        ),
                      ],
                      if (nurseName != null && labName == null) ...[
                        SizedBox(height: 20),
                        _buildSectionHeader('Nurse Information'),
                        _buildDetailCard(
                          children: [
                            if (nursePhoto != null)
                              CircleAvatar(
                                backgroundImage: NetworkImage(nursePhoto!),
                                radius: 40,
                              ),
                            SizedBox(height: 10),
                            _buildDetailItem(
                              icon: Icons.person,
                              label: 'Name',
                              value: nurseName ?? 'N/A',
                            ),
                            _buildDivider(),
                            _buildDetailItem(
                              icon: Icons.email,
                              label: 'Email',
                              value: nurseEmail ?? 'N/A',
                            ),
                          ],
                        ),
                      ],
                      if (labName != null) ...[
                        SizedBox(height: 20),
                        _buildSectionHeader('Lab Information'),
                        _buildDetailCard(
                          children: [
                            if (labProfileImage != null)
                              CircleAvatar(
                                backgroundImage: NetworkImage(labProfileImage!),
                                radius: 40,
                              ),
                            SizedBox(height: 10),
                            _buildDetailItem(
                              icon: Icons.business,
                              label: 'Lab Name',
                              value: labName ?? 'N/A',
                            ),
                            _buildDivider(),
                            _buildDetailItem(
                              icon: Icons.email,
                              label: 'Lab Email',
                              value: labEmail ?? 'N/A',
                            ),
                          ],
                        ),
                      ],
                      if (hospitalDetails != null) ...[
                        SizedBox(height: 20),
                        _buildSectionHeader('Hospital Information'),
                        _buildDetailCard(
                          children: [
                            if (hospitalPhoto != null)
                              CircleAvatar(
                                backgroundImage: NetworkImage(hospitalPhoto!),
                                radius: 40,
                              ),
                            SizedBox(height: 10),
                            _buildDetailItem(
                              icon: Icons.business,
                              label: 'Hospital Name',
                              value: hospitalName ?? 'N/A',
                            ),
                            _buildDivider(),
                            _buildDetailItem(
                              icon: Icons.email,
                              label: 'Email',
                              value: hospitalEmail ?? 'N/A',
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: 20),
                      _buildSectionHeader('Medical Files'),
                      _buildDetailCard(
                        children: [
                          if (medicalFileUrl != null)
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullScreenImage(
                                      imageUrl: medicalFileUrl!,
                                    ),
                                  ),
                                );
                              },
                              child: Hero(
                                tag: 'medicalFileImage',
                                child: Image.network(
                                  medicalFileUrl!,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          else
                            Text(
                              'No medical file available',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF004740),
        ),
      ),
    );
  }

  Widget _buildDetailCard({required List<Widget> children}) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String? value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            '$label: ${value ?? "N/A"}',
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.withOpacity(0.3),
      thickness: 1,
      height: 20,
    );
  }
}
