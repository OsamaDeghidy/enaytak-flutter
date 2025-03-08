import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextStyle {
  final double fontsize;
  final FontWeight fontWeight;

  const CustomTextStyle({
    required this.fontsize,
    required this.fontWeight,
  });

  TextStyle getTextStyle({
    required BuildContext context,
    bool useThemeColor = true,
  }) {

    Color textColor = useThemeColor
        ? Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black
        : Colors.black;

    return GoogleFonts.inter(
      fontSize: fontsize,
      fontWeight: fontWeight,
      color: textColor,
    );
  }
}
