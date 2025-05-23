import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Constant_Widgets/custom_AppBar.dart';
import 'package:flutter_sanar_proj/constant.dart';
import 'package:flutter_sanar_proj/core/helper/app_helper.dart';
import 'package:flutter_sanar_proj/core/widgets/custom_button.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/widgets/custom_gradiant_text_widget.dart';
import 'add_diagnosis.dart'; // Import the AddDiagnosisScreen

class StaffAppointmentScreen extends StatefulWidget {
  const StaffAppointmentScreen({super.key});

  @override
  State<StaffAppointmentScreen> createState() => _StaffAppointmentScreenState();
}

class _StaffAppointmentScreenState extends State<StaffAppointmentScreen> {
  List<ListItem> confirmedAppointments = [];
  List<ListItem> refusedAppointments = [];
  bool isLoading = true;
  Map<String, dynamic> userData = {};

  Future<Map<String, String>> fetchServiceDetails(int serviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access') ?? '';

      final url = Uri.parse('http://67.205.166.136/api/services/$serviceId/');
      final response = await http.get(
        url,
        headers: {
          'accept': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return {
          'name': data['name'] ?? 'Unknown Service',
          'cost': data['price']?.toString() ?? 'No Cost'
        };
      }
      return {'name': 'Unknown Service', 'cost': 'No Cost'};
    } catch (error) {
      print('Error fetching service details: $error');
      return {'name': 'Unknown Service', 'cost': 'No Cost'};
    }
  }

  String formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'No Date Time';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  Future<void> fetchAppointments() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access') ?? '';
    final specificId = prefs.getInt('specificId');
    debugPrint('specificId is $specificId , token is $token');
    final url =
        'http://67.205.166.136/api/doctors/$specificId/appointments/?page=1';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json; charset=utf-8',
          'X-CSRFTOKEN':
              'nBu98iMSXQUHWNabH8k7LLALqEPDzjQVmeBE9u7XssKYmYnL1hmvmJ8qRXOAfQ0u',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final results = List<Map<String, dynamic>>.from(data['results']);

        // Sort results by date in descending order (newest first)
        results.sort((a, b) {
          final dateA =
              DateTime.tryParse(a['date_time'] ?? '') ?? DateTime(1900);
          final dateB =
              DateTime.tryParse(b['date_time'] ?? '') ?? DateTime(1900);
          return dateB.compareTo(dateA); // Reverse order for newest first
        });

        // Process confirmed appointments
        List<Future<ListItem>> confirmedFutures = results
            .where((appointment) => appointment['status'] == 'confirmed')
            .map((appointment) async {
          final serviceDetails =
              await fetchServiceDetails(appointment['services'][0] ?? 0);
          return ListItem(
            id: appointment['id'],
            title: serviceDetails['name'] ?? 'Unknown Service',
            subtitle: formatDateTime(appointment['date_time']),
            trailing: serviceDetails['cost'] ?? 'No Cost',
            notes: appointment['notes'] ?? 'No link provided',
            serviceType: appointment['service_type'] ?? 'Unknown Service Type',
            patientId: appointment['patient'] ?? 0,
            doctorId: appointment['doctor'] ?? 0,
            nurseId: appointment['nurse'] ?? 0,
            services: appointment['services'] ?? [],
          );
        }).toList();

        // Process refused appointments
        List<Future<ListItem>> refusedFutures = results
            .where((appointment) => appointment['status'] == 'cancelled')
            .map((appointment) async {
          final serviceDetails =
              await fetchServiceDetails(appointment['services'][0] ?? 0);
          return ListItem(
            id: appointment['id'],
            title: serviceDetails['name'] ?? 'Unknown Service',
            subtitle: formatDateTime(appointment['date_time']),
            trailing: serviceDetails['cost'] ?? 'No Cost',
            notes: appointment['notes'] ?? 'No link provided',
            serviceType: appointment['service_type'] ?? 'Unknown Service Type',
            patientId: appointment['patient'] ?? 0,
            doctorId: appointment['doctor'] ?? 0,
            nurseId: appointment['nurse'] ?? 0,
            services: appointment['services'] ?? [],
          );
        }).toList();

