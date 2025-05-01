import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Constant_Widgets/custom_AppBar.dart';
import 'package:flutter_sanar_proj/STTAFF/HOSPITAL/Hospital_user_profile.dart';
import 'package:flutter_sanar_proj/STTAFF/LAB/lab_user_profile.dart';
import 'package:flutter_sanar_proj/core/helper/app_helper.dart';
import 'package:flutter_sanar_proj/core/widgets/custom_gradiant_icon_widget.dart';
import 'package:flutter_sanar_proj/core/widgets/custom_gradiant_text_widget.dart';
import 'package:flutter_sanar_proj/core/widgets/custom_netowrk_iamge.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String? token;
  int? userId;
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('access');
    userId = prefs.getInt('userId');

    if (userId != null) {
      await _fetchUserData(userId!);
    }
  }

  Future<void> _fetchUserData(int userId) async {
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
        debugPrint('Failed to fetch user data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access');
    await prefs.remove('userId');
    AppHelper.successSnackBar(
        context: context, message: "Logged out successfully");
    Navigator.pushReplacementNamed(context, '/Login_Signup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Profile Section
            _buildCard(
              child: GestureDetector(
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final userType = prefs.getString('user_type');

                  if (userType == 'hospital') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HospitalUserProfile()),
                    );
                  } else if (userType == 'lab') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LabUserProfile()),
                    );
                  } else {
                    Navigator.pushNamed(context, '/UserProfileScreen');
                  }
                },
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Container(
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: CustomNetworkImage(
                            imageUrl: userData['profile_image'] ?? '',
                            height: 60,
                            width: 60,
                          ),
                        )),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomGradiantTextWidget(
                            text: userData['full_name'] ?? 'No Name',
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                        const SizedBox(height: 4),
                        Text(
                          userData['email'] ?? 'No Email',
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios, size: 20),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Language Selection Section
            _buildCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      CustomGradiantIconWidget(
                          icon: Icons.language, iconSize: 24),
                      SizedBox(width: 10),
                      CustomGradiantTextWidget(
                          text: 'Language',
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ],
                  ),
                  DropdownButton<String>(
                    value: 'English',
                    items: <String>['English', 'Arabic']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      debugPrint('Selected language: $newValue');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // More Section
            _buildSectionCard(
              title: 'More',
              children: [
                _buildListTile(
                    icon: Icons.info_outline, title: 'About', route: '/about'),
                _buildListTile(
                    icon: Icons.description,
                    title: 'Terms and Conditions',
                    route: '/terms'),
                _buildListTile(
                    icon: Icons.privacy_tip,
                    title: 'Privacy Policy',
                    route: '/privacy'),
              ],
            ),

            const SizedBox(height: 16),

            // Work with Us Section
            _buildSectionCard(
              title: 'Work with Us',
              children: [
                _buildListTile(
                    icon: Icons.work_outline,
                    title: 'Join Us',
                    route: '/StaffSelectionScreen'),
              ],
            ),

            const SizedBox(height: 16),

            // Contact Section
            _buildSectionCard(
              title: 'Contact',
              children: [
                _buildListTile(
                    icon: Icons.contact_mail,
                    title: 'Contact Us',
                    route: '/contact'),
                _buildListTile(
                    icon: Icons.thumb_up,
                    title: 'Social Media',
                    route: '/socialMedia'),
              ],
            ),

            const SizedBox(height: 16),

            // Logout Section
            _buildCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.red),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: Colors.red,
                ),
                onTap: logout,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomGradiantTextWidget(
              text: title, fontSize: 18, fontWeight: FontWeight.bold),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CustomGradiantIconWidget(icon: icon),
      title: CustomGradiantTextWidget(
          text: title, fontSize: 16, fontWeight: FontWeight.w500),
      trailing: const Icon(Icons.arrow_forward_ios, size: 20),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }
}
