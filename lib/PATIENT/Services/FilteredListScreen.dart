import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Services/doctor_detail_service.dart';
import 'package:flutter_sanar_proj/PATIENT/Services/nurse_detail_service.dart';
import 'package:flutter_sanar_proj/STTAFF/HOSPITAL/ProviderDetailsScreen.dart';
import 'package:http/http.dart' as http;

class FilteredListScreen extends StatefulWidget {
  final int serviceId; // Pass the service ID to this screen
  final String servicePrice;
  const FilteredListScreen(
      {super.key, required this.serviceId, required this.servicePrice});

  @override
  _FilteredListScreenState createState() => _FilteredListScreenState();
}

class _FilteredListScreenState extends State<FilteredListScreen> {
  List<Map<String, dynamic>> providers =
      []; // Unified list for doctors and nurses
  Map<String, dynamic>? serviceData; // Store the entire service data
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProviders(); // Fetch providers when the screen is initialized
  }

  Future<void> fetchProviders() async {
    final url =
        Uri.parse('http://67.205.166.136/api/services/${widget.serviceId}/');
    final response = await http.get(url, headers: {
      'accept': 'application/json',
      'X-CSRFTOKEN':
          'RwpfLJZS49bhiZLmvXQ77CqB3Ca0VNa1WqmtZX8pFXGO0by2gp177JJwkOjsq1Mu',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(response.body);
      setState(() {
        serviceData = data; // Store the entire service data
        providers = List<Map<String, dynamic>>.from(data['provider_info']);
        _isLoading = false;
      });
    } else {
      print("Failed to load providers: ${response.statusCode}");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Staff"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Color.fromARGB(255, 223, 245, 244)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.teal.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : providers.isEmpty
                  ? const Center(
                      child: Text('No providers available for this service.'))
                  : ListView.builder(
                      itemCount: providers.length,
                      itemBuilder: (context, index) {
                        final provider = providers[index];
                        return Card(
                          color: Colors.white,
                          margin: const EdgeInsets.all(8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: provider['personal_photo'] != null
                                  ? Image.network(
                                      provider['personal_photo'],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: 50,
                                          height: 50,
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.person,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                            title: Text(
                              provider['name'] ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              "Type: ${provider['type'] ?? 'N/A'}",
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                // Navigate based on the type
                                if (provider['type'] == 'nurse') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          NurseDetailServiceScreen(
                                        nurse: provider, // Pass the nurse data
                                      ),
                                    ),
                                  );
                                } else if (provider['type'] == 'hospital' ||
                                    provider['type'] == 'lab') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProviderDetailsScreen(
                                        service:
                                            serviceData!, // Pass the entire service data
                                      ),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DoctorDetailsServiceScreen(
                                        doctor:
                                            provider, // Pass the doctor data
                                        servicePrice: widget.servicePrice,
                                      ),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "View Profile",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
