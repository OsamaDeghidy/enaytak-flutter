import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:flutter_sanar_proj/PATIENT/Schadule_Details/booking_Doctor_appointment.dart';
// import 'package:flutter_sanar_proj/PATIENT/Schadule_Details/booking_Nurse_appointment.dart';
import 'package:flutter_sanar_proj/PATIENT/Screens/userDetails.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Colors/colors.dart';
import 'package:flutter_sanar_proj/STTAFF/HOSPITAL/booking_hospital.dart';
import 'package:flutter_sanar_proj/STTAFF/LAB/booking_lab.dart';
import 'package:http/http.dart' as http;

class ProviderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> service;

  const ProviderDetailsScreen({required this.service, Key? key})
      : super(key: key);

  @override
  _ProviderDetailsScreenState createState() => _ProviderDetailsScreenState();
}

class _ProviderDetailsScreenState extends State<ProviderDetailsScreen> {
  Map<String, dynamic>? _providerDetails;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProviderDetails();
  }

  // Fetch provider details based on the type and ID in provider_info
  Future<void> _fetchProviderDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if provider_info exists and is not empty
      if (widget.service['provider_info'] != null &&
          widget.service['provider_info'].isNotEmpty) {
        final providerInfo = widget.service['provider_info'][0];
        final providerType = providerInfo['type'];
        final providerId = providerInfo['id'];

        if (providerType == 'hospital') {
          await _fetchHospitalDetails(providerId);
        } else if (providerType == 'lab') {
          await _fetchLabDetails(providerId);
        }
      } else {
        print('No provider_info available in the service data.');
      }
    } catch (e) {
      print('Error fetching provider details: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fetch hospital details
  Future<void> _fetchHospitalDetails(int hospitalId) async {
    final response = await http
        .get(Uri.parse('http://67.205.166.136/api/hospitals/$hospitalId/'));
    if (response.statusCode == 200) {
      final hospital = json.decode(utf8.decode(response.bodyBytes));

      // Fetch user details for the hospital
      final userResponse = await http.get(
          Uri.parse('http://67.205.166.136/api/users/${hospital['user']}/'));
      if (userResponse.statusCode == 200) {
        final user = jsonDecode(userResponse.body);
        hospital['userDetails'] = user; // Add user details to hospital data
      }

      setState(() {
        _providerDetails = hospital;
      });
      // Display Arabic data
      if (_providerDetails != null &&
          _providerDetails!['arabicField'] != null) {
        final arabicText = Text(
          _providerDetails![
              'arabicField'], // Replace 'arabicField' with the actual field name
          textDirection: TextDirection.rtl,
          style: TextStyle(fontSize: 16),
        );
        // Add arabicText to your widget tree where you want it displayed
      }
    } else {
      print('Failed to fetch hospital details: ${response.statusCode}');
    }
  }

  // Fetch lab details
  Future<void> _fetchLabDetails(int labId) async {
    try {
      final url = Uri.parse('http://67.205.166.136/api/labs/$labId/');
      final response = await http.get(
        url,
        headers: {
          'accept': 'application/json; charset=utf-8',
          'X-CSRFTOKEN':
              'TBnER2Sd30Nom2fNH40WwVJoMEWWyJsEEZNB4sXomfYXdTJIHJ7zFRNXr4BtC0EN',
        },
      );

      if (response.statusCode == 200) {
        final lab = json.decode(utf8.decode(response.bodyBytes));

        // Fetch user details for the lab
        final userResponse = await http.get(
          Uri.parse('http://67.205.166.136/api/users/${lab['user']}/'),
          headers: {
            'accept': 'application/json; charset=utf-8',
          },
        );

        if (userResponse.statusCode == 200) {
          final user = jsonDecode(userResponse.body);
          lab['userDetails'] = user; // Add user details to lab data
        } else {
          print('Failed to fetch user details: ${userResponse.statusCode}');
          // Handle the error, e.g., show a message to the user
        }

        setState(() {
          _providerDetails = lab;
        });
      } else {
        print('Failed to fetch lab details: ${response.statusCode}');
        // Handle the error, e.g., show a message to the user
      }
    } catch (e) {
      print('An error occurred: $e');
      // Handle the error, e.g., show a message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service['name'] ?? 'Provider Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.service['image'] != null)
              Center(
                child: ClipOval(
                  child: Image.network(
                    widget.service['image'],
                    height: 120,
                    width: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(
                    Icons.image_not_supported,
                    size: 60,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Description
            Text(
              'Description: ${widget.service['description'] ?? 'No description available'}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.teal.shade700,
              ),
            ),
            const SizedBox(height: 16),

            // Price
            Text(
              'Price: ${widget.service['price'] ?? 'N/A'} SAR',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.teal.shade600,
              ),
            ),
            const SizedBox(height: 16),

            // Duration
            Text(
              'Duration: ${widget.service['duration'] ?? 'N/A'}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Status (active or not)
            Text(
              'Status: ${widget.service['is_active'] == true ? 'Active' : 'Inactive'}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: widget.service['is_active'] == true
                    ? Colors.green.shade600
                    : Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 16),

            // Show provider details if available
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              )
            else if (_providerDetails != null)
              _buildProviderDetails(_providerDetails!)
            else
              Center(
                child: Text(
                  'No provider details available.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderDetails(Map<String, dynamic> provider) {
    final user = provider['userDetails'] ?? {};
    final type = widget.service['provider_info'][0]['type'];
    final profileImageUrl = user['profile_image'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Provider Name
        Text(
          provider['name'] ?? 'No name available',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.teal.shade700,
          ),
        ),
        const SizedBox(height: 8),

        // Provider Type
        Text(
          'Type: ${type == 'hospital' ? 'Hospital' : 'Lab'}',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),

        // Avatar and User Details
        Row(
          children: [
            // Avatar
            profileImageUrl != null && profileImageUrl.isNotEmpty
                ? CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(profileImageUrl),
                  )
                : CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.teal,
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
            const SizedBox(width: 16),
            // User Details
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['full_name'] ?? 'No name available',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  user['email'] ?? 'No email available',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  user['phone_number'] ?? 'No phone number available',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // View Profile Button
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserDetailsScreen(
                  user: user,
                  provider: provider, // Pass the full provider details
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'View Profile',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Book Appointment Button
        GestureDetector(
          onTap: () {
            if (type == 'hospital') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScheduleHospitalScreen(
                    price: widget.service['price'],
                    userId: provider['user'],
                    hospitalId: provider['id'],
                    serviceId: widget.service['id'],
                  ),
                ),
              );
            } else if (type == 'lab') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScheduleLabScreen(
                    price: widget.service['price'],
                    userId: provider['user'],
                    labId: provider['id'],
                    serviceId: widget.service['id'],
                  ),
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Book Appointment',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
