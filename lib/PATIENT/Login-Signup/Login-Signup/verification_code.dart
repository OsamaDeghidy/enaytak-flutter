import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Login-Signup/Login-Signup/medicalRegistration.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Constant_Widgets/custom_bottomNAVbar.dart';
import 'package:flutter_sanar_proj/STTAFF/Widgets/CustomButton.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class VerificationCode extends StatelessWidget {
  const VerificationCode({super.key});

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
                  builder: (context) => const MedicalRegistrationPage()),
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
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 100),
          child: Center(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Enter the verification code we sent to your \n number",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  return Expanded(
                    child: _buildCodeField(context),
                  );
                }),
              ),
              const SizedBox(height: 40),
              Center(
                child: CustomButton(
                  text: "Next",
                  color: const Color.fromARGB(255, 3, 190, 150),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        type: PageTransitionType.bottomToTop,
                        child: const MainScreen(),
                      ),
                    );
                  },
                  height: 60,
                  width: 200,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Didn't receive the code yet? ",
                      style: Theme.of(context).textTheme.bodyLarge),
                  Text("Resend", style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ],
          ))),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildCodeField(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.06,
      margin: const EdgeInsets.symmetric(
          horizontal: 4.0), // Add horizontal margin for spacing
      decoration: BoxDecoration(
        color: const Color.fromARGB(241, 245, 245, 245),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: TextField(
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        decoration: const InputDecoration(
          border: OutlineInputBorder(borderSide: BorderSide.none),
          counterText: '',
          contentPadding: EdgeInsets.zero,
        ),
        style: TextStyle(fontSize: 20.sp),
        onChanged: (value) {
          if (value.isNotEmpty) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }
}
