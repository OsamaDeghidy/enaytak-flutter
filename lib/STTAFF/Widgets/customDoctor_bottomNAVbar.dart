import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/STTAFF/Doctor_Screen/staff_Appointment.dart';
import 'package:flutter_sanar_proj/STTAFF/Doctor_Screen/staff_HomeScreen.dart';
import 'package:flutter_sanar_proj/STTAFF/Doctor_Screen/staff_Profile.dart';
import 'package:flutter_sanar_proj/STTAFF/Doctor_Screen/staff_Requests.dart';
import 'package:flutter_sanar_proj/STTAFF/Doctor_Screen/staff_Schadualing.dart';
import 'package:flutter_sanar_proj/constant.dart';

class StaffMainScreen extends StatefulWidget {
  const StaffMainScreen({super.key});

  @override
  State<StaffMainScreen> createState() => _StaffMainScreenState();
}

class _StaffMainScreenState extends State<StaffMainScreen> {
  int _currentIndex = 0; // Active tab index

  // List of screens to navigate between
  final List<Widget> _pages = [
    const StaffHomeScreen(),
    const StaffRequestScreen(),
    const StaffAppointmentScreen(),
    const StaffScheduleScreen(),
    const StaffProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Show the current active page
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Constant.primaryColor,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update active tab index
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.request_page),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
