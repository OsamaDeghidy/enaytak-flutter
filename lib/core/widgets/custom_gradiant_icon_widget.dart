import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/constant.dart';

class CustomGradiantIconWidget extends StatelessWidget {
  const CustomGradiantIconWidget({
    super.key,
    required this.icon,
    this.iconSize,
  });
  final IconData icon;
  final double? iconSize;
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
      child: Icon(
        icon,
        size: iconSize,
        color: Colors.white,
      ),
    );
  }
}
