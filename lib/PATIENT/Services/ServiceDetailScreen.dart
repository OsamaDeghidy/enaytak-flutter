import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Services/doctor_detail_service.dart';
import 'package:flutter_sanar_proj/PATIENT/Services/nurse_detail_service.dart';
import 'package:flutter_sanar_proj/constant.dart';
import 'package:flutter_sanar_proj/core/widgets/custom_button.dart';
import 'package:flutter_sanar_proj/core/widgets/custom_gradiant_icon_widget.dart';
import 'package:flutter_sanar_proj/core/widgets/custom_gradiant_text_widget.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../STTAFF/HOSPITAL/ProviderDetailsScreen.dart';
import '../../core/widgets/custom_netowrk_iamge.dart';
import 'FilteredListScreen.dart'; // Import the FilteredListScreen

class ServiceDetailScreen extends StatefulWidget {
  final int serviceId; // Service ID to fetch details

  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  List<Map<String, dynamic>> providers =
      []; // Unified list for doctors and nurses
  Map<String, dynamic>? serviceData; // Store the entire service data
  Future<Map<String, dynamic>> fetchServiceDetails() async {
    final url = Uri.parse(
        'http://67.205.166.136/api/services/${widget.serviceId}/'); // Adjust the URL as needed
    final response =
        await http.get(url, headers: {'accept': 'application/json'});

    if (response.statusCode == 200) {
      // Save the service ID in SharedPreferences
      await saveServiceId(widget.serviceId);
      final data = json.decode(response.body);
      serviceData = data; // Store the entire service data
      providers = List<Map<String, dynamic>>.from(data['provider_info']);
      return json.decode(utf8.decode(response.bodyBytes)); // Decode with UTF-8
    } else {
      throw Exception('Failed to load service details');
    }
  }

  Future<void> saveServiceId(int serviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('serviceIId', serviceId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchServiceDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.teal.shade50],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Colors.teal.shade50],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(child: Text('Error: ${snapshot.error}')),
            ),
          );
        } else {
          final serviceDetails = snapshot.data!;
          double price = (serviceDetails['price'] is String)
              ? double.parse(serviceDetails['price'])
              : (serviceDetails['price'] ?? 0.0);

          return Scaffold(
            bottomNavigationBar: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 20, vertical: 20),
              child: CustomButtonNew(
                  title: 'Book Service',
                  isLoading: false,
                  isBackgroundPrimary: true,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FilteredListScreen(
                          serviceId: widget.serviceId,
                          servicePrice: price.toStringAsFixed(2),
                        ),
                      ),
                    );
                  }),
            ),
            appBar: AppBar(
              title: CustomGradiantTextWidget(
                text: serviceDetails['name_ar'] ??
                    serviceDetails['name'] ??
                    'Service Details',
                fontSize: 22,
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.teal.shade900),
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service Image with Shadow
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Constant.primaryColor.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: CustomNetworkImage(
                            imageUrl: serviceDetails['image'] ?? '',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 250,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Service Name with Divider
                      CustomGradiantTextWidget(
                        text: serviceDetails['name_ar'] ??
                            serviceDetails['name'] ??
                            'Service Name',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      const Divider(
                        color: Constant.primaryColor,
                        thickness: 1,
                        height: 20,
                      ),
                      const SizedBox(height: 10),

                      // Price and Duration in a Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Price
                          CustomGradiantTextWidget(
                            text:
                                "${price.toStringAsFixed(2)} ${Constant.currency}",
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),

                          // Duration
                          Row(
                            children: [
                              const CustomGradiantIconWidget(
                                  icon: Icons.timer, iconSize: 28),
                              const SizedBox(width: 5),
                              CustomGradiantTextWidget(
                                text:
                                    "${serviceDetails['duration'] ?? 'N/A'} mins",
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Description Section
                      const CustomGradiantTextWidget(
                        text: "About the Service",
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 10),

                      Text(
                        serviceDetails['description_ar'] ??
                            serviceDetails['description'] ??
                            'No description available',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.grey.shade800,
                        ),
                        textDirection: TextDirection
                            .rtl, // Set text direction to RTL for Arabic
                      ),
                      const SizedBox(height: 16),
                      const CustomGradiantTextWidget(
                        text: "Providers",
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
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
                                  child: CustomNetworkImage(
                                      imageUrl:
                                          provider['personal_photo'] ?? '',
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover),
                                ),
                                title: CustomGradiantTextWidget(
                                  text: provider['name'] ?? 'Unknown',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                subtitle: Text(
                                  "Type: ${provider['type'] ?? 'N/A'}",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                trailing: SizedBox(
                                  width: 150,
                                  height: 50,
                                  child: CustomButtonNew(
                                    title: "View Profile",
                                    isLoading: false,
                                    isBackgroundPrimary: true,
                                    onPressed: () {
                                      // Navigate based on the type
                                      if (provider['type'] == 'nurse') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                NurseDetailServiceScreen(
                                              nurse:
                                                  provider, // Pass the nurse data
                                            ),
                                          ),
                                        );
                                      } else if (provider['type'] ==
                                              'hospital' ||
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
                                              servicePrice:
                                                  price.toStringAsFixed(2),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                )),
                          );
                        },
                      ),

                      // Book Service Button
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
