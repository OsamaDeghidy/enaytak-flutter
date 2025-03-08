import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/STTAFF/Nurse_Screen/staff_Nurse_Appointment.dart';
import 'package:flutter_sanar_proj/STTAFF/Nurse_Screen/staff_Nurse_HomeScreen.dart';
import 'package:flutter_sanar_proj/STTAFF/Nurse_Screen/staff_Nurse_Profile.dart';
import 'package:flutter_sanar_proj/STTAFF/Nurse_Screen/staff_Nurse_Requests.dart';
import 'package:flutter_sanar_proj/STTAFF/Nurse_Screen/staff_Nurse_Schadualing.dart';

class StaffNurseMainScreen extends StatefulWidget {
  const StaffNurseMainScreen({super.key});

  @override
  State<StaffNurseMainScreen> createState() => _StaffNurseMainScreenState();
}

class _StaffNurseMainScreenState extends State<StaffNurseMainScreen> {
  int _currentIndex = 0; // Active tab index

  // List of screens to navigate between
  final List<Widget> _pages = [
    const Staff_Nurse_HomeScreen(),
    Staff_Nurse_RequestScreen(),
    const Staff_Nurse_AppointmentScreen(),
    const Staff_Nurse_ScheduleScreen(),
    const Staff_Nurse_ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Show the current active page
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.teal,
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