        // Wait for all futures to complete
        confirmedAppointments = await Future.wait(confirmedFutures);
        refusedAppointments = await Future.wait(refusedFutures);

        setState(() {});
      } else {
        debugPrint('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateAppointmentNote({
    required int appointmentId,
    required String note,
    String? serviceType,
    int? patientId,
    int? doctorId,
    int? nurseId,
    int? labId,
    int? hospitalId,
    List<dynamic>? services,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access') ?? '';
    // final specificId =
    //     prefs.getInt('specificId'); // Assuming this is the patient ID

    final url = 'http://67.205.166.136/api/appointments/$appointmentId/';

    try {
      debugPrint('note or link is $note');
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'accept': 'application/json; charset=utf-8',
          'Content-Type': 'application/json',
          'X-CSRFTOKEN':
              'FTXOrj7A0h4seuYibzZLTxHGGC3ZiNsrDXnP3Rj4N0PoHDBw7o6XMfzBmZLAGfkf',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "notes": note,
          if (serviceType != null) "service_type": serviceType,
          if (patientId != null) "patient": patientId,
          if (doctorId != null) "doctor": doctorId,
          "nurse": nurseId == 0 || nurseId == null ? null : nurseId,
          if (labId != null && labId != 0) "lab": labId,
          if (hospitalId != null && hospitalId != 0) "hospital": hospitalId,
          if (services != null) "services": services,
        }),
      );
      debugPrint('Request URL: $url');
      debugPrint('Request Headers: ${{
        'accept': 'application/json; charset=utf-8',
        'Content-Type': 'application/json',
        'X-CSRFTOKEN':
            'FTXOrj7A0h4seuYibzZLTxHGGC3ZiNsrDXnP3Rj4N0PoHDBw7o6XMfzBmZLAGfkf',
        'Authorization': 'Bearer $token',
      }}');
      debugPrint('Request Body: ${json.encode({
            "notes": note,
            if (serviceType != null) "service_type": serviceType,
            if (patientId != null) "patient": patientId,
            if (doctorId != null) "doctor": doctorId,
            "nurse": nurseId == 0 || nurseId == null ? null : nurseId,
            if (labId != null && labId != 0) "lab": labId,
            if (hospitalId != null && hospitalId != 0) "hospital": hospitalId,
            if (services != null) "services": services,
          })}');
      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('link updated successfully');
        AppHelper.successSnackBar(
            context: context, message: 'Link updated successfully');
        fetchAppointments(); // Refresh data
      } else {
        AppHelper.errorSnackBar(
            context: context, message: 'Error updating link');
        debugPrint(
            'Error updating link: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAppointments(); // Fetch appointments
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const CustomAppBar(),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Constant.primaryColor,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Expanded(
                    child: TabbedList(
                      tabs: [
                        TabData(
                          title: 'Accepted Requests',
                          items: confirmedAppointments,
                        ),
                        TabData(
                          title: 'Refused Requests',
                          items: refusedAppointments,
                        ),
                      ],
                      onSaveNote: ({
                        required int appointmentId,
                        required String note,
                        String? serviceType,
                        int? patientId,
                        int? doctorId,
                        int? nurseId,
                        int? labId,
                        int? hospitalId,
                        List<dynamic>? services,
                      }) {
                        updateAppointmentNote(
                          appointmentId: appointmentId,
                          note: note,
                          serviceType: serviceType,
                          patientId: patientId,
                          doctorId: doctorId,
                          nurseId: nurseId,
                          labId: labId,
                          hospitalId: hospitalId,
                          services: services,
                        );
                      },
                      onAddDiagnosis: (int appointmentId) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddDiagnosisScreen(
                                appointmentId: appointmentId),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class TabbedList extends StatefulWidget {
  final List<TabData> tabs;
  final Function({
    required int appointmentId,
    required String note,
    String? serviceType,
    int? patientId,
    int? doctorId,
    int? nurseId,
    int? labId,
    int? hospitalId,
    List<dynamic>? services,
  }) onSaveNote;
  final Function(int) onAddDiagnosis;

  const TabbedList({
    super.key,
    required this.tabs,
    required this.onSaveNote,
    required this.onAddDiagnosis,
  });

  @override
  State<TabbedList> createState() => _TabbedListState();
}

class _TabbedListState extends State<TabbedList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
          ),
          child: TabBar(
            physics: const BouncingScrollPhysics(),
            controller: _tabController,
            isScrollable: false,
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
            tabs: widget.tabs
                .map((tab) => Tab(
                      text: tab.title,
                    ))
                .toList(),
            indicatorSize: TabBarIndicatorSize.tab,
            padding: EdgeInsets.zero,
            indicatorPadding: EdgeInsets.zero,
            dividerColor: Colors.transparent,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: widget.tabs
                .map((tab) => ListContent(
                      items: tab.items,
                      onSaveNote: widget.onSaveNote,
                      onAddDiagnosis: widget.onAddDiagnosis,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class ListContent extends StatelessWidget {
  final List<ListItem> items;
  final Function({
    required int appointmentId,
    required String note,
    String? serviceType,
    int? patientId,
    int? doctorId,
    int? nurseId,
    int? labId,
    int? hospitalId,
    List<dynamic>? services,
  }) onSaveNote;
  final Function(int) onAddDiagnosis;

  const ListContent({
    super.key,
    required this.items,
    required this.onSaveNote,
    required this.onAddDiagnosis,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final listItem = items[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomGradiantTextWidget(
                  text: listItem.title,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 8),
                Text(
                  listItem.subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                CustomGradiantTextWidget(
                  text: '${listItem.trailing} ${Constant.currency}',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomButtonNew(
                      width: 160,
                      height: 40,
                      title: 'Add Diagnosis',
                      isBackgroundPrimary: true,
                      onPressed: () {
                        onAddDiagnosis(listItem.id); // Pass appointmentId
                      },
                      isLoading: false,
                    ),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     onAddDiagnosis(listItem.id); // Pass appointmentId
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.teal,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //   ),
                    //   child: const Text(
                    //     'Add Diagnosis',
                    //     style: TextStyle(color: Colors.white),
                    //   ),
                    // ),
                    const SizedBox(width: 8),
                    CustomButtonNew(
                      width: 120,
                      height: 40,
                      title: 'Add link',
                      isBackgroundPrimary: true,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            final TextEditingController notesController =
                                TextEditingController(text: listItem.notes);

                            return AlertDialog(
                              title: const Text('Add link'),
                              content: TextField(
                                controller: notesController,
                                maxLines: 5,
                                decoration: const InputDecoration(
                                  hintText: 'Enter your link here',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    onSaveNote(
                                      appointmentId: listItem.id,
                                      note: notesController.text,
                                      serviceType: listItem.serviceType,
                                      patientId: listItem.patientId,
                                      doctorId: listItem.doctorId,
                                      nurseId: listItem.nurseId,
                                      labId: listItem.labId,
                                      hospitalId: listItem.hospitalId,
                                      services: listItem.services,
                                    );
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Save'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      isLoading: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ListItem {
  final int id;
  final String title;
  final String subtitle;
  final String trailing;
  final String notes;
  final String? serviceType;
  final int? patientId;
  final int? doctorId;
  final int? nurseId;
  final int? labId;
  final int? hospitalId;
  final List<dynamic>? services;

  ListItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.notes,
    this.serviceType,
    this.patientId,
    this.doctorId,
    this.nurseId,
    this.labId,
    this.hospitalId,
    this.services,
  });
}

class TabData {
  final String title;
  final List<ListItem> items;

  TabData({
    required this.title,
    required this.items,
  });
}
