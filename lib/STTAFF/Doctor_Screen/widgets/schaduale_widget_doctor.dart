import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleWidgetDoctor extends StatelessWidget {
  final Map<String, dynamic> schedule;
  final TextEditingController fromTimeController;
  final TextEditingController toTimeController;

  const ScheduleWidgetDoctor({
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
            primaryColor:
                const Color.fromARGB(255, 3, 190, 150), // Header color
            colorScheme: const ColorScheme.light(
                primary: Color.fromARGB(255, 3, 190, 150)),
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
