import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Constant_Widgets/custom_AppBar.dart';
import 'package:flutter_sanar_proj/STTAFF/Doctor_Screen/staff_addService.dart';
import 'package:flutter_sanar_proj/constant.dart';
import 'package:flutter_sanar_proj/core/widgets/custom_gradiant_icon_widget.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_gradiant_text_widget.dart';
import '../../core/widgets/custom_netowrk_iamge.dart';

class StaffHomeScreen extends StatefulWidget {
  const StaffHomeScreen({super.key});

  @override
  _StaffHomeScreenState createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  Map<String, dynamic>? staffProfile;
  Map<String, dynamic>? userProfile;
  List<Map<String, dynamic>> upcomingAppointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStaffProfile();
    fetchConfirmedAppointments();
  }

  Future<void> fetchStaffProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access');
      final specificId = prefs.getInt('specificId');
      final userId = prefs.getInt('userId');

      // Fetch staff profile
      final staffResponse = await http.get(
        Uri.parse('http://67.205.166.136/api/doctors/$specificId/'),
        headers: {
          'accept': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      // Fetch user profile
      final userResponse = await http.get(
        Uri.parse('http://67.205.166.136/api/users/$userId/'),
        headers: {
          'accept': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (staffResponse.statusCode == 200 && userResponse.statusCode == 200) {
        setState(() {
          // Decode the response body using utf8.decode and then parse JSON
          staffProfile = json.decode(utf8.decode(staffResponse.bodyBytes));
          userProfile = json.decode(utf8.decode(userResponse.bodyBytes));
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load profiles');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchConfirmedAppointments() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access') ?? '';
    final specificId = prefs.getInt('specificId');

    final url =
        'http://67.205.166.136/api/doctors/$specificId/appointments/?page=1';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final results = List<Map<String, dynamic>>.from(data['results']);

        // Filter confirmed appointments and fetch service details
        final confirmedAppointments = results
            .where((appointment) => appointment['status'] == 'confirmed')
            .toList();

        // Fetch service details for each appointment
        final appointmentsWithServices = await Future.wait(
          confirmedAppointments.map((appointment) async {
            if (appointment['services'] != null &&
                appointment['services'].isNotEmpty) {
              final serviceDetails =
                  await fetchServiceDetails(appointment['services'][0]);
              if (serviceDetails != null) {
                appointment['serviceDetails'] = serviceDetails;
              }
            }
            return appointment;
          }),
        );

        // Sort by date (newest first)
        appointmentsWithServices.sort((a, b) {
          final dateA =
              DateTime.tryParse(a['date_time'] ?? '') ?? DateTime(1900);
          final dateB =
              DateTime.tryParse(b['date_time'] ?? '') ?? DateTime(1900);
          return dateB.compareTo(dateA);
        });

        setState(() {
          upcomingAppointments = appointmentsWithServices;
          isLoading = false;
        });
      } else {
        debugPrint('Error Response: ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> fetchServiceDetails(int serviceId) async {
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
        return json.decode(utf8.decode(response.bodyBytes));
      }
      return null;
    } catch (error) {
      print('Error fetching service details: $error');
      return null;
    }
  }

  String formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'No Date Time';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid Date';
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
              ),
            )
          : staffProfile == null
              ? const Center(
                  child: Text(
                    'Failed to load profile data.',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomGradiantTextWidget(
                                    text: userProfile?['full_name'] ??
                                        'Loading...',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    userProfile?['email'] ?? 'Loading...',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ClipOval(
                              child: staffProfile!['personal_photo'] != null
                                  ? Image.network(
                                      staffProfile!['personal_photo'],
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.1,
                                      width:
                                          MediaQuery.of(context).size.height *
                                              0.1,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/images/capsules.png',
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.1,
                                      width:
                                          MediaQuery.of(context).size.height *
                                              0.1,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    // Add Service Button

                    // Center(
                    //   child: ElevatedButton.icon(
                    //     onPressed: () {
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (context) => const StaffAddservice()),
                    //       );
                    //     },
                    //     icon: const Icon(Icons.add, color: Colors.black),
                    //     label: const Text(
                    //       'Add Service',
                    //       style: TextStyle(color: Colors.black),
                    //     ),
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: Colors.teal,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(12),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: CustomGradiantTextWidget(
                        text: 'Upcoming Appointments',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (isLoading)
                      Expanded(
                        child: ListView.builder(
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                elevation: 4,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(
                                      color: Colors.teal, width: 1),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  title: Container(
                                    width: double.infinity,
                                    height: 16.0,
                                    color: Colors.white,
                                  ),
                                  subtitle: Container(
                                    width: double.infinity,
                                    height: 14.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else if (upcomingAppointments.isEmpty)
                      const Center(
                        child: Text('No upcoming confirmed appointments.'),
                      )
                    else
                      Expanded(
                        child: AnimatedList(
                          initialItemCount: upcomingAppointments.length,
                          itemBuilder: (context, index, animation) {
                            final appointment = upcomingAppointments[index];
                            final serviceDetails =
                                appointment['serviceDetails'];
                            return SlideTransition(
                              position: animation.drive(
                                Tween<Offset>(
                                  begin: const Offset(1, 0),
                                  end: Offset.zero,
                                ).chain(CurveTween(curve: Curves.easeInOut)),
                              ),
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                elevation: 4,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(
                                      color: Constant.primaryColor, width: 1),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // Service Image
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CustomNetworkImage(
                                          imageUrl:
                                              serviceDetails['image'] ?? '',
                                          width: 80,
                                          height: 80,
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
                                            CustomGradiantTextWidget(
                                              text: serviceDetails?['name'] ??
                                                  'Unknown Service',
                                              fontSize:
                                                  18, // Adjust the font size as needed
                                              fontWeight: FontWeight.bold,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Date: ${formatDateTime(appointment['date_time'])}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            if (serviceDetails != null)
                                              CustomGradiantTextWidget(
                                                text:
                                                    'Price:  ${serviceDetails['price']} ${Constant.currency}',
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const CustomGradiantIconWidget(
                                            icon: Icons.arrow_forward,
                                            iconSize: 20),
                                        onPressed: () {
                                          // Navigate to appointment details if needed
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
      floatingActionButton: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
        child: CustomButtonNew(
          title: 'Add Service',
          isBackgroundPrimary: true,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StaffAddservice()),
            );
          },
          isLoading: false,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
