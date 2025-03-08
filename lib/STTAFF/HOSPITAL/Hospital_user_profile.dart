import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/User_Profile/Edit_profile.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Colors/colors.dart';
import 'package:flutter_sanar_proj/STTAFF/HOSPITAL/Edit_provider_hospital.dart';
import 'package:flutter_sanar_proj/STTAFF/HOSPITAL/Hospital_bottom_navbar.dart';
import 'package:flutter_sanar_proj/STTAFF/HOSPITAL/add_Service.dart';
import 'package:flutter_sanar_proj/STTAFF/HOSPITAL/availabilty_Screen.dart';
import 'package:flutter_sanar_proj/STTAFF/HOSPITAL/change_password.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HospitalUserProfile extends StatefulWidget {
  const HospitalUserProfile({super.key});

  @override
  State<HospitalUserProfile> createState() => _HospitalUserProfileState();
}

class _HospitalUserProfileState extends State<HospitalUserProfile> {
  Map<String, dynamic> userData = {};
  Map<String, dynamic> hospitalData = {}; // Store hospital data here
  String? token;
  List<dynamic> doctors = []; // Store doctor IDs
  List<dynamic> nurses = []; // Store doctor IDs
  Map<String, dynamic> doctorDetails = {};
  int? userId;
  int? hospitalId;
  List<dynamic> services = []; // Store service data here

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchHospital();
    fetchAvailabilities(); // Fetch and filter availabilities
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
        // Parse the response body
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> allAvailabilities =
            data['results']; // Access the 'results' field

        // Filter availabilities that match the current userId
        final List<dynamic> userAvailabilities =
            allAvailabilities.where((availability) {
          return availability['user'] == userId;
        }).toList();

        setState(() {
          // Replace your existing list of availabilities with the filtered data
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

  Future<void> fetchHospital() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('access');
    hospitalId = prefs.getInt('specificId'); // Fetch the specific_id from prefs
    print('Token: $token');
    print('Hospital ID: $hospitalId');
    if (token == null || hospitalId == null) {
      _showErrorSnackBar("No token or hospital ID found. Please login first.");
      return;
    }

    final String apiUrl =
        'http://67.205.166.136/api/hospitals/$hospitalId/'; // Use dynamic hospitalId here

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
          hospitalData = json.decode(utf8.decode(response.bodyBytes));
        });

        List<String> doctorNames = [];
        List<String> nurseNames = []; // Add a list for nurse names
        List<String> serviceNames = []; // Add a list for service names

        // Fetch doctor details
        for (int doctorId in hospitalData['doctors']) {
          await fetchDoctorDetails(doctorId, doctorNames);
        }

        // Fetch nurse details
        for (int nurseId in hospitalData['nurses']) {
          // Assuming 'nurses' is a list in the response
          await fetchNurseDetails(nurseId, nurseNames);
        }
        /* for (int serviceId in hospitalData['services']) {
          await fetchServiceDetails(serviceId, serviceNames);
        } */
        await fetchServices(serviceNames);

