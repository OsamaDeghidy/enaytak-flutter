import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Schadule_Details/booking_Nurse_appointment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NurseDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> nurse;

  const NurseDetailsScreen({super.key, required this.nurse});

  Future<void> saveNurseId(int nurseId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('nurseId', nurseId);
  }

  Future<int?> getNurseId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('nurseId');
  }

  Future<Map<String, dynamic>> fetchNurseDetails(int nurseId) async {
    final response = await http.get(
      Uri.parse('http://67.205.166.136/api/nurses/$nurseId/'),
      headers: {
        'accept': 'application/json; charset=utf-8',
        'X-CSRFTOKEN':
            'fZCw6KDoVfbnDDn0mCcGXcTZSPSyMCDneCJ17WYtqR1E3OAAGLe4yarEj8Rvs9NW',
      },
    );

    if (response.statusCode == 200) {
      final nurseDetails = json.decode(utf8.decode(response.bodyBytes));
      final int nurseUserId = nurseDetails['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user', nurseUserId);

      return nurseDetails;
    } else {
      throw Exception('Failed to load nurse details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Nurse Details',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: FutureBuilder<int?>(
        future: getNurseId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching nurse ID'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No nurse ID found'));
          } else {
            final nurseId = snapshot.data!;
            return FutureBuilder<Map<String, dynamic>>(
              future: fetchNurseDetails(nurseId),
              builder: (context, apiSnapshot) {
                if (apiSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (apiSnapshot.hasError) {
                  return const Center(
                      child: Text('Error fetching nurse details'));
                } else if (!apiSnapshot.hasData) {
                  return const Center(child: Text('No nurse details found'));
                } else {
                  final nurseDetails = apiSnapshot.data!;
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // Header Card with Profile Image
                        Card(
                          color: Colors.white,
                          margin: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Profile Image
                                Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: NetworkImage(nurse['photo'] ?? ''),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Name and Specialization
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nurse['name'],
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        nurse['specialization'] ??
                                            'No specialization',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Info Cards
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard(
                                  'Rating',
                                  Icons.star,
                                  nurseDetails['average_rating']?.toString() ??
                                      'N/A',
                                  Colors.amber,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildInfoCard(
                                  'Fee',
                                  Icons.attach_money,
                                  '${nurse['fee']} SAR',
                                  Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Details Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow('City', nurseDetails['city']),
                                  _buildDetailRow(
                                      'Region', nurseDetails['region']),
                                  _buildDetailRow(
                                      'Degree', nurseDetails['degree']),
                                  _buildDetailRow('Years of Experience',
                                      nurseDetails['years_of_experience']),
                                  _buildDetailRow('Classification',
                                      nurseDetails['classification']),
                                  _buildDetailRow('Verification Status',
                                      nurseDetails['verification_status']),
                                  // _buildDetailRow(
                                  //     'Specializations',
                                  //     nurseDetails['specializations']
                                  //             ?.join(', ') ??
                                  //         'N/A'),
                                  // _buildDetailRow(
                                  //     'Services',
                                  //     nurseDetails['services']?.join(', ') ??
                                  //         'N/A'),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Action Buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ScheduleNurseScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Book Video Appointment',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ScheduleNurseScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Book Appointment',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildInfoCard(
      String title, IconData icon, String value, Color color) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value?.toString() ?? 'N/A',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
