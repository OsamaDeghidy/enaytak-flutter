import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_sanar_proj/PATIENT/Services/ServiceDetailScreen.dart';

class SubcategoryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> subcategoryIds;

  const SubcategoryScreen({
    Key? key,
    required this.subcategoryIds,
  }) : super(key: key);

  @override
  _SubcategoryScreenState createState() => _SubcategoryScreenState();
}

class _SubcategoryScreenState extends State<SubcategoryScreen> {
  // Map to store services for each subcategory
  final Map<int, List<Map<String, dynamic>>> _subcategoryServices = {};

  // Function to fetch services for a subcategory
  Future<void> _fetchServicesForSubcategory(int subcategoryId) async {
    final url =
        'http://67.205.166.136/api/subcategories/$subcategoryId/services/';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json; charset=utf-8',
          'X-CSRFTOKEN':
              'xWYBZFmSppuNADKiZ6nIXEn31ONoIDfVKsl6d5ZDEKO3pHp5KbV3SeXYSZ53x4xN',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final services = List<Map<String, dynamic>>.from(data['results']);
        setState(() {
          _subcategoryServices[subcategoryId] = services;
        });
      } else {
        throw Exception(
            'Failed to load services for subcategory $subcategoryId');
      }
    } catch (e) {
      print('Error fetching services: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch services for each subcategory when the screen loads
    for (var subcategory in widget.subcategoryIds) {
      _fetchServicesForSubcategory(subcategory['id']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Subcategory Screen'),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display each subcategory
              for (var subcategory in widget.subcategoryIds) ...[
                Text(
                  subcategory['name'],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                // Display services for the current subcategory
                _buildServiceList(subcategory['id']),
                SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceList(int subcategoryId) {
    final services = _subcategoryServices[subcategoryId];

    // If services are still loading, show a loading indicator
    if (services == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    // If no services are found, display a message
    if (services.isEmpty) {
      return Text(
        'No services available for this subcategory.',
        style: TextStyle(color: Colors.grey),
      );
    }

    // Display the services in a horizontal list
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return GestureDetector(
            onTap: () {
              // Navigate to ServiceDetailScreen with the service ID
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceDetailScreen(
                    serviceId: service['id'],
                  ),
                ),
              );
            },
            child: ServiceItem(
              photo: service['image'] ?? 'https://via.placeholder.com/150',
              name: service['name'],
              price: service['price'],
            ),
          );
        },
      ),
    );
  }
}

class ServiceItem extends StatelessWidget {
  final String photo;
  final String name;
  final dynamic price;

  const ServiceItem({
    Key? key,
    required this.photo,
    required this.name,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert price to double if it's a string
    double displayPrice = price is String ? double.parse(price) : price;

    return Container(
      width: 150,
      margin: EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              photo,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 120,
            ),
          ),
          SizedBox(height: 8),
          // Service Name
          Text(
            name,
            style: TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          // Service Price
          Text(
            "\$${displayPrice.toStringAsFixed(2)}",
            style: TextStyle(color: Colors.teal),
          ),
        ],
      ),
    );
  }
}
