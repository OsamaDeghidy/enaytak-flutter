import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Screens/diagnosis_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Constant_Widgets/custom_AppBar.dart';
import 'package:flutter_sanar_proj/PATIENT/Screens/MedicalRecordPage.dart';

class MedicalDiagnosisPage extends StatefulWidget {
  const MedicalDiagnosisPage({super.key});

  @override
  _MedicalDiagnosisPageState createState() => _MedicalDiagnosisPageState();
}

class _MedicalDiagnosisPageState extends State<MedicalDiagnosisPage> {
  int? medicalRecordId;
  List<dynamic> diagnoses = [];
  bool isLoading = true;
  final String baseUrl = 'http://67.205.166.136/api';

  // Cache for doctor, nurse, lab, and hospital details
  final Map<int, Map<String, dynamic>> _doctorCache = {};
  final Map<int, Map<String, dynamic>> _nurseCache = {};
  final Map<int, Map<String, dynamic>> _labCache = {};
  final Map<int, String> _userNameCache = {};
  final Map<int, String> _userProfileImageCache = {};
  final Map<int, Map<String, dynamic>> _hospitalCache = {};

  @override
  void initState() {
    super.initState();
    fetchMedicalRecordAndDiagnoses();
  }

  Future<void> fetchMedicalRecordAndDiagnoses() async {
    final prefs = await SharedPreferences.getInstance();
    int? recordId = prefs.getInt('medicalRecordId');

    if (recordId != null) {
      await fetchDiagnoses(recordId);
    }

    setState(() {
      medicalRecordId = recordId;
      isLoading = false;
    });
  }

  Future<void> fetchDiagnoses(int recordId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/medical-records/$recordId/diagnoses/'),
      headers: {'accept': 'application/json; charset=utf-8'},
    );

