import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Constant_Widgets/custom_AppBar.dart';
import 'package:flutter_sanar_proj/STTAFF/Doctor_Screen/staff_SubmitedScadualing.dart';
import 'package:flutter_sanar_proj/STTAFF/Widgets/CustomButton.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'widgets/day_schadule_doctor.dart';

class StaffScheduleScreen extends StatefulWidget {
  const StaffScheduleScreen({super.key});

  @override
  _StaffScheduleScreenState createState() => _StaffScheduleScreenState();
}

class _StaffScheduleScreenState extends State<StaffScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> daysOfWeek = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday'
  ];

  Map<String, List<Map<String, dynamic>>> schedulesByDay = {
    'monday': [],
    'tuesday': [],
    'wednesday': [],
    'thursday': [],
    'friday': [],
    'saturday': [],
    'sunday': [],
  };
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: daysOfWeek.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _submitSchedule(
      String day, String startTime, String endTime) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access') ?? '';
    final userId = prefs.getInt('userId') ?? 0;

    final url = Uri.parse('http://67.205.166.136/api/availabilities/');

    final headers = {
      'accept': 'application/json',
      'Content-Type': 'application/json',
      'X-CSRFTOKEN':
          'CVsQx7PPZQPUwHN9Oy4Sj0EMxw8MjITVk8eZer4nWXxnenfYHW1JfZw3KI3QZLbI',
      'Authorization': 'Bearer $token'
    };

    final body = jsonEncode({
      'day_of_week': day,
      'start_time': startTime,
      'end_time': endTime,
      'max_patients_per_slot': 1,
      'notes': 'abc', // Optional
      'user': userId,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule submitted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to submit schedule. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(50),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black54,
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                indicator: BoxDecoration(
                  color: Colors.teal[600],
                  borderRadius: BorderRadius.circular(50),
                ),
                tabs: daysOfWeek
                    .map((day) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: Center(child: Text(day)),
                        ))
                    .toList(),
                indicatorSize: TabBarIndicatorSize.tab,
                padding: EdgeInsets.zero,
                indicatorPadding: EdgeInsets.zero,
                dividerColor: Colors.transparent,
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: daysOfWeek.map((day) {
                var daySchedules = schedulesByDay[day] ?? [];
                return DayScheduleDoctor(
                  day: day,
                  schedules: daySchedules.isEmpty
                      ? [
                          {
                            'id': 'new_schedule',
                            'start_time': '',
                            'end_time': ''
                          }
                        ]
                      : daySchedules,
                  submitSchedule: _submitSchedule,
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: CustomButton(
              text: "View Submitted Schedules", // Button text
              color: Colors.teal[600],
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const StaffScheduleSubmited()), // Navigate to the submitted scheduling screen
                );
              },
              height: 60,
              width: 250,
            ),
          ),
        ],
      ),
    );
  }
}
