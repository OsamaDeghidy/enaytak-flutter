import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Login-Signup/Login-Signup/personalRegestraion.dart';
import 'package:flutter_sanar_proj/PATIENT/Login-Signup/Login-Signup/verification_code.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Constant_Widgets/CustomDropdownField.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Constant_Widgets/CustomInputField.dart';
import 'package:flutter_sanar_proj/STTAFF/Widgets/CustomButton.dart';
import 'package:page_transition/page_transition.dart';

class MedicalRegistrationPage extends StatefulWidget {
  const MedicalRegistrationPage({super.key});

  @override
  _MedicalRegistrationPageState createState() =>
      _MedicalRegistrationPageState();
}

class _MedicalRegistrationPageState extends State<MedicalRegistrationPage> {
  final _medicalConditionsController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _currentMedicationsController = TextEditingController();
  final _medicalNotesController = TextEditingController();

  String? _bloodType;
  bool _organDonor = false;
  bool _smoker = false;
  bool _alcoholic = false;
  bool _active = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black, // Set the arrow color
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const PersonalRegistrationPage()),
            );
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo image on the left
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Image.asset(
                "assets/images/Enayatak.png",
                height: 80,
              ),
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                CustomInputField(
                  controller: _medicalConditionsController,
                  labelText: "Medical Conditions",
                  hintText: "Enter medical conditions",
                  icon: Icons.medical_information_outlined, inputDecoration: InputDecoration(),
                ),
                const SizedBox(height: 5),
                CustomInputField(
                  controller: _allergiesController,
                  labelText: "Allergies",
                  hintText: "Enter allergies",
                  icon: Icons.medical_information_outlined, inputDecoration: InputDecoration(),
                ),
                const SizedBox(height: 5),
                CustomInputField(
                  controller: _currentMedicationsController,
                  labelText: "Current Medications",
                  hintText: "Enter current medications",
                  icon: Icons.medication_liquid, inputDecoration: InputDecoration(),
                ),
                const SizedBox(height: 5),
                CustomDropdownField(
                  labelText: "Blood Type",
                  selectedValue: _bloodType,
                  onChanged: (String? newValue) {
                    setState(() {
                      _bloodType = newValue;
                    });
                  },
                  icon: Icons.bloodtype,
                  hintText: "Select Blood Type",
                  items: const ["A", "B", "AB", "O"],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.92,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CheckboxListTile(
                          title: const Text("Organ Donor"),
                          value: _organDonor,
                          onChanged: (bool? value) {
                            setState(() {
                              _organDonor = value!;
                            });
                          },
                          activeColor: Colors.green,
                          checkColor: Colors.white,
                          controlAffinity: ListTileControlAffinity.leading,
                          secondary: Icon(
                            Icons.favorite,
                            color: _organDonor ? Colors.green : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 5),
                        CheckboxListTile(
                          title: const Text("Smoker"),
                          value: _smoker,
                          onChanged: (bool? value) {
                            setState(() {
                              _smoker = value!;
                            });
                          },
                          activeColor: Colors.red,
                          checkColor: Colors.white,
                          controlAffinity: ListTileControlAffinity.leading,
                          secondary: Icon(
                            Icons.smoking_rooms,
                            color: _smoker ? Colors.red : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 5),
                        CheckboxListTile(
                          title: const Text("Alcoholic"),
                          value: _alcoholic,
                          onChanged: (bool? value) {
                            setState(() {
                              _alcoholic = value!;
                            });
                          },
                          activeColor: Colors.orange,
                          checkColor: Colors.white,
                          controlAffinity: ListTileControlAffinity.leading,
                          secondary: Icon(
                            Icons.local_bar,
                            color: _alcoholic ? Colors.orange : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 5),
                        CheckboxListTile(
                          title: const Text("Active Person"),
                          value: _active,
                          onChanged: (bool? value) {
                            setState(() {
                              _active = value!;
                            });
                          },
                          activeColor: Colors.blue,
                          checkColor: Colors.white,
                          controlAffinity: ListTileControlAffinity.leading,
                          secondary: Icon(
                            Icons.directions_run,
                            color: _active ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                CustomInputField(
                  controller: _medicalNotesController,
                  labelText: "Medical Notes",
                  hintText: "Additional medical information",
                  icon: Icons.notes, inputDecoration: InputDecoration(),
                ),
                const SizedBox(height: 5),
                Center(
                  child: CustomButton(
                    text: "Submit",
                    color: const Color.fromARGB(255, 3, 190, 150),
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: const VerificationCode(),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text("Medical information saved locally.")),
                      );
                    },
                    height: 60,
                    width: 250,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
