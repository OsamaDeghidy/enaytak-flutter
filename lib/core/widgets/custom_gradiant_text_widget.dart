import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/constant.dart';

class CustomGradiantTextWidget extends StatelessWidget {
  const CustomGradiantTextWidget(
      {super.key, required this.text, required this.fontSize, this.fontWeight});
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: Constant.gradientPrimaryColors,
        ).createShader(bounds);
      },
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: Colors.white,
        ),
      ),
    );
  }
}
