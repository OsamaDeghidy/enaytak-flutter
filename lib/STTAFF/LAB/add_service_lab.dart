import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LabAddService extends StatefulWidget {
  final int? userId; // Add userId parameter

  const LabAddService({super.key, this.userId});

  @override
  State<LabAddService> createState() => _AddServiceState();
}

class _AddServiceState extends State<LabAddService> {
  Map<String, dynamic> labData = {};
  List<Map<String, dynamic>> subcategories = []; // Store subcategories
  String? selectedSubcategoryId;
  String? token;

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

  Map<String, dynamic> userData = {}; // Store user data

  @override
  void initState() {
    super.initState();
    fetchLab();
    if (widget.userId != null) {
      fetchUserDetails(
          widget.userId!); // Fetch user details if userId is provided
    }
  }

  int? labId;
  Future<void> fetchLab() async {
    setState(() {
      isLoading = true; // Set loading state true
    });

    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('access');
    labId = prefs.getInt('specificId'); // Fetch hospital ID

    if (token == null || labId == null) {
      _showErrorSnackBar("No token or hospital ID found. Please login first.");
      setState(() {
        isLoading = false;
      });
      return;
    }

    final String apiUrl = 'http://67.205.166.136/api/labs/$labId/';

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
          labData = json.decode(utf8.decode(response.bodyBytes));
        });

        // Fetch doctor and nurse details

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

  Future<void> fetchSubcategories(int categoryId) async {
    final String subcategoriesApiUrl =
        'http://67.205.166.136/api/service-categories/$categoryId/subcategories/';

    try {
      final response = await http.get(
        Uri.parse(subcategoriesApiUrl),
        headers: {
          'accept': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          subcategories = List<Map<String, dynamic>>.from(data['results']);
        });
      } else {
        _showErrorSnackBar('Error fetching subcategories.');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load subcategories: $e');
    }
  }

  Future<void> fetchUserDetails(int userId) async {
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
        _showErrorSnackBar('Failed to fetch user details.');
      }
    } catch (e) {
      _showErrorSnackBar('Error fetching user details: $e');
    }
  }

  Future<void> fetchUserDetailsWithList(
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
        fetchedList.add(userData);
      } else {
        _showErrorSnackBar('Failed to fetch user details with list.');
      }
    } catch (e) {
      _showErrorSnackBar('Error fetching user details with list: $e');
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

  final _formKey = GlobalKey<FormState>();
  File? _pickedImage;

  Future<void> postService() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access');
      final labId = prefs.getInt('specificId');

      if (token == null ||
          labId == null ||
          selectedCategory == null ||
          selectedSubcategoryId == null) {
        throw Exception(
            'Missing token, specificId, categoryId, or subcategoryId in shared preferences');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://67.205.166.136/api/services/'),
      );

      request.headers.addAll({
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.fields.addAll({
        'name': nameController.text,
        'description': descriptionController.text,
        'price': priceController.text,
        'duration': durationController.text,
        'category': selectedCategory.toString(),
        'subcategory': selectedSubcategoryId.toString(),
        'labs': labId.toString(),
      });

      if (_pickedImage != null) {
        request.files.add(
            await http.MultipartFile.fromPath('image', _pickedImage!.path));
      }

      final response = await request.send();
      final responseString = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
            'Service posted successfully!',
            style: TextStyle(color: Colors.green),
          )),
        );
        _formKey.currentState!.reset();
        setState(() {
          _pickedImage = null;
        });
      } else {
        throw Exception('Failed to post service: $responseString');
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration:
                          const InputDecoration(labelText: 'Service Name'),
                    ),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Price'),
                    ),
                    TextField(
                      controller: durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Duration (minutes)'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                    DropdownButton<int>(
                      hint: const Text('Select Category'),
                      value: selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                          selectedSubcategoryId =
                              null; // Reset subcategory when category changes
                          if (value != null) {
                            fetchSubcategories(value);
                          }
                        });
                      },
                      items: categories
                          .map((category) => DropdownMenuItem<int>(
                                value: category['id'],
                                child: Text(category['name']),
                              ))
                          .toList(),
                    ),
                    if (subcategories.isNotEmpty)
                      DropdownButton<String>(
                        hint: const Text('Select Subcategory'),
                        value: selectedSubcategoryId,
                        onChanged: (value) {
                          setState(() {
                            selectedSubcategoryId = value;
                          });
                        },
                        items: subcategories
                            .map((subcategory) => DropdownMenuItem<String>(
                                  value: subcategory['id'].toString(),
                                  child: Text(subcategory['name']),
                                ))
                            .toList(),
                      ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isEmpty ||
                            priceController.text.isEmpty ||
                            durationController.text.isEmpty ||
                            selectedCategory == null) {
                          _showErrorSnackBar("Please fill all fields");
                        } else {
                          postService();
                        }
                      },
                      child: const Text('Add Service'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