        setState(() {
          doctors = doctorNames; // Store doctor names in the doctors list
          nurses = nurseNames; // Store nurse names in the nurses list
          services = serviceNames; // Store service names in the services list
        });
      } else {
        String errorMsg =
            'Error: Unable to fetch hospital data. Status code: ${response.statusCode} status body :${response.body}';
      }
    } catch (e) {
      String errorMsg = 'Failed to load hospital data: $e';
      _showErrorSnackBar(errorMsg);
    }
  }

  Future<void> fetchServices(List<String> serviceNames) async {
    final String servicesUrl =
        'http://67.205.166.136/api/hospitals/$hospitalId/services/';

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
        for (var service in servicesData['results']) {
          serviceNames.add(service['name']); // Extract and add service names
        }
      } else {
        print(
            'Error: Failed to fetch services. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: Failed to fetch services. Exception: $e');
    }
  }

  Future<void> fetchNurseDetails(int nurseId, List<String> nurseNames) async {
    final String nurseApiUrl = 'http://67.205.166.136/api/nurses/$nurseId/';

    try {
      final response = await http.get(
        Uri.parse(nurseApiUrl),
        headers: {
          'accept': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final nurseData = json.decode(utf8.decode(response.bodyBytes));

        // Extract the user ID from the nurse data
        int userId = nurseData['user'];

        // Fetch the user details using the user ID
        await fetchUserDetails(userId, nurseNames);
      } else {
        nurseNames.add('Error: Unable to fetch nurse data');
      }
    } catch (e) {
      nurseNames.add('Failed to load nurse data');
    }
  }

  Future<void> fetchDoctorDetails(
      int doctorId, List<String> doctorNames) async {
    final String doctorApiUrl = 'http://67.205.166.136/api/doctors/$doctorId/';

    try {
      final response = await http.get(
        Uri.parse(doctorApiUrl),
        headers: {
          'accept': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final doctorData = json.decode(utf8.decode(response.bodyBytes));

        // Extract the user ID from the doctor data
        int userId = doctorData['user'];

        // Fetch the user details using the user ID
        await fetchUserDetails(userId, doctorNames);
      } else {
        doctorNames.add('Error: Unable to fetch doctor data');
      }
    } catch (e) {
      doctorNames.add('Failed to load doctor data');
    }
  }

  Future<void> fetchUserDetails(int userId, List<String> doctorNames) async {
    final String userApiUrl = 'http://67.205.166.136/api/users/$userId/';

    try {
      final response = await http.get(
        Uri.parse(userApiUrl),
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        String userName = userData['full_name'] ?? 'No Name';

        // Add the user's name to the list of doctor names
        doctorNames.add(userName);
      } else {
        doctorNames.add('Error: Unable to fetch user data');
      }
    } catch (e) {
      doctorNames.add('Failed to load user data');
    }
  }

  Future<void> fetchServiceDetails(
      int serviceId, List<String> serviceNames) async {
    final String serviceApiUrl =
        'http://67.205.166.136/api/services/$serviceId/';

    try {
      final response = await http.get(
        Uri.parse(serviceApiUrl),
        headers: {
          'accept': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final serviceData = json.decode(utf8.decode(response.bodyBytes));
        String serviceName = serviceData['name'] ?? 'No Service Name';
        serviceNames.add(serviceName);
      } else {
        serviceNames.add('Error: Unable to fetch service data');
      }
    } catch (e) {
      serviceNames.add('Failed to load service data');
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
      int selectedHospitalId,
      int selectedDoctorId,
      int selectedNurseId) async {
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
      'selectedHospitalId': selectedHospitalId,
      'selectedDoctorId': selectedDoctorId,
      'selectedNurseId': selectedNurseId
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
                      builder: (context) => const HospitalMainScreen(),
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
            _buildHospitalData(),
            _buildAvailabilities(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AddAvailabilityScreen()));
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
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddService(),
                    ),
                  ),
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
                    style: TextStyle(fontSize: 18, color: Colors.white),
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

  Future<void> refreshData() async {
    // Reload all necessary data
    await fetchUserData();
    await fetchHospital();
    await fetchAvailabilities();
  }

  void _showAddServiceDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController durationController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    int selectedCategoryId = 1;
    int? selectedDoctorId; // For storing selected doctor
    int? selectedNurseId; // For storing selected nurse
    int? selectedHospitalId =
        hospitalId; // Default to the hospital id fetched from SharedPreferences

    // Mapping of category names to their respective integer IDs
    Map<String, int> categoryMap = {
      'Homevisit': 4,
      'Laboratory': 5,
      'Seasonal Flu Vaccination': 3,
      'Radiology': 0,
      'Nursing Services': 2,
      'Kids Vaccination': 6,
      'استرخاء': 7,
      'اسsdaترخاء': 1,
    };

    // Fetching doctors and nurses data
    List<DropdownMenuItem<int>> doctorItems =
        doctors.map<DropdownMenuItem<int>>((doctor) {
      return DropdownMenuItem<int>(
        value: doctor['id'],
        child: Text(doctor['name']),
      );
    }).toList();

    List<DropdownMenuItem<int>> nurseItems =
        nurses.map<DropdownMenuItem<int>>((nurse) {
      return DropdownMenuItem<int>(
        value: nurse['id'],
        child: Text(nurse['name']),
      );
    }).toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Service'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Service Name'),
                ),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: durationController,
                  decoration:
                      InputDecoration(labelText: 'Duration (e.g., 00:30:00)'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration:
                      InputDecoration(labelText: 'Description (optional)'),
                ),
                DropdownButton<int>(
                  value: selectedCategoryId,
                  onChanged: (newValue) {
                    setState(() {
                      selectedCategoryId = newValue!;
                    });
                  },
                  items: categoryMap.entries.map<DropdownMenuItem<int>>(
                      (MapEntry<String, int> entry) {
                    return DropdownMenuItem<int>(
                      value: entry.value,
                      child: Text(entry.key),
                    );
                  }).toList(),
                ),
                DropdownButton<int>(
                  value: selectedDoctorId, // Selected doctor
                  onChanged: (newValue) {
                    setState(() {
                      selectedDoctorId = newValue;
                    });
                  },
                  items: doctorItems.isNotEmpty
                      ? doctorItems
                      : [
                          DropdownMenuItem<int>(
                              value: null, child: Text('No doctors available'))
                        ],
                  hint: Text('Select Doctor'),
                ),
                // Nurse Dropdown
                DropdownButton<int>(
                  value: selectedNurseId, // Selected nurse
                  onChanged: (newValue) {
                    setState(() {
                      selectedNurseId = newValue;
                    });
                  },
                  items: nurseItems.isNotEmpty
                      ? nurseItems
                      : [
                          DropdownMenuItem<int>(
                              value: null, child: Text('No nurses available'))
                        ],
                  hint: Text('Select Nurse'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String name = nameController.text;
                String price = priceController.text;
                String duration = durationController.text;
                String description = descriptionController.text;

                // Ensure all fields are filled
                if (name.isNotEmpty &&
                    price.isNotEmpty &&
                    duration.isNotEmpty) {
                  createService(name, price, duration, selectedCategoryId,
                      selectedHospitalId!, selectedDoctorId!, selectedNurseId!);
                  Navigator.of(context).pop();
                } else {
                  Fluttertoast.showToast(msg: "Please fill all fields");
                }
              },
              child: Text('Add Service'),
            ),
          ],
        );
      },
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

  Widget _buildHospitalData() {
    return hospitalData.isEmpty
        ? const SizedBox
            .shrink() // Return an empty box if no hospital data is loaded
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
                                builder: (context) => EditProviderHospital(
                                    hospitalData: hospitalData),
                              ),
                            );
                            if (result == true) {
                              await refreshData();
                            }
                          },
                          child: Icon(Icons.edit, color: primaryColor)),
                    ]),
                const SizedBox(height: 16),
                Text(
                  'Hospital Id: ${hospitalData['id'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                Text(
                  'Hospital Verification: ${hospitalData['verification_status'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 16),
                // Doctors Section
                const Text(
                  "Doctors:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal,
                  ),
                ),
                doctors.isEmpty
                    ? const Center(
                        child: Text(
                          'No doctors available.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ) // Show a loading indicator while doctors are loading
                    : ListView.builder(
                        shrinkWrap: true, // To prevent overflow issues
                        itemCount: doctors.length,
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
                                  doctors[index],
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                const SizedBox(height: 16),
                // Nurses Section
                const Text(
                  "Nurses:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal,
                  ),
                ),
                nurses.isEmpty
                    ? const Center(
                        child: Text(
                          'No Nurses available.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ) // Show a loading indicator while nurses are loading
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: nurses.length,
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
                                  nurses[index],
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                              ),
                            ),
                          );
                        },
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
                          'No Services available.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
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
                                  services[index],
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
            radius: 60,
            backgroundColor: Colors.black,
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
