import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Schadule_Details/payment_page.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Constant_Widgets/custom_bottomNAVbar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingDoctorServiceAppointment extends StatefulWidget {
  const BookingDoctorServiceAppointment(
      {super.key, required this.servicePrice});
  final String servicePrice;
  @override
  _BookingDoctorServiceAppointmentState createState() =>
      _BookingDoctorServiceAppointmentState();
}

class _BookingDoctorServiceAppointmentState
    extends State<BookingDoctorServiceAppointment> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  List<Map<String, dynamic>> availableSlots = []; // To hold available slots
  List<TimeOfDay> timeSlots = []; // To hold generated time slots
  Set<TimeOfDay> bookedSlots = {}; // To track booked time slots

  String? token; // To hold the token
  int? userId; // To hold the user ID
  int? doctorID; // To hold the doctor ID
  int? userdoctorID;
  int? serviceIId;

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('access'); // Get token
      userId = prefs.getInt('userId'); // Get user ID
      doctorID = prefs.getInt('doctorServiceId'); // Get doctor ID
      userdoctorID = prefs.getInt('userServicedoctorId'); // Get doctor ID
      serviceIId = prefs.getInt('serviceIId');
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load token, user ID, and doctor ID when the screen initializes
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
      availableSlots.clear(); // Clear previous slots
      timeSlots.clear(); // Clear previous time slots
      bookedSlots.clear(); // Clear booked slots for the new date
    });
    _fetchAvailableSlots(); // Fetch available slots for the selected date
  }

  Future<void> _fetchAvailableSlots() async {
    if (doctorID != null && selectedDate != null) {
      final String dayOfWeek =
          DateFormat('EEEE').format(selectedDate!).toLowerCase();
      final url = Uri.parse(
          'http://67.205.166.136/api/users/$userdoctorID/availabilities/?page=1');

      try {
        final response = await http.get(url, headers: {
          'accept': 'application/json',
          'X-CSRFTOKEN':
              'P3FjABAEkWU1wc3ikUa0GKXXhY6nbXMgOGMOBNVJPyKiWngSE3cohIvCIh5kRuWP',
        });

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final results = data['results'] as List;

          // Filter available slots for the selected day
          availableSlots = results
              .where((slot) => slot['day_of_week'] == dayOfWeek)
              .cast<Map<String, dynamic>>()
              .toList();

          // Clear existing time slots
          timeSlots.clear();

          // Generate time slots for each available slot
          for (var slot in availableSlots) {
            final startTime = TimeOfDay(
              hour: int.parse(slot['start_time'].split(':')[0]),
              minute: int.parse(slot['start_time'].split(':')[1]),
            );
            final endTime = TimeOfDay(
              hour: int.parse(slot['end_time'].split(':')[0]),
              minute: int.parse(slot['end_time'].split(':')[1]),
            );
            _generateTimeSlots(startTime, endTime); // Generate time slots
          }

          setState(() {}); // Update the UI
        } else {
          print('Failed to load available slots: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching available slots: $e');
      }
    }
  }

  void _generateTimeSlots(TimeOfDay startTime, TimeOfDay endTime) {
    final slots = <TimeOfDay>[];
    var currentTime = startTime;

    while (currentTime.hour < endTime.hour ||
        (currentTime.hour == endTime.hour &&
            currentTime.minute <= endTime.minute)) {
      // Skip the slot if it's already booked
      if (!bookedSlots.contains(currentTime)) {
        slots.add(currentTime);
      }
      // Add 30 minutes to the current time
      currentTime = _addMinutes(currentTime, 30);
    }

    setState(() {
      timeSlots.addAll(slots); // Add generated slots to the list
    });
  }

  TimeOfDay _addMinutes(TimeOfDay time, int minutes) {
    final totalMinutes = time.hour * 60 + time.minute + minutes;
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    return TimeOfDay(hour: hours, minute: mins);
  }

  void _onTimeSelected(TimeOfDay time) {
    setState(() {
      selectedTime = time;
    });
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

  Future<void> _onBookAppointment() async {
    if (selectedDate != null &&
        selectedTime != null &&
        token != null &&
        userId != null &&
        doctorID != null) {
      final int patientId = userId!;
      final int doctorId = doctorID!;

      final appointmentData = {
        "date_time": selectedDateTime?.toIso8601String(),
        "service_type": "teleconsultation",
        "status": "booked",
        "notes": "string",
        "appointment_address": "string",
        "is_follow_up": false,
        "is_confirmed": false,
        "patient": patientId,
        "doctor": doctorId,
        "nurse": null,
        "services": [serviceIId],
      };

      try {
        final response = await http.post(
          Uri.parse('http://67.205.166.136/api/appointments/'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-CSRFTOKEN':
                'o0Y2YK8sS1VKe1pNcJlrvZ8Gs6Jrf28nnD5xZWtxnDL1EcCnwSnP6XGlTpIoVziW',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(appointmentData),
        );

        if (response.statusCode == 201) {
          // Add the selected time slot to the bookedSlots set
          setState(() {
            bookedSlots.add(selectedTime!); // Mark the slot as booked
            timeSlots.removeWhere((slot) =>
                slot.hour == selectedTime!.hour &&
                slot.minute == selectedTime!.minute); // Remove from timeSlots
            selectedTime = null; // Clear the selected time
          });

          // Refresh the available slots
          await _fetchAvailableSlots();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment successfully booked!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        } else {
          final responseBody = json.decode(response.body);
          print('Error Response Body: $responseBody');

          String errorMessage =
              'Another user booked this appointment. Please select another time.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
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
    debugPrint('service price ${widget.servicePrice}');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Book Appointment"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.teal.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Select Appointment Date",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null && picked != selectedDate) {
                    _onDateSelected(picked); // Call the date selected method
                  }
                },
                child: Card(
                  elevation: 5,
                  color: selectedDate == null
                      ? Colors.grey[300]
                      : Colors.teal[100],
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
              const Text(
                "Select Appointment Time",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
              const SizedBox(height: 10),
              // Display generated time slots
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: timeSlots.length,
                itemBuilder: (context, index) {
                  final slot = timeSlots[index];
                  return GestureDetector(
                    onTap: () => _onTimeSelected(slot), // Select the time slot
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: selectedTime == slot
                            ? Colors.teal
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          if (selectedTime == slot)
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.4),
                              spreadRadius: 3,
                              blurRadius: 6,
                            )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          slot.format(context), // Format the time slot
                          style: TextStyle(
                            color: selectedTime == slot
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PaymentPage(
                                doctorID: doctorID,
                                userId: userId,
                                selectedDate: selectedDate,

                                // onPressed: () {
                                //   debugPrint(
                                //       'we call the payment page , onPressed');
                                //   if (selectedDate != null &&
                                //       selectedTime != null &&
                                //       token != null &&
                                //       userId != null &&
                                //       doctorID != null) {
                                //     AppointmentService().createAppointment(
                                //       context: context,
                                //       selectedDate: selectedDate!,
                                //       userId: userId!,
                                //       doctorID: doctorID!,
                                //       onSuccess: () {
                                //         Navigator.pop(context);
                                //         Navigator.pop(context);
                                //       },
                                //       onFailure: (String message) {
                                //         ScaffoldMessenger.of(context)
                                //             .showSnackBar(
                                //           SnackBar(
                                //             content: Text(message),
                                //           ),
                                //         );
                                //       },
                                //     );
                                //   } else {
                                //     ScaffoldMessenger.of(context).showSnackBar(
                                //       const SnackBar(
                                //         content: Text(
                                //             'Payment failed. Please try again.'),
                                //         backgroundColor: Colors.red,
                                //       ),
                                //     );
                                //   }
                                // },
                                servicePrice: widget.servicePrice,
                              )));
                },
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
      ),
    );
  }
}
