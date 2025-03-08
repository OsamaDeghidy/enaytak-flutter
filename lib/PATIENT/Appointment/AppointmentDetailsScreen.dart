import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import the intl package

class AppointmentDetailsScreen extends StatefulWidget {
  final int appointmentId;

  const AppointmentDetailsScreen({super.key, required this.appointmentId});

  @override
  _AppointmentDetailsScreenState createState() =>
      _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  late Map<String, dynamic> scheduleData;
  late Map<String, dynamic> serviceData; // To hold service details
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppointmentDetails();
  }

  Future<void> _fetchAppointmentDetails() async {
    final url =
        'http://67.205.166.136/api/appointments/${widget.appointmentId}';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'accept': 'application/json',
        'X-CSRFTOKEN':
            'XTUxdmxFdvqlHzXUKrrrT9itDG3fOvo6Ww12eySKI7gC7Kau4AtPu7Q84Z2cu2yF',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        scheduleData = json.decode(response.body);
        _fetchServiceDetails(
            scheduleData['services'][0]); // Fetch service details
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load appointment details')),
      );
    }
  }

  Future<void> _fetchServiceDetails(int serviceId) async {
    final url = 'http://67.205.166.136/api/services/$serviceId/';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'accept': 'application/json; charset=utf-8',
        'X-CSRFTOKEN':
            'XTUxdmxFdvqlHzXUKrrrT9itDG3fOvo6Ww12eySKI7gC7Kau4AtPu7Q84Z2cu2yF',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        serviceData = json.decode(utf8.decode(response.bodyBytes));
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load service details')),
      );
    }
  }

  // Helper function to format date
  String _formatDate(String dateTime) {
    try {
      final parsedDate = DateTime.parse(dateTime);
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Appointment Details'),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
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
            : SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Appointment Information Section
                    _buildSectionTitle('Appointment Info'),
                    _buildCardInfo(
                        'Appointment ID', scheduleData['id'].toString(),
                        icon: Icons.assignment),
                    _buildCardInfo(
                        'Day', _formatDate(scheduleData['date_time']),
                        icon: Icons.calendar_today),

                    const SizedBox(height: 24),

                    // Service Information Section
                    _buildSectionTitle('Service Info'),
                    _buildCardInfo('Service Name', serviceData['name'] ?? 'N/A',
                        icon: Icons.medical_services),
                    _buildCardInfo(
                        'Description', serviceData['description'] ?? 'N/A',
                        icon: Icons.description),
                    _buildCardInfo(
                        'Price', '\$${serviceData['price'] ?? '0.00'}',
                        icon: Icons.attach_money),
                    _buildCardInfo('Duration', serviceData['duration'] ?? 'N/A',
                        icon: Icons.timer),

                    // Service Image Section
                    if (serviceData.containsKey('image') &&
                        serviceData['image'] != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Service Image'),
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                serviceData['image'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Text(
                                        'Image not available',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 24),

                    // Provider Information Section
                    _buildSectionTitle('Provider Info'),
                    if (serviceData['provider_info'] != null &&
                        serviceData['provider_info'].isNotEmpty)
                      ...serviceData['provider_info'].map<Widget>((provider) {
                        return _buildCardInfo('Provider',
                            '${provider['name']} (${provider['type']})',
                            icon: Icons.person);
                      }).toList(),

                    const SizedBox(height: 24),

                    // Cancel Appointment Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () => _cancelAppointment(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 50),
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                        ),
                        child: const Text(
                          'Cancel Appointment',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    );
  }

  Widget _buildCardInfo(String label, String info, {IconData? icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (icon != null)
            Icon(
              icon,
              color: Colors.teal,
              size: 24,
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _cancelAppointment(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Appointment'),
          content:
              const Text('Are you sure you want to cancel this appointment?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Appointment Cancelled')),
                );
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
