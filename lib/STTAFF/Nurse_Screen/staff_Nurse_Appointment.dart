import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/STTAFF/Nurse_Screen/addNurse_diagnosis.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Constant_Widgets/custom_AppBar.dart';

class Staff_Nurse_AppointmentScreen extends StatefulWidget {
  const Staff_Nurse_AppointmentScreen({super.key});

  @override
  State<Staff_Nurse_AppointmentScreen> createState() =>
      _Staff_Nurse_AppointmentScreenState();
}

class _Staff_Nurse_AppointmentScreenState
    extends State<Staff_Nurse_AppointmentScreen> {
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

    final url =
        'http://67.205.166.136/api/nurses/$specificId/appointments/?page=1';

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

  Future<void> updateAppointmentNote(
    int appointmentId,
    String note,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access') ?? '';
    final specificId =
        prefs.getInt('specificId'); // Assuming this is the patient ID

    final url = 'http://67.205.166.136/api/appointments/$appointmentId/';

    try {
      final response = await http.put(
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
          "service_type":
              "teleconsultation", // Replace with a valid service type
          "patient": specificId, // Replace with a valid patient ID
          "doctor": '',
          "nurse": '',
          "services": [4],
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('Note updated successfully');
        fetchAppointments(); // Refresh data
      } else {
        debugPrint(
            'Error updating note: ${response.statusCode} - ${response.body}');
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
                color: Colors.teal,
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
                      onSaveNote: updateAppointmentNote,
                      onAddDiagnosis: (int appointmentId) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddNurseDiagnosisScreen(
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
  final Function(int, String) onSaveNote;
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
            color: Colors.teal[400],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: false,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.black54,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            indicator: BoxDecoration(
              color: Colors.teal[600],
              borderRadius: BorderRadius.circular(12),
            ),
            tabs: widget.tabs
                .map((tab) => Tab(
                      text: tab.title,
                    ))
                .toList(),
          ),
        ),
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
  final Function(int, String) onSaveNote;
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
                Text(
                  listItem.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
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
                Text(
                  '\$${listItem.trailing}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        onAddDiagnosis(listItem.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Add Diagnosis',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
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
                                        listItem.id, notesController.text);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Save'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Add link',
                        style: TextStyle(color: Colors.white),
                      ),
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

  ListItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.notes,
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
