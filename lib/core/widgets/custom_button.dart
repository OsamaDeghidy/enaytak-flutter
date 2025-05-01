import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/constant.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CustomButtonNew extends StatelessWidget {
  const CustomButtonNew({
    super.key,
    this.foregroundColor,
    this.backgroundColor,
    required this.title,
    this.onPressed,
    required this.isLoading,
    required this.isBackgroundPrimary,
    this.width,
    this.height,
  });
  final Color? foregroundColor;
  final Color? backgroundColor;
  final String title;
  final Function()? onPressed;
  final bool isLoading;
  final bool isBackgroundPrimary;
  final double? width;
  final double? height;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Constant.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Constant.disabledButtonColor,
        ),
        child: isLoading
            ? Center(
                child: LoadingAnimationWidget.fallingDot(
                  color: isBackgroundPrimary
                      ? Constant.whiteColor
                      : Constant.primaryColor,
                  size: 30,
                ),
              )
            : Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: foregroundColor ?? Constant.whiteColor,
                ),
              ),
      ),
    );
  }
}
