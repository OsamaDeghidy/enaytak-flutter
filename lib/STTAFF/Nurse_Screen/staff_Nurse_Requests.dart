import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Constant_Widgets/custom_AppBar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class RequestItem {
  final String title;
  final String description;
  final String imageUrl;
  final String status;
  final VoidCallback? onAcceptPressed;
  final VoidCallback? onRejectPressed;

  RequestItem({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.status,
    this.onAcceptPressed,
    this.onRejectPressed,
  });
}

class Staff_Nurse_RequestScreen extends StatefulWidget {
  @override
  _Staff_Nurse_RequestScreenState createState() =>
      _Staff_Nurse_RequestScreenState();
}

class _Staff_Nurse_RequestScreenState extends State<Staff_Nurse_RequestScreen> {
  List<RequestItem> userRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<Map<String, String>> fetchServiceDetails(int serviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access') ?? '';

      final url = Uri.parse('http://67.205.166.136/api/services/$serviceId/');
      final response = await http.get(
        url,
        headers: {
          'accept': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return {
          'name': data['name'] ?? 'Unknown Service',
          'cost': data['price']?.toString() ?? 'No Cost'
        };
      }
      return {'name': 'Unknown Service', 'cost': 'No Cost'};
    } catch (error) {
      print('Error fetching service details: $error');
      return {'name': 'Unknown Service', 'cost': 'No Cost'};
    }
  }

  String formatAppointmentDate(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('yyyy-MM-dd').format(dateTime);
    } catch (e) {
      print('Error formatting date: $e');
      return dateTimeString;
    }
  }

  Future<void> fetchAppointments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access') ?? '';
      final specificId = prefs.getInt('specificId');

      if (specificId == null) {
        throw Exception('specificId is null');
      }

      final url = Uri.parse(
          'http://67.205.166.136/api/nurses/$specificId/appointments/?page=1');
      final response = await http.get(
        url,
        headers: {
          'accept': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final results = data['results'] as List;

        print('Nurse ID: $specificId');

        final filteredResults = results.where((appointment) {
          return appointment['status'] == 'booked';
        }).toList();

        // Create a list of futures for parallel service details fetching
        final List<Future<Map<String, dynamic>>> serviceFutures =
            filteredResults.map((appointment) async {
          if (appointment['services'] != null &&
              appointment['services'].isNotEmpty) {
            final serviceDetails =
                await fetchServiceDetails(appointment['services'][0]);
            return {
              'appointment': appointment,
              'serviceDetails': serviceDetails,
            };
          }
          return {
            'appointment': appointment,
            'serviceDetails': {'name': 'Unknown Service', 'cost': 'No Cost'},
          };
        }).toList();

        // Wait for all service details to be fetched in parallel
        final List<Map<String, dynamic>> appointmentsWithServices =
            await Future.wait(serviceFutures);

        // Sort appointments by date (newest first)
        appointmentsWithServices.sort((a, b) {
          final DateTime dateA = DateTime.parse(a['appointment']['date_time']);
          final DateTime dateB = DateTime.parse(b['appointment']['date_time']);
          return dateB.compareTo(dateA);
        });

        // Create request items with the fetched service details
        final List<RequestItem> requests = appointmentsWithServices.map((data) {
          final appointment = data['appointment'];
          final serviceDetails = data['serviceDetails'];
          final appointmentId = appointment['id'];
          final formattedDate = formatAppointmentDate(appointment['date_time']);

          return RequestItem(
            title: serviceDetails['name'],
            description:
                'Appointment on $formattedDate\nCost: ${serviceDetails['cost']}',
            imageUrl: 'assets/images/5132.png_860.png',
            status: appointment['status'],
            onAcceptPressed: () {
              updateAppointmentStatus(
                appointmentId,
                'confirmed',
                appointment['service_type'],
                appointment['date_time'],
                appointment['patient'],
                appointment['services']?.cast<int>() ?? [],
              );
            },
            onRejectPressed: () {
              updateAppointmentStatus(
                appointmentId,
                'cancelled',
                appointment['service_type'],
                appointment['date_time'],
                appointment['patient'],
                appointment['services']?.cast<int>() ?? [],
              );
            },
          );
        }).toList();

        setState(() {
          userRequests = requests;
          isLoading = false;
        });
      } else {
        print('Failed to load appointments: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('Error fetching appointments: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateAppointmentStatus(
    int appointmentId,
    String status,
    String serviceType,
    String dateTime,
    int patientId,
    List<int> services, {
    String? notes,
    String? appointmentAddress,
    bool isFollowUp = true,
    bool isConfirmed = true,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access') ?? '';
      final specificId = prefs.getInt('specificId');

      final url =
          Uri.parse('http://67.205.166.136/api/appointments/$appointmentId/');
      final response = await http.put(
        url,
        headers: {
          'accept': 'application/json; charset=utf-8',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "status": status,
          "service_type": serviceType,
          "date_time": dateTime,
          "patient": patientId,
          "doctor": null,
          "nurse": specificId, // Optional, pass null or appropriate ID
          "services": services, // List of service IDs
          "cost": null, // Optional, pass null if not required
          "notes": notes ?? "No notes provided", // Optional
          "appointment_address": appointmentAddress ?? "No address provided",
        }),
      );

      print(appointmentId);
      print(patientId);
      print(specificId);
      print(status);

      if (response.statusCode == 200) {
        print('Appointment updated successfully: ${response.body}');
        fetchAppointments(); // Refresh the appointments list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Appointment submit successful!",
                  style: TextStyle(color: Colors.green))),
        );
      } else {
        print(
            'Failed to update appointment: ${response.statusCode}, ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Faild to submit appointment",
                  style: TextStyle(color: Colors.green))),
        );
      }
    } catch (error) {
      print('Error updating appointment: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.teal,
            ))
          : userRequests.isEmpty
              ? const Center(child: Text('No appointments found'))
              : ListView.builder(
                  itemCount: userRequests.length,
                  itemBuilder: (context, index) {
                    final request = userRequests[index];

                    return GestureDetector(
                      onTap: () {
                        // You can navigate to a detailed screen if necessary
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16), // Reduced margins
                        child: Card(
                          color: Colors.white,
                          elevation: 4, // Reduced elevation for a flatter look
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              // Image Section with Circular Design and Shadow
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    request.imageUrl,
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              // Content Section with details
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title and Status Section in a Row
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            request.title,
                                            style: GoogleFonts.montserrat(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blueAccent,
                                            ),
                                            softWrap: true,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: request.status == 'confirmed'
                                                ? Colors.green
                                                : request.status == 'pending'
                                                    ? Colors.orange
                                                    : Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            request.status,
                                            style: GoogleFonts.montserrat(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Description Section
                                    Text(
                                      request.description,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Action Buttons (Accept/Reject)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (request.onAcceptPressed != null)
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.check),
                                        label: const Text('Accept'),
                                        onPressed: request.onAcceptPressed,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 12),
                                    if (request.onRejectPressed != null)
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.close),
                                        label: const Text('Reject'),
                                        onPressed: request.onRejectPressed,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                            vertical: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
