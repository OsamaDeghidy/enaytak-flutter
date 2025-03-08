import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter_sanar_proj/PATIENT/User_Profile/Edit_profile.dart';

import 'package:flutter_sanar_proj/PATIENT/Widgets/Colors/colors.dart';
import 'package:flutter_sanar_proj/STTAFF/HOSPITAL/availabilty_Screen.dart';
import 'package:flutter_sanar_proj/STTAFF/HOSPITAL/change_password.dart';
import 'package:flutter_sanar_proj/STTAFF/LAB/Edit_Provider.dart';
import 'package:flutter_sanar_proj/STTAFF/LAB/Lab_bottom_navbar.dart';
import 'package:flutter_sanar_proj/STTAFF/LAB/add_service_lab.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LabUserProfile extends StatefulWidget {
  const LabUserProfile({super.key});

  @override
  State<LabUserProfile> createState() => _LabUserProfileState();
}

class _LabUserProfileState extends State<LabUserProfile> {
  Map<String, dynamic> userData = {};
  Map<String, dynamic> labData = {}; // Store hospital data here
  String? token;

  int? userId;
  int? labId;
  List<dynamic> services = []; // Store service data here

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchAvailabilities();
    fetchLab();
    fetchServices(); // Fetch and filter availabilities
  }

  Future<void> fetchLab() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('access');
    labId = prefs.getInt('specificId'); // Fetch the specific_id from prefs
    print('Token: $token');
    print('labId : $labId');
    if (token == null || labId == null) {
      _showErrorSnackBar("No token or hospital ID found. Please login first.");
      return;
    }

    final String apiUrl =
        'http://67.205.166.136/api/labs/$labId/'; // Use dynamic hospitalId here

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'accept': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        setState(() {
          labData = json.decode(utf8.decode(response.bodyBytes));
        });

        fetchServices();
      } else {
        String errorMsg =
            'Error: Unable to fetch hospital data. Status code: ${response.statusCode} status body :${response.body}';
        _showErrorSnackBar(errorMsg);
      }
    } catch (e) {
      String errorMsg = 'Failed to load hospital data: $e';
      _showErrorSnackBar(errorMsg);
    }
  }

  Future<void> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('access');
    userId = prefs.getInt('userId');

    if (token == null || userId == null) {
      _showErrorSnackBar("No token or user ID found. Please login first.");
      return;
    }

    final String apiUrl = 'http://67.205.166.136/api/users/$userId/';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'accept': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = json.decode(utf8.decode(response.bodyBytes));
        });
      } else {
        String errorMsg =
            'Error: Unable to fetch user data. Status code: ${response.statusCode}';
        _showErrorSnackBar(errorMsg);
      }
    } catch (e) {
      String errorMsg = 'Failed to load user data: $e';
      _showErrorSnackBar(errorMsg);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  List<dynamic> availabilities = [];

  Future<void> fetchAvailabilities() async {
    final prefs = await SharedPreferences.getInstance();

    token = prefs.getString('access');

    final String apiUrl = 'http://67.205.166.136/api/availabilities/';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> allAvailabilities = data['results'];

        final List<dynamic> userAvailabilities =
            allAvailabilities.where((availability) {
          return availability['user'] == userId;
        }).toList();

        setState(() {
          availabilities = userAvailabilities;
        });
      } else {
        print(response.body);
        String errorMsg =
            'Error: Unable to fetch availabilities. Status code: ${response.body} ${response.statusCode}';
        _showErrorSnackBar(errorMsg);
      }
    } catch (e) {
      String errorMsg = 'Failed to load availabilities: $e';
      _showErrorSnackBar(errorMsg);
    }
  }

  Future<void> fetchServices() async {
    final String servicesUrl =
        'http://67.205.166.136/api/labs/$labId/services/';

    try {
      final response = await http.get(
        Uri.parse(servicesUrl),
        headers: {
          'accept': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final servicesData = json.decode(utf8.decode(response.bodyBytes));
        List<String> fetchedServices = [];
        for (var service in servicesData['results']) {
          fetchedServices.add(service['name']); // Extract and add service names
        }

        // Call setState after services are fetched to rebuild the widget tree
        setState(() {
          services = fetchedServices;
        });
      } else {
        print(
            'Error: Failed to fetch services. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: Failed to fetch services. Exception: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access');
    await prefs.remove('userId');

    Fluttertoast.showToast(
      msg: "Logged out successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.teal,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    Navigator.pushReplacementNamed(context, '/Login_Signup');
  }

  Future<void> createService(
    String name,
    String price,
    String duration,
    int category,
  ) async {
    final String apiUrl = 'http://67.205.166.136/api/services/';

    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type':
          'application/json', // Ensure Content-Type is set to application/json
    };

    final body = json.encode({
      'name': name,
      'price': price,
      'duration': duration,
      'category': category,
      'lab': [labId],
      'selectedHospitalId': null,
      'selectedDoctorId': null,
      'selectedNurseId': null
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201) {
        Fluttertoast.showToast(msg: "Service added successfully");
        print(response.body);
      } else {
        Fluttertoast.showToast(msg: "Failed to add service: ${response.body}");
        print(response.body);
        print(response.statusCode);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  Future<void> refreshData() async {
    // Reload all necessary data
    await fetchUserData();
    await fetchAvailabilities();
    fetchLab();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LabMainScreen(),
                    ),
                  )
                },
            icon: Icon(Icons.arrow_back)),
        title: const Text('User Profile'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileHeader(),
            const SizedBox(height: 20),
            _buildMedicalDetails(),
            _buildLabData(),
            _buildAvailabilities(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Add Availability Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AddAvailabilityScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add Availability',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      overflow:
                          TextOverflow.ellipsis, // Add ellipsis for long text
                    ),
                  ),
                ),
                const SizedBox(width: 12), // Add spacing between buttons
                // Add Service Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LabAddService(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add Service',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      overflow:
                          TextOverflow.ellipsis, // Add ellipsis for long text
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangePassword(),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Change Password',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilities() {
    if (availabilities.isEmpty) {
      return Center(
        child: Text(
          'No availabilities found for this user.',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Align the title to the left
      children: [
        // Add a title with improved styling
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Text(
            'Availabilities',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ),

        // The list of availabilities with improved styling
        ListView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(), // Disable scrolling for better layout
          itemCount: availabilities.length,
          itemBuilder: (context, index) {
            final availability = availabilities[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                  title: Text(
                    '${availability['day_of_week']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal,
                    ),
                  ),
                  subtitle: Text(
                    'Start: ${availability['start_time']} - End: ${availability['end_time']}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLabData() {
    return labData.isEmpty
        ? const SizedBox
            .shrink() // Return an empty box if no lab data is loaded
        : Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Lab Information",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditProvider(labData: labData),
                              ),
                            );
                            if (result == true) {
                              await refreshData();
                            }
                          },
                          child: Icon(Icons.edit, color: primaryColor)),
                    ]),
                const SizedBox(height: 4),
                const SizedBox(height: 16),

                Text(
                  'Lab Bio: ${labData['bio'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                Text(
                  'Lab City: ${labData['city'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                Text(
                  'Verification Status: ${labData['verification_status'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                // Services Section
                const Text(
                  "Services:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal,
                  ),
                ),
                services.isEmpty
                    ? const Center(
                        child: Text(
                            'No services available')) // Show a loading indicator while services are loading
                    : ListView.builder(
                        shrinkWrap: true, // Prevent overflow issues
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 6,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                child: Text(
                                  services[index], // Display service name
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.black,
            radius: 60,
            backgroundImage: userData['profile_image'] != null
                ? NetworkImage(userData['profile_image'])
                : const AssetImage("assets/images/logo.png") as ImageProvider,
          ),
          const SizedBox(height: 10),
          Text(
            userData['username'] ?? 'No Username',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfile(userData: userData),
                  ),
                );
                if (result == true) {
                  await refreshData();
                }
              },
              child: Icon(Icons.edit, color: primaryColor)),
          const SizedBox(height: 4),
          Text(
            userData['email'] ?? 'No Email',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            userData['phone_number'] ?? 'No Phone Number',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalDetails() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Medical Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow("Full Name", userData['full_name'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildLifestyleSection() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Lifestyle Preferences",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
                "Is Verified", userData['is_verified'] == true ? 'Yes' : 'No'),
            _buildDetailRow(
                "Is Active", userData['is_active'] == true ? 'Yes' : 'No'),
            _buildDetailRow("User Type", userData['user_type'] ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      onPressed: logout,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: const Text(
        'Logout',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
