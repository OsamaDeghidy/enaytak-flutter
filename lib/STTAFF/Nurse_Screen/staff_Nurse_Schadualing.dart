import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Constant_Widgets/custom_AppBar.dart';
import 'package:flutter_sanar_proj/STTAFF/Doctor_Screen/staff_SubmitedScadualing.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant.dart';
import '../../core/helper/app_helper.dart';
import '../../core/widgets/custom_button.dart';

class StaffNurseScheduleScreen extends StatefulWidget {
  const StaffNurseScheduleScreen({super.key});

  @override
  _StaffNurseScheduleScreenState createState() =>
      _StaffNurseScheduleScreenState();
}

class _StaffNurseScheduleScreenState extends State<StaffNurseScheduleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isSubmittingLoading = false;
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
    setState(() {
      isSubmittingLoading = true;
    });
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
        AppHelper.successSnackBar(
            context: context, message: 'Schedule submitted successfully!');
      } else {
        AppHelper.errorSnackBar(
            context: context,
            message: 'Failed to submit schedule. Please try again.');
      }
    } catch (e) {
      AppHelper.errorSnackBar(
          context: context, message: 'An error occurred. Please try again.');
    }
    setState(() {
      isSubmittingLoading = false;
    });
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
                  gradient: const LinearGradient(
                      colors: Constant.gradientPrimaryColors,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter),
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
                return DaySchedule(
                  isSubmitting: isSubmittingLoading,
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
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 36),
            child: CustomButtonNew(
              title: "View Submitted Schedules", // Button text
              isLoading: isLoading,
              isBackgroundPrimary: true,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const StaffScheduleSubmited()), // Navigate to the submitted scheduling screen
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DaySchedule extends StatefulWidget {
  final String day;
  final List<Map<String, dynamic>> schedules;
  final Future<void> Function(String day, String startTime, String endTime)
      submitSchedule;
  final bool isSubmitting;

  const DaySchedule({
    super.key,
    required this.day,
    required this.schedules,
    required this.submitSchedule,
    required this.isSubmitting,
  });

  @override
  _DayScheduleState createState() => _DayScheduleState();
}

class _DayScheduleState extends State<DaySchedule> {
  late Map<String, TextEditingController> fromTimeControllers;
  late Map<String, TextEditingController> toTimeControllers;

  @override
  void initState() {
    super.initState();
    fromTimeControllers = {};
    toTimeControllers = {};

    // Initialize text controllers for each schedule
    for (var schedule in widget.schedules) {
      fromTimeControllers[schedule['id']] =
          TextEditingController(text: schedule['start_time']);
      toTimeControllers[schedule['id']] =
          TextEditingController(text: schedule['end_time']);
    }

    // Initialize controllers for days with no schedule, allowing user to add time
    if (widget.schedules.isEmpty) {
      fromTimeControllers['new_schedule'] = TextEditingController();
      toTimeControllers['new_schedule'] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in fromTimeControllers.values) {
      controller.dispose();
    }
    for (var controller in toTimeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          const SizedBox(height: 20),
          ...widget.schedules.map((schedule) {
            return ScheduleWidget(
              schedule: schedule,
              fromTimeController: fromTimeControllers[schedule['id']]!,
              toTimeController: toTimeControllers[schedule['id']]!,
            );
          }),
          if (widget.schedules.isEmpty)
            ScheduleWidget(
              schedule: {'id': 'new_schedule', 'day_of_week': widget.day},
              fromTimeController: fromTimeControllers['new_schedule']!,
              toTimeController: toTimeControllers['new_schedule']!,
            ),
          const SizedBox(height: 50),
          CustomButtonNew(
            width: 250,
            height: 50,
            title: "Submit",
            isLoading: widget.isSubmitting,
            isBackgroundPrimary: true,
            onPressed: () {
              // Submit schedule for the day
              final startTime = fromTimeControllers['new_schedule']?.text ?? '';
              final endTime = toTimeControllers['new_schedule']?.text ?? '';
              widget.submitSchedule(widget.day, startTime, endTime);
            },
          ),
          // CustomButton(
          //   text: "Submit",
          //   color: const Color.fromARGB(255, 3, 190, 150),
          //   onPressed: () {
          //     // Submit schedule for the day
          //     final startTime = fromTimeControllers['new_schedule']?.text ?? '';
          //     final endTime = toTimeControllers['new_schedule']?.text ?? '';
          //     widget.submitSchedule(widget.day, startTime, endTime);
          //   },
          //   height: 60,
          //   width: 250,
          // ),
        ],
      ),
    );
  }
}

class ScheduleWidget extends StatelessWidget {
  final Map<String, dynamic> schedule;
  final TextEditingController fromTimeController;
  final TextEditingController toTimeController;

  const ScheduleWidget({
    super.key,
    required this.schedule,
    required this.fromTimeController,
    required this.toTimeController,
  });

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    // Show the time picker
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Constant.primaryColor, // Header color
            colorScheme:
                const ColorScheme.light(primary: Constant.primaryColor),
          ),
          child: child!,
        );
      },
    );

    // If a time was picked
    if (picked != null) {
      // Format the selected time as HH:mm:ss (24-hour format with seconds)
      final now = DateTime.now();
      final selectedTime =
          DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      controller.text = DateFormat('HH:mm:ss').format(selectedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _selectTime(context, fromTimeController),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: fromTimeController,
                  decoration: InputDecoration(
                    labelText: 'Start Time',
                    hintText: 'HH:mm:ss',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter start time';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: GestureDetector(
              onTap: () => _selectTime(context, toTimeController),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: toTimeController,
                  decoration: InputDecoration(
                    labelText: 'End Time',
                    hintText: 'HH:mm:ss',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter end time';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
