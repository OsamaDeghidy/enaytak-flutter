import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Login-Signup/Login-Signup/login.dart';
import 'package:flutter_sanar_proj/PATIENT/Login-Signup/Login-Signup/personalRegestraion.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LoginSignup extends StatelessWidget {
  const LoginSignup({super.key});

  @override
  Widget build(BuildContext context) {
    // Store screen height and width
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // Ensure the gradient covers the entire screen
      body: Container(
        width: double.infinity, // Cover full width
        height: double.infinity, // Cover full height
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0782BA), // #0782BA
              Color(0xFF8DCFD4), // #8DCFD4
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  Padding(
                    padding: const EdgeInsets.only(right: 35),
                    child: Container(
                      height: screenHeight * 0.2,
                      width: screenHeight * 0.4,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/Enayatak2.png"),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Title Text
                  Text(
                    "Let's get Started!",
                    style: GoogleFonts.poppins(
                      fontSize: 22.sp,
                      color: Colors.white, // Updated text color
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  // Subtitle Text
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Text(
                      "Login to enjoy the features we've provided, and stay healthy",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        color: Colors.white, // Updated text color
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  // Login Button
                  SizedBox(
                    height: screenHeight * 0.06,
                    width: screenWidth * 0.7,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: const Login()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // Button background
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Login",
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          color: const Color.fromARGB(
                              255, 0, 0, 0), // Button text color
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Signup Button
                  SizedBox(
                    height: screenHeight * 0.06,
                    width: screenWidth * 0.7,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: const PersonalRegistrationPage()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // Button background
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Sign up",
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          color: const Color.fromARGB(
                              255, 0, 0, 0), // Button text color
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Continue as Guest Button (optional)
                  // SizedBox(
                  //   height: screenHeight * 0.06,
                  //   width: screenWidth * 0.7,
                  //   child: OutlinedButton(
                  //     onPressed: () {
                  //       Navigator.pushNamed(context, '/MainScreen');
                  //     },
                  //     style: OutlinedButton.styleFrom(
                  //         shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(30),
                  //         ),
                  //         side: const BorderSide(color: Colors.white),
                  //         backgroundColor: Colors.transparent),
                  //     child: Text(
                  //       "Continue as Guest",
                  //       style: GoogleFonts.poppins(
                  //         fontSize: 18.sp,
                  //         color: Colors.white,
                  //         fontWeight: FontWeight.w500,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
