import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Login-Signup/Login-Signup/login_signup.dart';
import 'package:flutter_sanar_proj/PATIENT/Login-Signup/Login-Signup/personalRegestraion.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Constant_Widgets/custom_bottomNAVbar.dart';
import 'package:flutter_sanar_proj/STTAFF/HOSPITAL/Hospital_bottom_navbar.dart';
import 'package:flutter_sanar_proj/STTAFF/LAB/Lab_bottom_navbar.dart';
import 'package:flutter_sanar_proj/STTAFF/Widgets/customDoctor_bottomNAVbar.dart';
import 'package:flutter_sanar_proj/STTAFF/Widgets/customNurse_bottomNAVbar.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Define the new color
  final Color newColor = const Color(0xFF52A0AE); // #52A0AE

  Future<void> handleLogin() async {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    final url = Uri.parse('http://67.205.166.136/api/login/');
    final headers = {
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      'email': email,
      'password': password,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final token = responseBody['access'];
        final userId = responseBody['user']['id'];
        final userType = responseBody['user_type'];
        final specificId = responseBody['specific_id'] ?? 0;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access', token);
        await prefs.setInt('userId', userId);
        await prefs.setInt('specificId', specificId);
        await prefs.setString('user_type', userType);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Login successful!",
                  style: TextStyle(color: Colors.green))),
        );

        if (userType == 'doctor') {
          Navigator.pushReplacement(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: const StaffMainScreen(),
            ),
          );
        } else if (userType == 'patient') {
          Navigator.pushReplacement(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: const MainScreen(),
            ),
          );
        } else if (userType == 'nurse') {
          Navigator.pushReplacement(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: const StaffNurseMainScreen(),
            ),
          );
        } else if (userType == 'hospital') {
          Navigator.pushReplacement(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: const HospitalMainScreen(),
            ),
          );
        } else if (userType == 'lab') {
          Navigator.pushReplacement(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: const LabMainScreen(),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login failed. Check credentials.")),
        );
        print(response.body);
        print(response.statusCode);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred. Please try again.")),
      );
    }
  }

  void navigateToRegistration() {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.rightToLeft,
        child: const PersonalRegistrationPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleSpacing: 0,
        // automaticallyImplyLeading: false, // Remove or comment this line
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: const Color(0xFF52A0AE), // Use the color #52A0AE
          ),
          onPressed: () {
            // Navigate to the LoginSignup screen
            Navigator.pushReplacement(
              context,
              PageTransition(
                type: PageTransitionType.rightToLeft,
                child:
                    const LoginSignup(), // Replace with your LoginSignup screen
              ),
            );
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Image.asset(
                "assets/images/Enayatak.png",
                height: screenHeight * 0.1,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.1,
            vertical: screenHeight * 0.05,
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: screenHeight * 0.2,
                  child: Image.asset(
                    "assets/images/logo.png",
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email, color: newColor),
                    labelText: "Email",
                    labelStyle: TextStyle(color: newColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: newColor),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                TextField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: newColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: newColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    labelText: "Password",
                    labelStyle: TextStyle(color: newColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: newColor),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: navigateToRegistration,
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: newColor,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                SizedBox(
                  width: screenWidth * 0.5,
                  height: screenHeight * 0.08,
                  child: ElevatedButton(
                    onPressed: handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: newColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Log In",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
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
