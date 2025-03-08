import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/StaffDetails/doctor_details.dart';
import 'package:flutter_sanar_proj/PATIENT/StaffDetails/nurse_details.dart';
import 'package:flutter_sanar_proj/PATIENT/Staff_List/DoctorListScreen.dart';
import 'package:flutter_sanar_proj/PATIENT/Staff_List/NurseListScreen.dart';
import 'package:flutter_sanar_proj/PATIENT/Map_Service/GoogleMapScreen.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Constant_Widgets/custom_AppBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';

List<Map<String, dynamic>> serviceIcons = [
  {'id': 1, 'icon': Icons.local_hospital, 'name': 'Home Visit Doctor'},
  {'id': 2, 'icon': Icons.science, 'name': 'Laboratory'},
  {'id': 3, 'icon': Icons.medical_services, 'name': 'Seasonal Flu Vaccination'},
  {'id': 4, 'icon': Icons.radar, 'name': 'Radiology'},
  {'id': 5, 'icon': Icons.medical_information, 'name': 'Nurse Service'},
  {'id': 6, 'icon': Icons.child_friendly, 'name': 'Kids Vaccination'},
  {'id': 7, 'icon': Icons.spa, 'name': 'استرخاء'},
  {'id': 8, 'icon': Icons.local_hospital, 'name': 'Hospital'},
];

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<List<Map<String, dynamic>>>> _fetchDoctorsAndNurses;

  @override
  void initState() {
    super.initState();
    _printServiceId();
    _fetchDoctorsAndNurses = _fetchDoctorsAndNursesInParallel();
  }

  Future<void> _printServiceId() async {
    final prefs = await SharedPreferences.getInstance();
    final serviceId = prefs.getInt('serviceId');
    print(serviceId);

    if (serviceId != null) {
      print('Saved Service ID: $serviceId');
    } else {
      print('No Service ID found in SharedPreferences');
    }
  }

  IconData _getServiceIcon(int serviceId) {
    final iconEntry = serviceIcons.firstWhere(
      (entry) => entry['id'] == serviceId,
      orElse: () => {'icon': Icons.help_outline},
    );
    return iconEntry['icon'] as IconData;
  }

  Future<List<Map<String, dynamic>>> fetchServices() async {
    final url = Uri.parse('http://67.205.166.136/api/service-categories/');
    final response = await http.get(
      url,
      headers: {
        'accept': 'application/json; charset=utf-8',
        'X-CSRFTOKEN':
            'TBnER2Sd30Nom2fNH40WwVJoMEWWyJsEEZNB4sXomfYXdTJIHJ7zFRNXr4BtC0EN',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final results = data['results'] as List;

      return results.map((service) {
        return {
          'id': service['id'],
          'name': service['name'] ?? 'Unknown Service',
          'description': service['description'] ?? '',
          'image': service['image'] ?? '',
          'subcategory_ids': service['subcategory_ids'] ?? [],
          'service_ids': service['service_ids'] ?? [],
        };
      }).toList();
    } else {
      throw Exception('Failed to load services');
    }
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

      final List<Future<Map<String, dynamic>>> doctorFutures =
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
              'photo':
                  doctor['personal_photo'] ?? 'assets/images/placeholder.png',
              'name': userData['full_name'] ?? 'Unknown Doctor',
              'specialization':
                  doctor['specializations']?.join(', ') ?? 'No specialization',
              'rating': doctor['average_rating'] ?? 0.0,
              'description': doctor['bio'] ?? 'No bio available',
              'certifications':
                  doctor['certifications'] ?? 'No certifications available',
              'years_of_experience':
                  doctor['years_of_experience'] ?? 'Not provided',
              'city': doctor['city'] ?? 'Unknown City',
              'region': doctor['region'] ?? 'Unknown Region',
              'degree': doctor['degree'] ?? 'Not provided',
              'classification': doctor['classification'] ?? 'Not provided',
              'id_card_image':
                  doctor['id_card_image'] ?? 'No ID card image available',
              'verification_status':
                  doctor['verification_status'] ?? 'Not verified',
              'hospital':
                  doctor['hospital'] ?? 'Not associated with a hospital',
              'services': doctor['services'] ?? [],
            };
          }
        }
        return {
          'id': doctor['id'],
          'photo': 'assets/images/placeholder.png',
          'name': 'Unknown Doctor',
          'specialization': 'No specialization',
          'rating': 0.0,
          'description': 'No bio available',
          'certifications': 'No certifications available',
          'years_of_experience': 'Not provided',
          'city': 'Unknown City',
          'region': 'Unknown Region',
          'degree': 'Not provided',
          'classification': 'Not provided',
          'id_card_image': 'No ID card image available',
          'verification_status': 'Not verified',
          'hospital': 'Not associated with a hospital',
          'services': [],
        };
      }).toList();

      final List<Map<String, dynamic>> doctors =
          await Future.wait(doctorFutures);
      return doctors;
    } else {
      throw Exception('Failed to load doctors');
    }
  }

  Future<List<Map<String, dynamic>>> fetchNurses() async {
    final url = Uri.parse('http://67.205.166.136/api/nurses/');
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

      final List<Future<Map<String, dynamic>>> nurseFutures =
          results.map((nurse) async {
        final userId = nurse['user'];
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
              'id': nurse['id'],
              'photo':
                  nurse['personal_photo'] ?? 'assets/images/placeholder.png',
              'name': userData['full_name'] ?? 'Unknown Nurse',
              'specialization':
                  nurse['specializations']?.join(', ') ?? 'No specialization',
              'rating': nurse['average_rating'] ?? 0.0,
              'description': nurse['bio'] ?? 'No bio available',
              'certifications':
                  nurse['certifications'] ?? 'No certifications available',
              'years_of_experience':
                  nurse['years_of_experience'] ?? 'Not provided',
              'city': nurse['city'] ?? 'Unknown City',
              'region': nurse['region'] ?? 'Unknown Region',
              'degree': nurse['degree'] ?? 'Not provided',
              'classification': nurse['classification'] ?? 'Not provided',
              'id_card_image':
                  nurse['id_card_image'] ?? 'No ID card image available',
              'verification_status':
                  nurse['verification_status'] ?? 'Not verified',
              'hospital': nurse['hospital'] ?? 'Not associated with a hospital',
              'services': nurse['services'] ?? [],
            };
          }
        }
        return {
          'id': nurse['id'],
          'photo': 'assets/images/placeholder.png',
          'name': 'Unknown Nurse',
          'specialization': 'No specialization',
          'rating': 0.0,
          'description': 'No bio available',
          'certifications': 'No certifications available',
          'years_of_experience': 'Not provided',
          'city': 'Unknown City',
          'region': 'Unknown Region',
          'degree': 'Not provided',
          'classification': 'Not provided',
          'id_card_image': 'No ID card image available',
          'verification_status': 'Not verified',
          'hospital': 'Not associated with a hospital',
          'services': [],
        };
      }).toList();

      final List<Map<String, dynamic>> nurses = await Future.wait(nurseFutures);
      return nurses;
    } else {
      throw Exception('Failed to load nurses');
    }
  }

  Future<List<List<Map<String, dynamic>>>>
      _fetchDoctorsAndNursesInParallel() async {
    return await Future.wait([fetchDoctors(), fetchNurses()]);
  }

  Future<void> saveDoctorId(int doctorId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('doctorId', doctorId);
    print('Saved doctorID: $doctorId');
  }

  Future<void> saveNurseId(int nurseId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('nurseId', nurseId);
    print('Saved nurseID: $nurseId');
  }

  Future<void> saveServiceId(int serviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('serviceId', serviceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Homecare Services',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchServices(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildServiceShimmerEffect();
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text('Failed to load services',
                            style: TextStyle(color: Colors.red)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No services available'));
                  }

                  final services = snapshot.data!;
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return GestureDetector(
                        onTap: () async {
                          await saveServiceId(service['id']);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GoogleMapScreen(
                                serviceName: service['name'],
                              ),
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
                              Icon(
                                _getServiceIcon(service['id']),
                                size: 36,
                                color: const Color(0xFF0782BA),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                service['name'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Top-Rated Doctors',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoctorListScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<List<Map<String, dynamic>>>>(
                future: _fetchDoctorsAndNurses,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildDoctorShimmerEffect();
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text('Failed to load data',
                            style: TextStyle(color: Colors.red)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No data available'));
                  }

                  final doctors = snapshot.data![0];
                  final nurses = snapshot.data![1];

                  return Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: doctors.map((doctor) {
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
                                margin: const EdgeInsets.only(right: 16),
                                width: 150,
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
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        doctor['photo'],
                                        height: 90,
                                        width: 90,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      doctor['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          doctor['rating'].toString(),
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Top-Rated Nurses',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NurseListScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'See All',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: nurses.length,
                          itemBuilder: (context, index) {
                            final nurse = nurses[index];
                            return GestureDetector(
                              onTap: () async {
                                await saveNurseId(nurse['id']);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NurseDetailsScreen(nurse: nurse),
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                  right: index == nurses.length - 1 ? 0 : 16,
                                  left: index == 0 ? 16 : 0,
                                ),
                                width: 140,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 80,
                                      width: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: Image.network(
                                          nurse['photo'],
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Icon(
                                              Icons.person,
                                              size: 40,
                                              color: Colors.grey[400],
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      nurse['name'],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          nurse['rating'].toString(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
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
                Container(
                  height: 36,
                  width: 36,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 20,
                  width: double.infinity,
                  color: Colors.white,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDoctorShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Row(
        children: List.generate(
          3,
          (index) => Container(
            margin: const EdgeInsets.only(right: 16),
            width: 150,
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
              children: [
                Container(
                  height: 90,
                  width: 90,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 20,
                  width: double.infinity,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 20,
                  width: double.infinity,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
