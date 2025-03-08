import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Appointment/AppointmentDetailsScreen.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Constant_Widgets/custom_AppBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  String selectedStatus = 'booked'; // Default status
  List<dynamic> allAppointments = [];
  List<dynamic> services = []; // To hold service details
  bool isLoading = true; // Show loading spinner during API call
  String errorMessage = ''; // To hold error messages

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId') ?? 0;

      final response = await http.get(
        Uri.parse(
            'http://67.205.166.136/api/users/$userId/appointments/?page=1'),
        headers: {
          'accept': 'application/json; charset=utf-8',
          'X-CSRFTOKEN':
              'nBu98iMSXQUHWNabH8k7LLALqEPDzjQVmeBE9u7XssKYmYnL1hmvmJ8qRXOAfQ0u',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        allAppointments = data['results'];
        await fetchServiceDetails(); // Fetch service details after appointments
        setState(() {
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load appointments');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching appointments: $error';
      });
    }
  }

  Future<void> fetchServiceDetails() async {
    List<Future<void>> serviceFutures = [];

    for (var appointment in allAppointments) {
      if (appointment['services'].isNotEmpty) {
        int serviceId = appointment['services'][0]; // Assuming single service
        serviceFutures.add(fetchService(serviceId)); // Add future to list
      }
    }

    // Wait for all service fetches to complete
    await Future.wait(serviceFutures);
  }

  Future<void> fetchService(int serviceId) async {
    final response = await http.get(
      Uri.parse('http://67.205.166.136/api/services/$serviceId/'),
      headers: {
        'accept': 'application/json; charset=utf-8',
        'X-CSRFTOKEN':
            'nBu98iMSXQUHWNabH8k7LLALqEPDzjQVmeBE9u7XssKYmYnL1hmvmJ8qRXOAfQ0u',
      },
    );

    if (response.statusCode == 200) {
      final serviceData = json.decode(utf8.decode(response.bodyBytes));
      services.add(serviceData); // Store service details
    }
  }

  List<dynamic> get filteredAppointments {
    // Filter appointments by status
    final filtered = allAppointments
        .where((appointment) => appointment['status'] == selectedStatus)
        .toList();

    // Sort appointments in descending order based on date_time
    filtered.sort((a, b) {
      final dateA = DateTime.parse(a['date_time']);
      final dateB = DateTime.parse(b['date_time']);
      return dateB.compareTo(dateA); // Sort in descending order
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.teal.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                color: Colors.teal,
              ))
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : Padding(
                    padding:
                        const EdgeInsets.only(top: 30, left: 16, right: 16),
                    child: Column(
                      children: [
                        // Toggle Buttons for Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedStatus = 'booked';
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedStatus == 'booked'
                                    ? Colors.teal
                                    : Colors.grey[300],
                              ),
                              child: const Text('Booking',
                                  style: TextStyle(color: Colors.white)),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedStatus = 'confirmed';
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedStatus == 'confirmed'
                                    ? Colors.teal
                                    : Colors.grey[300],
                              ),
                              child: const Text('Confirmed',
                                  style: TextStyle(color: Colors.white)),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  selectedStatus = 'cancelled';
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedStatus == 'cancelled'
                                    ? Colors.teal
                                    : Colors.grey[300],
                              ),
                              child: const Text('Cancelled',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Appointments List
                        Expanded(
                          child: filteredAppointments.isEmpty
                              ? const Center(child: Text('Select your status.'))
                              : ListView.builder(
                                  itemCount: filteredAppointments.length,
                                  itemBuilder: (context, index) {
                                    final appointment =
                                        filteredAppointments[index];
                                    final service = services.firstWhere(
                                        (service) =>
                                            service['id'] ==
                                            appointment['services'][0],
                                        orElse: () =>
                                            {'name': 'Unknown Service'});

                                    return GestureDetector(
                                      onTap: () {
                                        // Navigate to AppointmentDetailsScreen with necessary data
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AppointmentDetailsScreen(
                                                appointmentId: appointment[
                                                    'id'], // Pass the appointment ID
                                              ),
                                            ));
                                      },
                                      child: Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.2),
                                              blurRadius: 5,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Placeholder for Doctor Photo
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.asset(
                                                'assets/images/appointment.png',
                                                height: 80,
                                                width: 60,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            // Appointment Details
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Service Type
                                                  Text(
                                                    service['name'] ?? 'N/A',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  // Date and Time
                                                  Text(
                                                    DateFormat('yyyy-MM-dd')
                                                        .format(DateTime.parse(
                                                            appointment[
                                                                'date_time'])),
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  // Status
                                                  Text(
                                                    appointment['status'] ??
                                                        'N/A',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.teal,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
