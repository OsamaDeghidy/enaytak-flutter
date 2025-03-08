import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Constant_Widgets/custom_AppBar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Staff_Nurse_ScheduleSubmited extends StatefulWidget {
  const Staff_Nurse_ScheduleSubmited({super.key});

  @override
  _Staff_Nurse_ScheduleSubmitedState createState() => _Staff_Nurse_ScheduleSubmitedState();
}

class _Staff_Nurse_ScheduleSubmitedState extends State<Staff_Nurse_ScheduleSubmited>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: daysOfWeek.length, vsync: this);
    _fetchSchedules(); // Fetch schedules on initialization
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;

    final url = Uri.parse(
        'http://67.205.166.136/api/users/$userId/availabilities/?page=1');
    final headers = {
      'accept': 'application/json',
      'X-CSRFTOKEN':
          'jbdNyNMlKuAY8qjTLSCmKsJy4GQsoxxfiOkizZ7qf6qfyBwt51EKlqhdvZPp44HO',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        // Populate schedulesByDay
        schedulesByDay.forEach((key, value) {
          schedulesByDay[key]!.clear();
        });

        for (var schedule in results) {
          final day = schedule['day_of_week'].toString();
          if (schedulesByDay.containsKey(day)) {
            schedulesByDay[day]!.add(schedule);
          }
        }

        setState(() {
          isLoading = false; // Stop loading
        });
      } else {
        print('Failed to load schedules: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching schedules: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50], // Soft background color
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal, Colors.cyan],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                indicator: BoxDecoration(
                  color: Colors.teal[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                tabs: daysOfWeek.map((day) {
                  return Center(child: Text(day));
                }).toList(),
              ),
            ),
          ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.teal[300],
                  ),
                )
              : Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: daysOfWeek.map((day) {
                      final daySchedules =
                          schedulesByDay[day.toLowerCase()] ?? [];
                      return daySchedules.isEmpty
                          ? Center(
                              child: Text("No schedules available for $day"))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              itemCount: daySchedules.length,
                              itemBuilder: (context, index) {
                                final schedule = daySchedules[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Time: ${schedule['start_time']} - ${schedule['end_time']}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Notes: ${schedule['notes'] ?? 'No notes available'}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                    }).toList(),
                  ),
                ),
        ],
      ),
    );
  }
}
