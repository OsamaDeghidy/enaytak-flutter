import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddService extends StatefulWidget {
  const AddService({super.key});

  @override
  State<AddService> createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
  Map<String, dynamic> hospitalData = {};
  String? token;
  List<Map<String, dynamic>> doctors = []; // Store doctor data as {id, name}
  List<Map<String, dynamic>> nurses = []; // Store nurse data as {id, name}

  List<int> selectedDoctorIds = []; // Store selected doctor IDs
  List<int> selectedNurseIds = []; // Store selected nurse IDs

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  int? selectedCategory; // Store selected category ID

  Map<String, int> categoryMap = {
    'Homevisit': 4,
    'Laboratory': 5,
    'Seasonal Flu Vaccination': 3,
    'Radiology': 0,
    'Nursing Services': 2,
    'Kids Vaccination': 6,
    'استرخاء': 7,
  };

  bool isLoading = false; // For loading state

  @override
  void initState() {
    super.initState();
    fetchHospital();
  }

  int? hospitalId;
  Future<void> fetchHospital() async {
    setState(() {
      isLoading = true; // Set loading state true
    });

    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('access');
    hospitalId = prefs.getInt('specificId'); // Fetch hospital ID

    if (token == null || hospitalId == null) {
      _showErrorSnackBar("No token or hospital ID found. Please login first.");
      setState(() {
        isLoading = false;
      });
      return;
    }

    final String apiUrl = 'http://67.205.166.136/api/hospitals/$hospitalId/';

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
          hospitalData = json.decode(utf8.decode(response.bodyBytes));
        });

        // Fetch doctor and nurse details
        List<Map<String, dynamic>> fetchedDoctors = [];
        List<Map<String, dynamic>> fetchedNurses = [];

        for (int doctorId in hospitalData['doctors']) {
          await fetchDoctorDetails(doctorId, fetchedDoctors);
        }

        for (int nurseId in hospitalData['nurses']) {
          await fetchNurseDetails(nurseId, fetchedNurses);
        }

        setState(() {
          doctors = fetchedDoctors;
          nurses = fetchedNurses;
        });
        fetchCategories();
      } else {
        _showErrorSnackBar('Error fetching hospital data.');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load hospital data: $e');
    } finally {
      setState(() {
        isLoading = false; // Set loading state false after fetching data
      });
    }
  }

  Future<void> fetchDoctorDetails(
      int doctorId, List<Map<String, dynamic>> fetchedDoctors) async {
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
        int userId = doctorData['user'];

        await fetchUserDetails(userId, fetchedDoctors);
      } else {
        fetchedDoctors.add(
            {'id': doctorId, 'name': 'Error: Unable to fetch doctor data'});
      }
    } catch (e) {
      fetchedDoctors
          .add({'id': doctorId, 'name': 'Failed to load doctor data'});
    }
  }

  Future<void> fetchUserDetails(
      int userId, List<Map<String, dynamic>> fetchedList) async {
    final String userApiUrl = 'http://67.205.166.136/api/users/$userId/';

    try {
      final response = await http.get(
        Uri.parse(userApiUrl),
        headers: {
          'accept': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(utf8.decode(response.bodyBytes));
        String userName = userData['full_name'] ?? 'No Name';

        fetchedList.add({'id': userId, 'name': userName});
      } else {
        fetchedList
            .add({'id': userId, 'name': 'Error: Unable to fetch user data'});
      }
    } catch (e) {
      fetchedList.add({'id': userId, 'name': 'Failed to load user data'});
    }
  }

  Future<void> fetchNurseDetails(
      int nurseId, List<Map<String, dynamic>> fetchedNurses) async {
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
        int userId = nurseData['user'];

        await fetchUserDetails(userId, fetchedNurses);
      } else {
        fetchedNurses
            .add({'id': nurseId, 'name': 'Error: Unable to fetch nurse data'});
      }
    } catch (e) {
      fetchedNurses.add({'id': nurseId, 'name': 'Failed to load nurse data'});
    }
  }

  List<Map<String, dynamic>> categories = []; // Store categories

  Future<void> fetchCategories() async {
    final String categoriesApiUrl =
        'http://67.205.166.136/api/service-categories/';

    try {
      final response = await http.get(
        Uri.parse(categoriesApiUrl),
        headers: {
          'accept': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          categories = List<Map<String, dynamic>>.from(data['results']);
        });
      } else {
        _showErrorSnackBar('Error fetching categories.');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load categories: $e');
    }
  }

  Future<void> createService(
    String name,
    String price,
    String duration,
    int category,
    List<int> doctors,
    List<int> nurses,
  ) async {
    final String apiUrl = 'http://67.205.166.136/api/services/';

    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type':
          'application/json', // Ensure Content-Type is set to application/json
    };

    // Construct the body based on the new model
    final body = json.encode({
      'name': name,
      'description': descriptionController.text.isNotEmpty
          ? descriptionController.text
          : null, // Optional field, can be null
      'price': price,
      'duration': duration,
      'category': category,
      'doctors': doctors, // List of doctor IDs
      'nurses': nurses, // List of nurse IDs
      'hospitals': [hospitalId], // List of hospital IDs
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Service'),
        centerTitle: true, // Center the app bar title
        elevation: 4, // Add subtle shadow for depth
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              ) // Show loading spinner while data loads
            : ListView(
                children: [
                  // Service Name Field
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Service Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.teal, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide:
                            const BorderSide(color: Colors.teal, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price Field
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.teal, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide:
                            const BorderSide(color: Colors.teal, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Duration Field
                  TextField(
                    controller: durationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Duration (minutes)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.teal, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide:
                            const BorderSide(color: Colors.teal, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description Field
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide(color: Colors.teal, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide:
                            const BorderSide(color: Colors.teal, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Dropdown
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Colors.teal, width: 1.5),
                    ),
                    child: DropdownButton<int>(
                      hint: const Text('Select Category'),
                      value: selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                      items: categories
                          .map((category) => DropdownMenuItem<int>(
                                value: category['id'],
                                child: Text(category['name']),
                              ))
                          .toList(),
                      isExpanded: true, // Make the dropdown fill the width
                      underline: Container(), // Remove the default underline
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Select Doctors Section
                  const Text(
                    'Select Doctors:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Column(
                    children: doctors
                        .map((doctor) => CheckboxListTile(
                              title: Text(doctor['name']),
                              value: selectedDoctorIds.contains(doctor['id']),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    selectedDoctorIds.add(doctor['id']);
                                  } else {
                                    selectedDoctorIds.remove(doctor['id']);
                                  }
                                });
                              },
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),

                  // Select Nurses Section
                  const Text(
                    'Select Nurses:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Column(
                    children: nurses
                        .map((nurse) => CheckboxListTile(
                              title: Text(nurse['name']),
                              subtitle: Text(nurse['id'].toString()),
                              value: selectedNurseIds.contains(nurse['id']),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    selectedNurseIds.add(nurse['id']);
                                  } else {
                                    selectedNurseIds.remove(nurse['id']);
                                  }
                                });
                              },
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isEmpty ||
                          priceController.text.isEmpty ||
                          durationController.text.isEmpty ||
                          selectedCategory == null) {
                        _showErrorSnackBar("Please fill all fields");
                      } else {
                        createService(
                          nameController.text,
                          priceController.text,
                          durationController.text,
                          selectedCategory!,
                          selectedDoctorIds,
                          selectedNurseIds,
                        );
                      }
                    },
                    child: const Text('Add Service'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.teal, // Set button color to teal
                      foregroundColor: Colors.white, // Set text color to white
                      elevation: 4, // Add shadow for depth
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
