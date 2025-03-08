import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Screens/HomeScreen.dart';
// import 'package:flutter_sanar_proj/PATIENT/Screens/MedicalDiagnosisPage.dart';
import 'package:flutter_sanar_proj/PATIENT/Screens/MedicalRecordPage.dart';
import 'package:flutter_sanar_proj/PATIENT/Screens/SchedulePage.dart';
import 'package:flutter_sanar_proj/PATIENT/Screens/SettingPage.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Active tab index

  // List of screens to navigate between
  final List<Widget> _pages = [
    HomePage(),
    const SchedulePage(),
    MedicalRecordPage(),
    // const MedicalDiagnosisPage(),
    const SettingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Show the current active page
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0782BA),
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
            icon: Icon(Icons.schedule),
            label: 'Schedule',
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
