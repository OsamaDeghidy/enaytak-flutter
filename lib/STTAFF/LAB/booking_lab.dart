import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Colors/colors.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Constant_Widgets/custom_bottomNAVbar.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleLabScreen extends StatefulWidget {
  final int labId; // Hospital ID passed from ProviderDetailsScreen
  final int serviceId;
  final int userId;
  final String price;
  const ScheduleLabScreen(
      {required this.labId,
      Key? key,
      required this.serviceId,
      required this.price,
      required this.userId})
      : super(key: key);

  @override
  _ScheduleLabScreenState createState() => _ScheduleLabScreenState();
}

class _ScheduleLabScreenState extends State<ScheduleLabScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  List<Map<String, dynamic>> availableSlots = []; // To hold available slots
  String selectedServiceType = 'teleconsultation'; // Default service type
  final List<String> serviceTypes = ['teleconsultation', 'home_visit'];

  String? token; // To hold the token
  bool isLoading = false; // Loading state
  int? patientId;
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('access'); // Get tokenge
      patientId = prefs.getInt('userId');
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load token, user ID, and hospital ID when the screen initializes
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
      availableSlots.clear(); // Clear previous slots
      isLoading = true; // Set loading state to true
    });
    _fetchAvailableSlots(); // Fetch available slots for the selected date
  }

  Future<void> _fetchAvailableSlots() async {
    if (widget.userId != null && selectedDate != null) {
      final String dayOfWeek =
          DateFormat('EEEE').format(selectedDate!).toLowerCase();
      final url = Uri.parse(
          'http://67.205.166.136/api/users/${widget.userId}/availabilities/?page=1');

      try {
        final response = await http.get(url, headers: {
          'accept': 'application/json',
          'X-CSRFTOKEN':
              'P3FjABAEkWU1wc3ikUa0GKXXhY6nbXMgOGMOBNVJPyKiWngSE3cohIvCIh5kRuWP',
        });

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final results = data['results'] as List;

          // Check if there are no available slots
          if (results.isEmpty) {
            setState(() {
              availableSlots.clear(); // Clear previous slots
              isLoading = false; // Set loading state to false
              _showNoSlotsMessage(); // Show no slots message
            });
          } else {
            // Filter available slots for the selected day
            availableSlots = results
                .where((slot) => slot['day_of_week'] == dayOfWeek)
                .cast<Map<String, dynamic>>()
                .toList();
            setState(() {
              isLoading = false; // Set loading state to false
            }); // Update the UI
          }
        } else {
          print('Failed to load available slots: ${response.statusCode}');
          setState(() {
            isLoading = false; // Set loading state to false
          });
          _showErrorMessage(); // Handle error
        }
      } catch (e) {
        print('Error fetching available slots: $e');
        setState(() {
          isLoading = false; // Set loading state to false
        });
        _showErrorMessage(); // Handle error
      }
    }
  }

  void _showNoSlotsMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'No available slots for the selected date. Please choose another date.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showErrorMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error fetching availability. Please try again later.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  TimeOfDay? selectedSlotTime;

  void _onTimeSelected(TimeOfDay time) {
    setState(() {
      selectedSlotTime = time;
      selectedTime = time;
    });
    print(selectedTime);
  }

  DateTime? get selectedDateTime {
    if (selectedDate != null && selectedTime != null) {
      return DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );
    }
    return null;
  }

  String? get formattedSelectedDate {
    if (selectedDate != null) {
      return DateFormat('yyyy-MM-dd').format(selectedDate!); // Format date
    }
    return null;
  }

  String? get formattedSelectedTime {
    if (selectedTime != null) {
      return '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00'; // Format time with timezone
    }
    return null;
  }

  Future<void> _onBookAppointment() async {
    if (selectedDate != null &&
        selectedTime != null &&
        token != null &&
        widget.userId != null &&
        patientId != null &&
        widget.labId != null &&
        widget.serviceId != null) {
      // Combine selected date and time into a DateTime object
      final DateTime dateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      // Appointment data matching the API schema
      final appointmentData = {
        "date_time":
            dateTime.toIso8601String(), // Date and time formatted as ISO string
        "service_type": selectedServiceType, // Service type (adjust if needed)
        "status": "booked", // Status of the appointment
        "cost": widget.price, // Set to null if cost is not provided
        "notes": null, // You can replace with actual notes if needed
        "appointment_address": null, // Address for the appointment, can be null
        "is_follow_up": false, // Set to false for initial appointments
        "is_confirmed": false, // Initially not confirmed
        "patient": patientId, // Patient ID from shared preferences
        "doctor": null, // Assuming serviceId maps to doctor ID
        "nurse": null, // Set to null if nurse is not needed
        "hospital": null, // Hospital ID passed to the screen
        "lab": widget.labId, // Set to null if lab is not involved
        "services": [
          widget.serviceId
        ], // List of services; you can extend it if necessary
      };

      try {
        // Send POST request to API to book the appointment
        final response = await http.post(
          Uri.parse('http://67.205.166.136/api/appointments/'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-CSRFTOKEN':
                'o0Y2YK8sS1VKe1pNcJlrvZ8Gs6Jrf28nnD5xZWtxnDL1EcCnwSnP6XGlTpIoVziW', // Use the correct CSRF token
            'Authorization': 'Bearer $token', // Use the token for authorization
          },
          body:
              json.encode(appointmentData), // Send the appointment data as JSON
        );

        if (response.statusCode == 201) {
          print(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment successfully booked!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        } else {
          // Handle error response
          final responseBody = json.decode(response.body);
          print(responseBody);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to book appointment: $responseBody'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Failed to book appointment. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please fill in all the details to book an appointment'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lab'),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Title for Appointment Date
            const Text(
              "Select Appointment Date",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
            const SizedBox(height: 10),
            Text(
              "Price: ${widget.price} SAR",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: primaryColor),
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2030),
                );
                if (picked != null && picked != selectedDate) {
                  _onDateSelected(picked);
                }
              },
              child: Card(
                elevation: 5,
                color:
                    selectedDate == null ? Colors.grey[300] : Colors.teal[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Text(
                      selectedDate == null
                          ? 'Select Date'
                          : DateFormat('yMMMd').format(selectedDate!),
                      style: TextStyle(
                        color: selectedDate == null
                            ? Colors.black
                            : Colors.teal[800],
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title for Available Slots
            Text(
              "Select Available Slot",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (availableSlots.isEmpty)
              Center(child: Text('No slots available for this date'))
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // Adjust the number of slots per row
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: availableSlots.fold<int>(0, (sum, slot) {
                  // Calculate total 30-minute intervals across all available slots
                  DateTime start =
                      DateFormat('HH:mm').parse(slot['start_time']);
                  DateTime end = DateFormat('HH:mm').parse(slot['end_time']);

                  int intervalCount = 0;
                  while (start.isBefore(end)) {
                    intervalCount++;
                    start = start.add(const Duration(minutes: 30));
                  }
                  return sum +
                      intervalCount; // Add the number of 30-minute intervals
                }),
                itemBuilder: (context, index) {
                  // Flatten the list of slots into individual 30-minute intervals
                  List<TimeOfDay> halfHourSlots = [];
                  for (var slot in availableSlots) {
                    DateTime start =
                        DateFormat('HH:mm').parse(slot['start_time']);
                    DateTime end = DateFormat('HH:mm').parse(slot['end_time']);

                    while (start.isBefore(end)) {
                      halfHourSlots.add(
                          TimeOfDay(hour: start.hour, minute: start.minute));
                      start = start.add(const Duration(
                          minutes: 30)); // Add 30 minutes for each slot
                    }
                  }

                  // Get the current slot for the grid item
                  final timeSlot = halfHourSlots[index];

                  // Check if this slot is selected
                  final bool isSelected = selectedSlotTime == timeSlot;

                  return GestureDetector(
                    onTap: () {
                      _onTimeSelected(
                          timeSlot); // Update the selected slot time
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.teal : Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.4),
                              spreadRadius: 3,
                              blurRadius: 6,
                            )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${timeSlot.format(context)}',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),
            Text(
              "Select Service Type",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor),
              ),
              child: DropdownButton<String>(
                value: selectedServiceType,
                isExpanded: true,
                underline: SizedBox(),
                items: serviceTypes
                    .map((type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedServiceType = value!;
                  });
                },
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onBookAppointment,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Book Appointment',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
