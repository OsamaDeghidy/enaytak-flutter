import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/StaffDetails/doctor_details.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  _DoctorListScreenState createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  late Future<List<Map<String, dynamic>>> doctors;

  @override
  void initState() {
    super.initState();
    doctors = fetchDoctors();
  }

  Future<List<Map<String, dynamic>>> fetchDoctors() async {
    final url = Uri.parse('http://67.205.166.136/api/doctors/');
    final response = await http.get(
      url,
      headers: {
        'accept': 'application/json',
        'X-CSRFTOKEN':
            'TBnER2Sd30Nom2fNH40WwVJoMEWWyJsEEZNB4sXomfYXdTJIHJ7zFRNXr4BtC0EN',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;

      // Fetch user details for all doctors in parallel
      final doctorsWithDetails = await Future.wait(
        results.map((doctor) async {
          final userId = doctor['user'];
          if (userId != null) {
            final userResponse = await http.get(
              Uri.parse('http://67.205.166.136/api/users/$userId/'),
              headers: {
                'accept': 'application/json',
                'X-CSRFTOKEN':
                    'TBnER2Sd30Nom2fNH40WwVJoMEWWyJsEEZNB4sXomfYXdTJIHJ7zFRNXr4BtC0EN',
              },
            );

            if (userResponse.statusCode == 200) {
              final userData = json.decode(userResponse.body);
              return {
                'id': doctor['id'],
                'user': doctor['user'] as int,
                'photo':
                    doctor['personal_photo'] ?? 'assets/images/placeholder.png',
                'name': userData['full_name'] ?? 'Unknown Doctor',
                'specialization': doctor['specializations']?.join(', ') ??
                    'No specialization',
                'rating': doctor['average_rating'] ?? 0.0,
                'description': doctor['bio'] ?? 'No bio available',
              };
            }
          }
          return null; // Return null if user details cannot be fetched
        }).where((future) => future != null),
      );

      return doctorsWithDetails.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load doctors');
    }
  }

  Future<void> saveDoctorId(int doctorId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('doctorId', doctorId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Top-Rated Doctors'),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: doctors,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerEffect();
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching doctor data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No doctors available'));
          } else {
            final doctorsData = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: doctorsData.length,
                itemBuilder: (context, index) {
                  final doctor = doctorsData[index];
                  return GestureDetector(
                    onTap: () async {
                      await saveDoctorId(doctor['id']);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DoctorDetailsScreen(doctor: doctor),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundImage: doctor['photo']
                                    .toString()
                                    .contains('http')
                                ? NetworkImage(doctor['photo'])
                                : AssetImage(doctor['photo']) as ImageProvider,
                            radius: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            doctor['name'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.orange,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                doctor['rating'].toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${doctor['price'] ?? 'N/A'}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 12,
                    width: 100,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Container(
                        height: 14,
                        width: 30,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 14,
                    width: 60,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
