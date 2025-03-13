import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Constant_Widgets/custom_bottomNAVbar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:my_fatoorah/my_fatoorah.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  List<Map<String, dynamic>> availableSlots = [];
  List<TimeOfDay> timeSlots = [];

  String? token;
  int? userId;
  int? doctorID;
  int? userdoctorID;

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('access');
      userId = prefs.getInt('userId');
      doctorID = prefs.getInt('doctorId');
      userdoctorID = prefs.getInt('user');
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
      availableSlots.clear();
      timeSlots.clear();
    });
    _fetchAvailableSlots();
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

          availableSlots = results
              .where((slot) => slot['day_of_week'] == dayOfWeek)
              .cast<Map<String, dynamic>>()
              .toList();

          for (var slot in availableSlots) {
            final startTime = TimeOfDay(
              hour: int.parse(slot['start_time'].split(':')[0]),
              minute: int.parse(slot['start_time'].split(':')[1]),
            );
            final endTime = TimeOfDay(
              hour: int.parse(slot['end_time'].split(':')[0]),
              minute: int.parse(slot['end_time'].split(':')[1]),
            );
            _generateTimeSlots(startTime, endTime);
          }

          setState(() {});
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
      slots.add(currentTime);
      currentTime = _addMinutes(currentTime, 30);
    }

    setState(() {
      timeSlots.addAll(slots);
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

  String? get formattedSelectedDate {
    if (selectedDate != null) {
      return DateFormat('yyyy-MM-dd').format(selectedDate!);
    }
    return null;
  }

  String? get formattedSelectedTime {
    if (selectedTime != null) {
      return '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00';
    }
    return null;
  }

  Future<void> onBookAppointment() async {
    if (selectedDate != null &&
        selectedTime != null &&
        token != null &&
        userId != null &&
        doctorID != null) {
      try {
        var response = await MyFatoorah.startPayment(
          context: context,
          request: MyfatoorahRequest.test(
              currencyIso: Country.SaudiArabia,
              successUrl: 'https://www.facebook.com',
              errorUrl: 'https://www.google.com/',
              invoiceAmount: 100,
              language: ApiLanguage.English,
              token:
                  'rLtt6JWvbUHDDhsZnfpAhpYk4dxYDQkbcPTyGaKp2TYqQgG7FGZ5Th_WD53Oq8Ebz6A53njUoo1w3pjU1D4vs_ZMqFiz_j0urb_BH9Oq9VZoKFoJEDAbRZepGcQanImyYrry7Kt6MnMdgfG5jn4HngWoRdKduNNyP4kzcp3mRv7x00ahkm9LAK7ZRieg7k1PDAnBIOG3EyVSJ5kK4WLMvYr7sCwHbHcu4A5WwelxYK0GMJy37bNAarSJDFQsJ2ZvJjvMDmfWwDVFEVe_5tOomfVNt6bOg9mexbGjMrnHBnKnZR1vQbBtQieDlQepzTZMuQrSuKn-t5XZM7V6fCW7oP-uXGX-sMOajeX65JOf6XVpk29DP6ro8WTAflCDANC193yof8-f5_EYY-3hXhJj7RBXmizDpneEQDSaSz5sFk0sV5qPcARJ9zGG73vuGFyenjPPmtDtXtpx35A-BVcOSBYVIWe9kndG3nclfefjKEuZ3m4jL9Gg1h2JBvmXSMYiZtp9MR5I6pvbvylU_PP5xJFSjVTIz7IQSjcVGO41npnwIxRXNRxFOdIUHn0tjQ-7LwvEcTXyPsHXcMD8WtgBh-wxR8aKX7WPSsT1O8d8reb2aR7K3rkV3K82K_0OgawImEpwSvp9MNKynEAJQS6ZHe_J_l77652xwPNxMRTMASk1ZsJL'),
        );
        debugPrint(
            'payment id ${response.paymentId} and order status ${response.status}');
        if (response.isSuccess) {
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
            "services": [3],
          };

          final appointmentResponse = await http.post(
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

          if (appointmentResponse.statusCode == 201) {
            setState(() {
              timeSlots.remove(selectedTime);
              selectedTime = null;
            });

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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Another user booked this appointment. Please select another appointment.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to process payment. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please fill in all the details to book an appointment.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Book Appointment"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
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
            const Text(
              "Select Appointment Time",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
            const SizedBox(height: 10),
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
                  onTap: () => _onTimeSelected(slot),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color:
                          selectedTime == slot ? Colors.teal : Colors.grey[300],
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
                        slot.format(context),
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
            // ElevatedButton(
            //   // onPressed: _onBookAppointment,
            //   onPressed: () {
            //     Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: (context) => PaymentPage(
            //                   onPressed: () {
            //                     if (selectedDate != null &&
            //                         selectedTime != null &&
            //                         token != null &&
            //                         userId != null &&
            //                         doctorID != null) {
            //                       AppointmentService().createAppointment(
            //                         context: context,
            //                         selectedDate: selectedDate!,
            //                         userId: userId!,
            //                         doctorID: doctorID!,
            //                         onSuccess: () {
            //                           Navigator.pop(context);
            //                           Navigator.pop(context);
            //                         },
            //                         onFailure: (String message) {
            //                           ScaffoldMessenger.of(context)
            //                               .showSnackBar(
            //                             SnackBar(
            //                               content: Text(message),
            //                             ),
            //                           );
            //                         },
            //                       );
            //                     } else {
            //                       ScaffoldMessenger.of(context).showSnackBar(
            //                         const SnackBar(
            //                           content: Text(
            //                               'Payment failed. Please try again.'),
            //                           backgroundColor: Colors.red,
            //                         ),
            //                       );
            //                     }
            //                   },
            //                 )));
            //   },
            //   style: ElevatedButton.styleFrom(
            //     minimumSize: const Size(double.infinity, 50),
            //     backgroundColor: Colors.teal,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(15),
            //     ),
            //   ),
            //   child: const Text(
            //     'Book Appointment',
            //     style: TextStyle(fontSize: 18, color: Colors.white),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
