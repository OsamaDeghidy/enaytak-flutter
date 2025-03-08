import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/STTAFF/HOSPITAL/ProviderDetailsScreen.dart';
import 'package:http/http.dart' as http;

class ServiceScreen extends StatefulWidget {
  final int categoryId;

  const ServiceScreen({required this.categoryId, Key? key}) : super(key: key);

  @override
  _ServiceScreenState createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  Map<String, dynamic>? categoryDetails;
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> subcategories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategoryDetails();
  }

  // Fetch category details
  Future<void> _fetchCategoryDetails() async {
    final categoryResponse = await http.get(
      Uri.parse('http://67.205.166.136/api/service-categories/'),
      headers: {
        'accept': 'application/json; charset=utf-8',
      },
    );
    if (categoryResponse.statusCode == 200) {
      final categories =
          json.decode(utf8.decode(categoryResponse.bodyBytes))['results'];

      // Find the category by categoryId
      final category = categories.firstWhere(
          (cat) => cat['id'] == widget.categoryId,
          orElse: () => null);

      if (category != null) {
        setState(() {
          categoryDetails = category;
          services.clear(); // Clear the services list before fetching new ones
        });
        print('Category: ${category}');
        print('category ids  +${category['service_ids'][0]['id']}');

        // If subcategory_ids is not null, fetch subcategory details
        List<dynamic> serviceIds =
            category['service_ids'].map((service) => service['id']).toList();

        // If subcategory_ids is not null, fetch subcategory details
        print('category sub ${category['subcategory_ids']}');
        if (category['subcategory_ids'] != null &&
            category['subcategory_ids'].isNotEmpty) {
          _fetchSubcategories(category['subcategory_ids']);
        } else {
          // Fetch services using all the extracted service_ids
          _fetchServices(serviceIds);
        }
      }
    }
  }

  // Fetch subcategories
  Future<void> _fetchSubcategories(List<dynamic> subcategoryIds) async {
    for (var subcategoryId in subcategoryIds) {
      final subcategoryResponse = await http.get(
        Uri.parse('http://67.205.166.136/api/subcategories/$subcategoryId/'),
        headers: {
          'accept': 'application/json; charset=utf-8',
        },
      );
      if (subcategoryResponse.statusCode == 200) {
        final subcategory =
            json.decode(utf8.decode(subcategoryResponse.bodyBytes));
        setState(() {
          subcategories.add(subcategory);
        });

        // After fetching subcategory, fetch its associated services
        _fetchServicesFromSubcategory(subcategory['service_ids']);
      }
    }
  }

  // Fetch services from subcategory
  Future<void> _fetchServicesFromSubcategory(List<dynamic> serviceIds) async {
    for (var serviceId in serviceIds) {
      final serviceResponse = await http.get(
        Uri.parse('http://67.205.166.136/api/services/$serviceId/'),
        headers: {
          'accept': 'application/json; charset=utf-8',
        },
      );
      if (serviceResponse.statusCode == 200) {
        final service = json.decode(utf8.decode(serviceResponse.bodyBytes));
        setState(() {
          services.add(service);
        });
      }
    }
  }

  // Fetch services from category directly
  Future<void> _fetchServices(List<dynamic> serviceIds) async {
    for (var serviceId in serviceIds) {
      final serviceResponse = await http.get(
        Uri.parse('http://67.205.166.136/api/services/$serviceId/'),
        headers: {
          'accept': 'application/json; charset=utf-8',
        },
      );
      if (serviceResponse.statusCode == 200 ||
          serviceResponse.statusCode == 201) {
        final service = json.decode(utf8.decode(serviceResponse.bodyBytes));

        // Initialize variable for userId (this could be a lab, hospital, doctor, or nurse)
        int? userId;
        int? labId;
        int? doctorId;
        int? hospitalId;
        int? nurseId;

        // Check the service's provider_info to determine if it's linked to a lab, doctor, hospital, or nurse
        if (service['provider_info'] != null &&
            service['provider_info'].isNotEmpty) {
          for (var provider in service['provider_info']) {
            if (provider['type'] == 'lab') {
              labId = provider['id'];
              break; // Exit the loop once we find the first provider
            } else if (provider['type'] == 'doctor') {
              doctorId = provider['id'];
              break; // Exit the loop once we find the first provider
            } else if (provider['type'] == 'hospital') {
              hospitalId = provider['id'];
              break; // Exit the loop once we find the first provider
            } else if (provider['type'] == 'nurse') {
              nurseId = provider['id'];
              break; // Exit the loop once we find the first provider
            }
          }
        }

        // Fetch the userId based on the provider type
        if (labId != null) {
          final labResponse = await http.get(
            Uri.parse('http://67.205.166.136/api/labs/$labId/'),
            headers: {
              'accept': 'application/json; charset=utf-8',
            },
          );
          if (labResponse.statusCode == 200 || labResponse.statusCode == 201) {
            final lab = json.decode(utf8.decode(labResponse.bodyBytes));
            userId = lab['user']; // Fetch the userId from lab data
          }
        } else if (doctorId != null) {
          final doctorResponse = await http.get(
            Uri.parse('http://67.205.166.136/api/doctors/$doctorId/'),
            headers: {
              'accept': 'application/json; charset=utf-8',
            },
          );
          if (doctorResponse.statusCode == 200 ||
              doctorResponse.statusCode == 201) {
            final doctor = json.decode(utf8.decode(doctorResponse.bodyBytes));
            userId = doctor['user']; // Fetch the userId from doctor data
          }
        } else if (hospitalId != null) {
          final hospitalResponse = await http.get(
            Uri.parse('http://67.205.166.136/api/hospitals/$hospitalId/'),
            headers: {
              'accept': 'application/json; charset=utf-8',
            },
          );
          if (hospitalResponse.statusCode == 200 ||
              hospitalResponse.statusCode == 201) {
            final hospital =
                json.decode(utf8.decode(hospitalResponse.bodyBytes));
            userId = hospital['user']; // Fetch the userId from hospital data
          }
        } else if (nurseId != null) {
          final nurseResponse = await http.get(
            Uri.parse('http://67.205.166.136/api/nurses/$nurseId/'),
            headers: {
              'accept': 'application/json; charset=utf-8',
            },
          );
          if (nurseResponse.statusCode == 200 ||
              nurseResponse.statusCode == 201) {
            final nurse = json.decode(utf8.decode(nurseResponse.bodyBytes));
            userId = nurse['user']; // Fetch the userId from nurse data
          }
        }

        // If we found a valid userId, fetch the user's profile image
        if (userId != null) {
          final userResponse = await http.get(
            Uri.parse('http://67.205.166.136/api/users/$userId/'),
            headers: {
              'accept': 'application/json; charset=utf-8',
            },
          );

          if (userResponse.statusCode == 200 ||
              userResponse.statusCode == 201) {
            final user = json.decode(utf8.decode(userResponse.bodyBytes));

            setState(() {
              service['profile_image'] =
                  user['profile_image']; // Save profile_image URL
            });
          }
        }

        setState(() {
          services.add(service); // Add the service to the list
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (categoryDetails == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${categoryDetails!['name'] ?? 'Unavailable'}'), // Display 'Unavailable' if the category name is null
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Name
              Text(
                '${categoryDetails!['name'] ?? 'Unavailable'}', // Handle null category name
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${categoryDetails!['description'] ?? 'Unavailable'}', // Handle null category description
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),

              // Subcategories Section
              if (subcategories.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Subcategories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ),
              if (subcategories.isNotEmpty)
                ...subcategories.map((subcategory) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      title: Text(
                        subcategory['name'] ??
                            'Unavailable', // Handle null subcategory name
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        subcategory['description'] ??
                            'Unavailable', // Handle null subcategory description
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Navigate to subcategory details if needed
                      },
                    ),
                  );
                }).toList(),

              // Services Section
              if (services.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Services',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ),
              if (services.isNotEmpty)
                ...services.map((service) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: service['profile_image'] != null &&
                                service['profile_image'].isNotEmpty
                            ? NetworkImage(service[
                                'profile_image']) // Display profile image if available
                            : null,
                        child: service['profile_image'] == null ||
                                service['profile_image'].isEmpty
                            ? const Icon(Icons.image,
                                size: 20, color: Colors.teal)
                            : null, // Show icon if no image is available
                      ),
                      title: Text(
                        service['name'] ??
                            'Unavailable', // Handle null service name
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        service['description'] ??
                            'Unavailable', // Handle null service description
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: Text(
                        '${service['price'] ?? 'N/A'} SAR', // Handle null service price
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      onTap: () {
                        // Navigate to the ProviderDetailsScreen when a service is tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProviderDetailsScreen(
                              service:
                                  service, // Pass the service data to the new screen
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),

              // Fallback message when no services or subcategories are available
              if (services.isEmpty && subcategories.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No services or subcategories available for this category',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
