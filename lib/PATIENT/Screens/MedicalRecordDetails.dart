import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Screens/diagnosis_detail_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedicalRecordDetails extends StatefulWidget {
  final String itemName;
  final int categoryId;

  const MedicalRecordDetails({
    Key? key,
    required this.itemName,
    required this.categoryId,
  }) : super(key: key);

  @override
  _MedicalRecordDetailsState createState() => _MedicalRecordDetailsState();
}

class _MedicalRecordDetailsState extends State<MedicalRecordDetails> {
  List<dynamic> diagnoses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDiagnoses();
  }

  Future<void> fetchDiagnoses() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId') ?? 0;

    final url =
        'http://67.205.166.136/api/diagnoses/user/$userId/category/${widget.categoryId}/';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'X-CSRFTOKEN':
              'm3elSkdGEmhpAN5ZYDh43H7WR9kZRFgzzzBQ6KQrTHBFpRKMJIPpYhHRIkCEG6yr',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> results = data['results'];

        setState(() {
          diagnoses = results;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load diagnoses');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching diagnoses: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Color.fromARGB(255, 190, 226, 223),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              widget.itemName,
              style: TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 1, 128, 116),
                    const Color.fromARGB(255, 139, 210, 215)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          body: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 0, 71, 64),
                  ),
                )
              : diagnoses.isEmpty
                  ? Center(
                      child: Text(
                        'No diagnoses found for this category.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: diagnoses.length,
                      itemBuilder: (context, index) {
                        final diagnosis = diagnoses[index];
                        final date = DateTime.parse(diagnosis['date']);
                        final formattedDate =
                            DateFormat('dd/MM/yyyy').format(date);

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DiagnosisDetailScreen(
                                    diagnosisId: diagnosis['id']),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            margin: EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.medical_services,
                                        color: Color.fromARGB(255, 0, 71, 64),
                                        size: 24,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Diagnosis',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(255, 0, 71, 64),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    diagnosis['diagnosis_text'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  Divider(
                                    color: Colors.grey.withOpacity(0.3),
                                    thickness: 1,
                                    height: 16,
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        color: Colors.grey[600],
                                        size: 16,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Date: $formattedDate',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
