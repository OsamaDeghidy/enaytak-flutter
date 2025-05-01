import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/core/widgets/custom_gradiant_icon_widget.dart';
import 'package:flutter_sanar_proj/core/widgets/custom_gradiant_text_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic> userData = {};
  String? token;
  int? userId;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('access');
    userId = prefs.getInt('userId');

    if (token == null || userId == null) {
      _showErrorSnackBar("No token or user ID found. Please login first.");
      return;
    }

    final String apiUrl = 'http://67.205.166.136/api/users/$userId/';

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'accept': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = json.decode(utf8.decode(response.bodyBytes));
        });
      } else {
        String errorMsg =
            'Error: Unable to fetch user data. Status code: ${response.statusCode}';
        _showErrorSnackBar(errorMsg);
      }
    } catch (e) {
      String errorMsg = 'Failed to load user data: $e';
      _showErrorSnackBar(errorMsg);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access');
    await prefs.remove('userId');

    Fluttertoast.showToast(
      msg: "Logged out successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.teal,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    Navigator.pushReplacementNamed(context, '/Login_Signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // Adds a back arrow
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black), // Back arrow color
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.teal.shade50],
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                _buildProfileHeader(),
                // const SizedBox(height: 20),
                // _buildHorizontalScrollSection(),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _buildInfoSection(
                          title: "Personal Information",
                          icon: Icons.person,
                          children: [
                            _buildInfoItem(
                                "Username", userData['username'] ?? 'N/A'),
                            _buildInfoItem(
                                "Birth Date", userData['birth_date'] ?? 'N/A'),
                            _buildInfoItem(
                                "Address", userData['address'] ?? 'N/A'),
                            _buildInfoItem(
                                "Gender", userData['gender'] ?? 'N/A'),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildInfoSection(
                          title: "Account Details",
                          icon: Icons.lock,
                          children: [
                            _buildInfoItem("Email", userData['email'] ?? 'N/A'),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Floating Logout Button
            // Positioned(
            //   bottom: 20,
            //   right: 20,
            //   child: FloatingActionButton(
            //     onPressed: logout,
            //     backgroundColor: Colors.teal,
            //     child: const Icon(Icons.logout, color: Colors.white),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: userData['profile_image'] != null
                ? NetworkImage(userData['profile_image'])
                : const AssetImage("assets/user_profile.jpg") as ImageProvider,
          ),
          const SizedBox(height: 10),
          CustomGradiantTextWidget(
              text: userData['full_name'] ?? "User Name",
              fontSize: 24,
              fontWeight: FontWeight.bold),
          const SizedBox(height: 5),
          CustomGradiantTextWidget(
              text: userData['email'] ?? "Email not available", fontSize: 14),
        ],
      ),
    );
  }

  // Widget _buildHorizontalScrollSection() {
  //   return SizedBox(
  //     height: 100,
  //     child: SingleChildScrollView(
  //       // scrollDirection: Axis.horizontal,
  //       padding: const EdgeInsets.symmetric(horizontal: 16),
  //       child: Row(
  //         children: [
  //           _buildInfoCard("Username", userData['username'] ?? 'N/A'),
  //           _buildInfoCard("Birth Date", userData['birth_date'] ?? 'N/A'),
  //           _buildInfoCard("Gender", userData['gender'] ?? 'N/A'),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildInfoCard(String title, String value) {
  //   return Container(
  //     width: 110,
  //     margin: const EdgeInsets.only(right: 10),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(15),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.1),
  //           blurRadius: 10,
  //           offset: const Offset(0, 5),
  //         ),
  //       ],
  //     ),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             title,
  //             style: const TextStyle(
  //               fontSize: 14,
  //               color: Colors.grey,
  //             ),
  //           ),
  //           const SizedBox(height: 5),
  //           Text(
  //             value,
  //             style: const TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.teal,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomGradiantIconWidget(icon: icon),
                const SizedBox(width: 8),
                CustomGradiantTextWidget(
                    text: title, fontSize: 18, fontWeight: FontWeight.bold),
              ],
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          CustomGradiantTextWidget(
              text: value, fontSize: 16, fontWeight: FontWeight.bold),
        ],
      ),
    );
  }
}
