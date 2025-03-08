import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/STTAFF/HOSPITAL/DiagnosisPage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LabAppointmentPage extends StatefulWidget {
  const LabAppointmentPage({super.key});

  @override
  _LabAppointmentPageState createState() => _LabAppointmentPageState();
}

class _LabAppointmentPageState extends State<LabAppointmentPage> {
  bool _isLoading = true;
  List<dynamic> _appointmentsDetails = [];
  String? _errorMessage;
  late int? labId;
  String selectedStatus = 'all'; // Default status for filtering

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Map<int, Map<String, dynamic>> _serviceDetailsCache = {};
  Future<Map<String, dynamic>?> _fetchServiceDetails(int serviceId) async {
    if (_serviceDetailsCache.containsKey(serviceId)) {
      return _serviceDetailsCache[serviceId];
    }

    final url = Uri.parse('http://67.205.166.136/api/services/$serviceId/');
    final response = await http.get(
      url,
      headers: {
        'accept': 'application/json; charset=utf-8',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      _serviceDetailsCache[serviceId] = data;
      return data;
    } else {
      return null;
    }
  }

  Future<void> _fetchAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    labId = prefs.getInt('specificId');

    if (labId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "No LAB ID found.";
      });
      return;
    }

    final url = Uri.parse(
        'http://67.205.166.136/api/providers/lab/$labId/appointments/');
    final response = await http.get(
      url,
      headers: {
        'accept': 'application/json; charset=utf-8',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final matchedAppointments = data as List;
      print(data);
      print(matchedAppointments);

      if (matchedAppointments.isNotEmpty) {
        setState(() {
          _isLoading = false;
          _appointmentsDetails = matchedAppointments;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = "No appointments found for this lab.";
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load appointments.";
      });
    }
  }

  List<dynamic> get filteredAppointments {
    if (selectedStatus == 'all') {
      return _appointmentsDetails;
    }
    return _appointmentsDetails
        .where((appointment) => appointment['status'] == selectedStatus)
        .toList();
  }

  void navigateToDiagnosisPage(Map<String, dynamic> appointment) {
    final appointmentId = appointment['id'];
    final patientId = appointment['patient'];
    final hospitalId = appointment['hospital'];
    final doctorId = appointment['doctor'];
    final nurseId = appointment['nurse'];
    final labId = appointment['lab'];
    final status = appointment['status'];
    final services = appointment['services']; // Pass the services array
    final service_type = appointment['service_type']; // Pass the services array
    final notes = appointment['notes']; // Pass the services array

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiagnosisPage(
            notes: notes,
            service_type: service_type,
            appointmentId: appointmentId,
            patientId: patientId,
            hospitalId: hospitalId,
            doctorId: doctorId,
            nurseId: nurseId,
            labId: labId,
            status: status,
            services: services),
      ),
    ).then((updatedStatus) {
      if (updatedStatus != null) {
        setState(() {
          appointment['status'] = updatedStatus; // Update the status locally
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> statuses = [
      'booked',
      'confirmed',
      'in_progress',
      'completed',
      'dispatched',
      'delivered',
      'cancelled',
      'pending',
      'rejected'
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(kToolbarHeight), // Set height of the AppBar
        child: AppBar(
          backgroundColor: Colors.teal,
          title: const Text('Appointments'),
          automaticallyImplyLeading: false, // This ensures no back arrow
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : Column(
                  children: [
                    // Filter Buttons
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            // "All" Button
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedStatus = 'all';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 16),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                decoration: BoxDecoration(
                                  color: selectedStatus == 'all'
                                      ? Colors.teal
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: const Text(
                                  'ALL',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            // Dynamically generated status buttons
                            ...statuses.map((status) {
                              final isSelected = selectedStatus == status;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedStatus = status;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 16),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.teal
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Text(
                                    status.replaceAll("_", " ").toUpperCase(),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Appointment List
                    Expanded(
                      child: filteredAppointments.isEmpty
                          ? const Center(
                              child: Text(
                                'No appointments available.',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredAppointments.length,
                              itemBuilder: (context, index) {
                                final appointment = filteredAppointments[index];
                                // Using the new _buildAppointmentCard widget
                                return _buildAppointmentCard(appointment);
                              },
                            ),
                    ),
                  ],
                ),
    );
    ;
  } // Widget for Appointment Card

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    return GestureDetector(
      onTap: () => navigateToDiagnosisPage(appointment),
      child: Card(
        margin: const EdgeInsets.all(10),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppointmentDetailRow(
                  'Date & Time:', appointment['date_time']),
              _buildAppointmentDetailRow(
                  'Service Type:', appointment['service_type']),
              _buildAppointmentDetailRow('Status:', appointment['status']),
              _buildAppointmentDetailRow('Cost:', appointment['cost'] ?? 'N/A'),
              _buildServiceDetailsRow('Service:', appointment['services']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceDetailsRow(String label, List<dynamic> serviceIds) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.teal,
            ),
          ),
          ...serviceIds.map((serviceId) => FutureBuilder<Map<String, dynamic>?>(
                future: _fetchServiceDetails(serviceId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading service details...');
                  }
                  if (snapshot.hasError || snapshot.data == null) {
                    return Text('Failed to load service $serviceId');
                  }

                  final service = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name: ${service['name']}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Description: ${service['description']}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  );
                },
              )),
        ],
      ),
    );
  }

// Widget for a single appointment detail row
  Widget _buildAppointmentDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.teal,
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: Text(
              '$value',
              style: const TextStyle(fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
