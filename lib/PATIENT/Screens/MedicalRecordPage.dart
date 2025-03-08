import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_sanar_proj/PATIENT/Widgets/Constant_Widgets/custom_AppBar.dart';
import 'package:flutter_sanar_proj/PATIENT/Screens/MedicalRecordDetails.dart';
import 'package:flutter_sanar_proj/STTAFF/HOSPITAL/MedicalReports.dart';

class MedicalRecordPage extends StatefulWidget {
  const MedicalRecordPage({super.key});

  @override
  _MedicalRecordPageState createState() => _MedicalRecordPageState();
}

class _MedicalRecordPageState extends State<MedicalRecordPage> {
  List<dynamic> categories = [];
  bool isLoading = true;

  // Mapping of category names to icons
  final Map<String, IconData> categoryIcons = {
    'doctors': Icons.medical_services,
    'nurse': Icons.medical_services_outlined,
    'lab': Icons.science,
    'hosptail': Icons.local_hospital,
    'عيون': Icons.remove_red_eye,
  };

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final response = await http.get(
      Uri.parse('http://67.205.166.136/api/service-categories/'),
      headers: {
        'accept': 'application/json; charset=utf-8',
        'X-CSRFTOKEN':
            '8MAzJuKaCGr0FYt7xi6uluQ0Q0Yi6uuCliX4XUnVR1Lgu28UinEPg4qVHbgXVVMu',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        categories = data['results'];
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load categories');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set the background color of the Scaffold to transparent

      appBar: const CustomAppBar(),
      body: Container(
        // Apply the gradient background here
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color.fromARGB(255, 190, 226, 223)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: categories.length +
                            1, // +1 for the "Medical Reports" button
                        itemBuilder: (context, index) {
                          if (index < categories.length) {
                            return _buildMedicalFileItem(
                                context, categories[index]);
                          } else {
                            return _buildMedicalReportsButton(context);
                          }
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicalFileItem(BuildContext context, dynamic category) {
    // Get the icon for the category name, or use a default icon if not found
    final IconData icon =
        categoryIcons[category['name']] ?? Icons.medical_services;

    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MedicalRecordDetails(
                itemName: category['name'] as String,
                categoryId: category['id'],
              ),
            ),
          );
        },
        splashColor: Colors.teal.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 126, 231, 220),
                    const Color.fromARGB(255, 76, 168, 175)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: Icon(
                icon, // Use the icon from the mapping
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              category['name'] as String,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalReportsButton(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MedicalReportsPage(),
            ),
          );
        },
        splashColor: Colors.teal.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 126, 231, 220),
                    const Color.fromARGB(255, 76, 168, 175)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.receipt_long,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Medical Reports',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