    if (response.statusCode == 200) {
      List<dynamic> results =
          json.decode(utf8.decode(response.bodyBytes))['results'];

      // Fetch doctor, nurse, lab, and hospital details in parallel
      List<Future<void>> futures = [];
      for (var diagnosis in results) {
        if (diagnosis['doctor'] != null) {
          futures.add(_fetchAndCacheDoctorDetails(diagnosis));
        }
        if (diagnosis['nurse'] != null) {
          futures.add(_fetchAndCacheNurseDetails(diagnosis));
        }
        if (diagnosis['lab'] != null) {
          futures.add(_fetchAndCacheLabDetails(diagnosis));
        }
        if (diagnosis['hospital'] != null) {
          futures.add(_fetchAndCacheHospitalDetails(diagnosis));
        }
      }

      // Wait for all futures to complete
      await Future.wait(futures);

      setState(() {
        diagnoses = results;
      });
    } else {
      print('Failed to load diagnoses');
    }
  }

  Future<void> _fetchAndCacheDoctorDetails(
      Map<String, dynamic> diagnosis) async {
    int doctorId = diagnosis['doctor'];
    if (!_doctorCache.containsKey(doctorId)) {
      var doctorDetails = await fetchDoctorDetails(doctorId);
      _doctorCache[doctorId] = doctorDetails;
      diagnosis['doctorPhoto'] = doctorDetails['personal_photo'] ?? '';
      diagnosis['doctorUserId'] = doctorDetails['user'] ?? 0;
      if (diagnosis['doctorUserId'] != 0) {
        diagnosis['doctorName'] =
            await _fetchAndCacheUserName(diagnosis['doctorUserId']);
      } else {
        diagnosis['doctorName'] = 'Unknown';
      }
    } else {
      diagnosis['doctorPhoto'] =
          _doctorCache[doctorId]!['personal_photo'] ?? '';
      diagnosis['doctorName'] =
          await _fetchAndCacheUserName(_doctorCache[doctorId]!['user'] ?? 0);
    }
  }

  Future<void> _fetchAndCacheNurseDetails(
      Map<String, dynamic> diagnosis) async {
    int nurseId = diagnosis['nurse'];
    if (!_nurseCache.containsKey(nurseId)) {
      var nurseDetails = await fetchNurseDetails(nurseId);
      _nurseCache[nurseId] = nurseDetails;
      diagnosis['nursePhoto'] = nurseDetails['personal_photo'] ?? '';
      diagnosis['nurseUserId'] = nurseDetails['user'] ?? 0;
      if (diagnosis['nurseUserId'] != 0) {
        diagnosis['nurseName'] =
            await _fetchAndCacheUserName(diagnosis['nurseUserId']);
      } else {
        diagnosis['nurseName'] = 'Unknown';
      }
    } else {
      diagnosis['nursePhoto'] = _nurseCache[nurseId]!['personal_photo'] ?? '';
      diagnosis['nurseName'] =
          await _fetchAndCacheUserName(_nurseCache[nurseId]!['user'] ?? 0);
    }
  }

  Future<void> _fetchAndCacheLabDetails(Map<String, dynamic> diagnosis) async {
    int labId = diagnosis['lab'];
    if (!_labCache.containsKey(labId)) {
      var labDetails = await fetchLabDetails(labId);
      _labCache[labId] = labDetails;
      diagnosis['labUserId'] = labDetails['user'] ?? 0;
      if (diagnosis['labUserId'] != 0) {
        diagnosis['labName'] =
            await _fetchAndCacheUserName(diagnosis['labUserId']);
        diagnosis['labPhoto'] =
            await _fetchAndCacheUserProfileImage(diagnosis['labUserId']);
      } else {
        diagnosis['labName'] = 'Unknown';
        diagnosis['labPhoto'] = '';
      }
    } else {
      diagnosis['labName'] =
          await _fetchAndCacheUserName(_labCache[labId]!['user'] ?? 0);
      diagnosis['labPhoto'] =
          await _fetchAndCacheUserProfileImage(_labCache[labId]!['user'] ?? 0);
    }
  }

  Future<void> _fetchAndCacheHospitalDetails(
      Map<String, dynamic> diagnosis) async {
    int hospitalId = diagnosis['hospital'];
    if (!_hospitalCache.containsKey(hospitalId)) {
      var hospitalDetails = await fetchHospitalDetails(hospitalId);
      _hospitalCache[hospitalId] = hospitalDetails;
      diagnosis['hospitalUserId'] = hospitalDetails['user'] ?? 0;
      if (diagnosis['hospitalUserId'] != 0) {
        diagnosis['hospitalName'] =
            await _fetchAndCacheUserName(diagnosis['hospitalUserId']);
        diagnosis['hospitalPhoto'] =
            await _fetchAndCacheUserProfileImage(diagnosis['hospitalUserId']);
      } else {
        diagnosis['hospitalName'] = 'Unknown';
        diagnosis['hospitalPhoto'] = '';
      }
    } else {
      diagnosis['hospitalName'] = await _fetchAndCacheUserName(
          _hospitalCache[hospitalId]!['user'] ?? 0);
      diagnosis['hospitalPhoto'] = await _fetchAndCacheUserProfileImage(
          _hospitalCache[hospitalId]!['user'] ?? 0);
    }
  }

  Future<String> _fetchAndCacheUserName(int userId) async {
    if (!_userNameCache.containsKey(userId)) {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/'),
        headers: {'accept': 'application/json; charset=utf-8'},
      );

      if (response.statusCode == 200) {
        _userNameCache[userId] =
            json.decode(utf8.decode(response.bodyBytes))['full_name'] ??
                'Unknown';
      } else {
        _userNameCache[userId] = 'Unknown';
      }
    }
    return _userNameCache[userId]!;
  }

  Future<String> _fetchAndCacheUserProfileImage(int userId) async {
    if (!_userProfileImageCache.containsKey(userId)) {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/'),
        headers: {'accept': 'application/json; charset=utf-8'},
      );

      if (response.statusCode == 200) {
        _userProfileImageCache[userId] =
            json.decode(utf8.decode(response.bodyBytes))['profile_image'] ?? '';
      } else {
        _userProfileImageCache[userId] = '';
      }
    }
    return _userProfileImageCache[userId]!;
  }

  Future<Map<String, dynamic>> fetchDoctorDetails(int doctorId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/doctors/$doctorId/'),
      headers: {'accept': 'application/json; charset=utf-8'},
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      print('Failed to load doctor details');
      return {};
    }
  }

  Future<Map<String, dynamic>> fetchNurseDetails(int nurseId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/nurses/$nurseId/'),
      headers: {'accept': 'application/json; charset=utf-8'},
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      print('Failed to load nurse details');
      return {};
    }
  }

  Future<Map<String, dynamic>> fetchLabDetails(int labId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/labs/$labId/'),
      headers: {'accept': 'application/json; charset=utf-8'},
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      print('Failed to load lab details');
      return {};
    }
  }

  Future<Map<String, dynamic>> fetchHospitalDetails(int hospitalId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/hospitals/$hospitalId/'),
      headers: {'accept': 'application/json; charset=utf-8'},
    );

    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      print('Failed to load hospital details');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.teal.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Medical Profile',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.upload_file,
                            color: Colors.teal,
                            size: 30,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MedicalRecordPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: diagnoses.isEmpty
                        ? const Center(child: Text('No diagnoses available'))
                        : ListView.builder(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: diagnoses.length,
                            itemBuilder: (context, index) {
                              final diagnosis = diagnoses[index];
                              return _MedicalRecordItem(
                                diagnosisId: diagnosis['id'],
                                date: diagnosis['date'] ?? 'Unknown date',
                                doctorType: diagnosis['doctor'] != null
                                    ? 'Doctor'
                                    : diagnosis['nurse'] != null
                                        ? 'Nurse'
                                        : diagnosis['lab'] != null
                                            ? 'Lab'
                                            : diagnosis['hospital'] != null
                                                ? 'Hospital'
                                                : 'Unknown',
                                description:
                                    diagnosis['diagnosis_text'] ?? 'No details',
                                time: 'N/A',
                                name: diagnosis['doctor'] != null
                                    ? diagnosis['doctorName'] ?? 'Unknown'
                                    : diagnosis['nurse'] != null
                                        ? diagnosis['nurseName'] ?? 'Unknown'
                                        : diagnosis['lab'] != null
                                            ? diagnosis['labName'] ?? 'Unknown'
                                            : diagnosis['hospitalName'] ??
                                                'Unknown',
                                photo: diagnosis['doctor'] != null
                                    ? diagnosis['doctorPhoto'] ?? ''
                                    : diagnosis['nurse'] != null
                                        ? diagnosis['nursePhoto'] ?? ''
                                        : diagnosis['lab'] != null
                                            ? diagnosis['labPhoto'] ?? ''
                                            : diagnosis['hospitalPhoto'] ?? '',
                                // hospitalName: diagnosis['hospitalName'] ?? '',
                                // hospitalPhoto: diagnosis['hospitalPhoto'] ?? '',
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _MedicalRecordItem extends StatelessWidget {
  final int diagnosisId;
  final String date;
  final String doctorType;
  final String description;
  final String time;
  final String name;
  final String photo;
  // final String hospitalName;
  // final String hospitalPhoto;

  const _MedicalRecordItem({
    required this.diagnosisId,
    required this.date,
    required this.doctorType,
    required this.description,
    required this.time,
    required this.name,
    required this.photo,
    // required this.hospitalName,
    // required this.hospitalPhoto,
  });

  String formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DiagnosisDetailScreen(diagnosisId: diagnosisId),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 16.0),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Text(
                formatDate(date),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: (photo.isNotEmpty)
                        ? NetworkImage(photo)
                        : const AssetImage('assets/default_profile.png')
                            as ImageProvider,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // if (hospitalName.isNotEmpty)
                        //   Row(
                        //     children: [
                        //       CircleAvatar(
                        //         radius: 15,
                        //         backgroundImage: (hospitalPhoto.isNotEmpty)
                        //             ? NetworkImage(hospitalPhoto)
                        //             : const AssetImage(
                        //                     'assets/default_profile.png')
                        //                 as ImageProvider,
                        //       ),
                        //       const SizedBox(width: 8),
                        //       Text(
                        //         hospitalName,
                        //         style: const TextStyle(
                        //           fontSize: 14,
                        //           color: Colors.black54,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
