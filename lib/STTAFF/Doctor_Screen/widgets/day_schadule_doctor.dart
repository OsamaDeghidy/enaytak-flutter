import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/STTAFF/Widgets/CustomButton.dart';

import 'schaduale_widget_doctor.dart';

class DayScheduleDoctor extends StatefulWidget {
  final String day;
  final List<Map<String, dynamic>> schedules;
  final Future<void> Function(String day, String startTime, String endTime)
      submitSchedule;

  const DayScheduleDoctor({
    super.key,
    required this.day,
    required this.schedules,
    required this.submitSchedule,
  });

  @override
  _DayScheduleDoctorState createState() => _DayScheduleDoctorState();
}

class _DayScheduleDoctorState extends State<DayScheduleDoctor> {
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
            return ScheduleWidgetDoctor(
              schedule: schedule,
              fromTimeController: fromTimeControllers[schedule['id']]!,
              toTimeController: toTimeControllers[schedule['id']]!,
            );
          }),
          if (widget.schedules.isEmpty)
            ScheduleWidgetDoctor(
              schedule: {'id': 'new_schedule', 'day_of_week': widget.day},
              fromTimeController: fromTimeControllers['new_schedule']!,
              toTimeController: toTimeControllers['new_schedule']!,
            ),
          const SizedBox(height: 50),
          CustomButton(
            text: "Submit",
            color: Colors.teal[600],
            onPressed: () {
              // Submit schedule for the day
              final startTime = fromTimeControllers['new_schedule']?.text ?? '';
              final endTime = toTimeControllers['new_schedule']?.text ?? '';
              widget.submitSchedule(widget.day, startTime, endTime);
            },
            height: 60,
            width: 250,
          ),
        ],
      ),
    );
  }
}
