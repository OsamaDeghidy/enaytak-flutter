import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomButton extends StatelessWidget {
  final String text; // Text to display on the button
  final Color color; // Color of the button
  final VoidCallback onPressed; // Function to execute when the button is pressed
  final double? height; // Height of the button
  final double? width; // Width of the button

  // Constructor for the custom button widget
  const CustomButton({
    super.key,
    required this.text,
    required this.color,
    required this.onPressed,
    this.height, // Optional height
    this.width,  // Optional width
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        minimumSize: Size(width ?? double.infinity, height ?? 50),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 18.sp,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
      ),
    );
  }
}
