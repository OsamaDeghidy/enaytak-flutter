import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/StaffDetails/nurse_details.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class NurseListScreen extends StatefulWidget {
  const NurseListScreen({super.key});

  @override
  _NurseListScreenState createState() => _NurseListScreenState();
}

class _NurseListScreenState extends State<NurseListScreen> {
  late Future<List<Map<String, dynamic>>> nurses;

  @override
  void initState() {
    super.initState();
    nurses = fetchNurses();
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

      // Fetch user details for all nurses in parallel
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
              'user': nurse['user'] as int,
              'photo':
                  nurse['personal_photo'] ?? 'assets/images/placeholder.png',
              'name': userData['full_name'] ?? 'Unknown Nurse',
              'specialization':
                  nurse['specializations']?.join(', ') ?? 'No specialization',
              'rating': nurse['average_rating'] ?? 0.0,
            };
          }
        }
        return {
          'id': nurse['id'],
          'user': nurse['user'] as int,
          'photo': 'assets/images/placeholder.png',
          'name': 'Unknown Nurse',
          'specialization': 'No specialization',
          'rating': 0.0,
        };
      }).toList();

      // Wait for all user details to be fetched
      final List<Map<String, dynamic>> nurses = await Future.wait(nurseFutures);
      return nurses;
    } else {
      throw Exception('Failed to load nurses');
    }
  }

  Future<void> saveNurseId(int nurseId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('nurseId', nurseId);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Top-Rated Nurses'),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: nurses,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerEffect();
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching nurse data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No nurses available'));
          } else {
            final nursesData = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: screenWidth * 0.04,
                mainAxisSpacing: screenHeight * 0.02,
                childAspectRatio: 0.8,
              ),
              itemCount: nursesData.length,
              itemBuilder: (context, index) {
                final nurse = nursesData[index];
                return GestureDetector(
                  onTap: () async {
                    await saveNurseId(nurse['id']);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NurseDetailsScreen(nurse: nurse),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Nurse Photo
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: nurse['photo'].toString().contains('http')
                              ? Image.network(
                                  nurse['photo'],
                                  height: screenHeight * 0.12,
                                  width: screenHeight * 0.12,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return CircleAvatar(
                                      radius: screenHeight * 0.06,
                                      backgroundColor: Colors.grey[300],
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                        size: screenHeight * 0.06,
                                      ),
                                    );
                                  },
                                )
                              : CircleAvatar(
                                  radius: screenHeight * 0.06,
                                  backgroundImage: AssetImage(nurse['photo']),
                                ),
                        ),
                        const SizedBox(height: 8),
                        // Nurse Name
                        Text(
                          nurse['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star, color: Colors.orange, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              nurse['rating'].toString(),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 14,
                  width: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 4),
                Container(
                  height: 14,
                  width: 60,
                  color: Colors.grey[300],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
