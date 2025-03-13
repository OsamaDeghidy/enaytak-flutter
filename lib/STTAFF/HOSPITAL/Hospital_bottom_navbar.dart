import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Screens/HomeScreen.dart';
import 'package:flutter_sanar_proj/PATIENT/Screens/SettingPage.dart';
import 'package:flutter_sanar_proj/PATIENT/Screens/medical_diagnosis_page.dart';
import 'package:flutter_sanar_proj/STTAFF/HOSPITAL/appointment_screen.dart';

class HospitalMainScreen extends StatefulWidget {
  const HospitalMainScreen({super.key});

  @override
  State<HospitalMainScreen> createState() => _HospitalMainScreenState();
}

class _HospitalMainScreenState extends State<HospitalMainScreen> {
  int _currentIndex = 0; // Active tab index

  // List of screens to navigate between
  final List<Widget> _pages = [
    const HomePage(),
/*     const SchedulePage(),
 */
    const AppointmentPage(),
    const MedicalDiagnosisPage(),
    const SettingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
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
          /*  BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ), */
          BottomNavigationBarItem(
            icon: Icon(Icons.time_to_leave),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Medical File',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
