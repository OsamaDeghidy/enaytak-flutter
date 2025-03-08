import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'FilteredListScreen.dart'; // Import the FilteredListScreen

class ServiceDetailScreen extends StatelessWidget {
  final int serviceId; // Service ID to fetch details

  const ServiceDetailScreen({Key? key, required this.serviceId})
      : super(key: key);

  Future<Map<String, dynamic>> fetchServiceDetails() async {
    final url = Uri.parse(
        'http://67.205.166.136/api/services/$serviceId/'); // Adjust the URL as needed
    final response =
        await http.get(url, headers: {'accept': 'application/json'});

    if (response.statusCode == 200) {
      // Save the service ID in SharedPreferences
      await saveServiceId(serviceId);
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
              child: Center(child: CircularProgressIndicator()),
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
            appBar: AppBar(
              title: Text(
                serviceDetails['name_ar'] ??
                    serviceDetails['name'] ??
                    'Service Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade900,
                ),
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
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service Image with Shadow
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.2),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Image.network(
                            serviceDetails['image'] ??
                                'https://via.placeholder.com/150',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 250,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Service Name with Divider
                      Text(
                        serviceDetails['name_ar'] ??
                            serviceDetails['name'] ??
                            'Service Name',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade900,
                        ),
                      ),
                      Divider(
                        color: Colors.teal.shade200,
                        thickness: 1,
                        height: 20,
                      ),
                      SizedBox(height: 10),

                      // Price and Duration in a Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Price
                          Row(
                            children: [
                              Icon(Icons.attach_money,
                                  size: 28, color: Colors.teal.shade800),
                              SizedBox(width: 5),
                              Text(
                                "\$${price.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade700,
                                ),
                              ),
                            ],
                          ),

                          // Duration
                          Row(
                            children: [
                              Icon(Icons.timer,
                                  size: 28, color: Colors.teal.shade800),
                              SizedBox(width: 5),
                              Text(
                                "${serviceDetails['duration'] ?? 'N/A'} mins",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Description Section
                      Text(
                        "About the Service",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade900,
                        ),
                      ),
                      SizedBox(height: 10),
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
                      SizedBox(height: 20),

                      // Book Service Button
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FilteredListScreen(serviceId: serviceId),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            'Book Service',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
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
