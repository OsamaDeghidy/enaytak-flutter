import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add intl package for formatting
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AddAvailabilityScreen extends StatefulWidget {
  @override
  _AddAvailabilityScreenState createState() => _AddAvailabilityScreenState();
}

class _AddAvailabilityScreenState extends State<AddAvailabilityScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _maxPatientsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  int? userId;
  String? token;

  void _pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      // Disable all past dates
      selectableDayPredicate: (DateTime date) {
        return date.isAfter(DateTime.now().subtract(Duration(days: 1)));
      },
    );
    if (pickedDate != null) {
      setState(() {
        _dayController.text = DateFormat('EEEE').format(pickedDate);
      });
    }
  }

  String formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final formattedTime = DateFormat('HH:mm')
        .format(DateTime(now.year, now.month, now.day, time.hour, time.minute));
    return formattedTime;
  }

  void _pickTime(TextEditingController controller) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        controller.text = formatTime(pickedTime);
      });
    }
  }

  Future<void> _submitAvailability() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('access');
    userId = prefs.getInt('userId');

    if (_formKey.currentState!.validate()) {
      final dayOfWeekMap = {
        'Monday': 1,
        'Tuesday': 2,
        'Wednesday': 3,
        'Thursday': 4,
        'Friday': 5,
        'Saturday': 6,
        'Sunday': 7,
      };

      final dayOfWeek = dayOfWeekMap[_dayController.text] ?? 1;

      final body = {
        "day_of_week": _dayController.text.toLowerCase(),
        "start_time": _startTimeController.text,
        "end_time": _endTimeController.text,
        "max_patients_per_slot": int.tryParse(_maxPatientsController.text) ?? 1,
        "notes": _notesController.text.isEmpty ? null : _notesController.text,
        "user": userId,
      };

      final String apiUrl = 'http://67.205.166.136/api/availabilities/';
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'accept': 'application/json',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Availability added successfully')),
          );
          Navigator.pop(context);
        } else {
          print(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add availability')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Availability'),
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day of Week Field
              TextFormField(
                controller: _dayController,
                decoration: InputDecoration(
                  labelText: 'Day of Week',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _pickDate(context),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.teal, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.teal, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
                readOnly: true,
                validator: (value) =>
                    value!.isEmpty ? 'Please select a day' : null,
              ),
              const SizedBox(height: 16),

              // Start Time Field
              TextFormField(
                controller: _startTimeController,
                decoration: InputDecoration(
                  labelText: 'Start Time',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () => _pickTime(_startTimeController),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.teal, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.teal, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
                readOnly: true,
                validator: (value) =>
                    value!.isEmpty ? 'Please select a start time' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _endTimeController,
                decoration: InputDecoration(
                  labelText: 'End Time',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () => _pickTime(_endTimeController),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.teal, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.teal, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
                readOnly: true,
                validator: (value) =>
                    value!.isEmpty ? 'Please select an end time' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _maxPatientsController,
                decoration: InputDecoration(
                  labelText: 'Max Patients Per Slot',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.teal, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.teal, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter max patients' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.teal, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.teal, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Center(
                child: ElevatedButton(
                  onPressed: _submitAvailability,
                  child: const Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: Colors.teal,
                    backgroundColor: Colors.white,
                    elevation: 4, // Add shadow for depth
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
