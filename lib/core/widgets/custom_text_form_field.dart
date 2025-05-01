import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constant.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField(
      {super.key,
      this.hint,
      this.maxLines,
      this.readOnly,
      this.onTap,
      this.inputType,
      this.validation,
      this.onChanged,
      this.inputFormatters,
      this.maxLength,
      this.focusNode,
      this.controller});
  final TextEditingController? controller;
  final String? hint;
  final int? maxLines;
  final bool? readOnly;
  final Function()? onTap;
  final TextInputType? inputType;
  final String? Function(String?)? validation;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final FocusNode? focusNode;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: inputType,
      onTap: onTap,
      validator: validation,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      focusNode: focusNode,
      cursorColor: Constant.primaryColor,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Constant.primaryColor),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Constant.disabledButtonColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Constant.disabledButtonColor,
          ),
        ),
        hintText: hint,
        hintStyle: const TextStyle(color: Constant.hintColor),
      ),
    );
  }
}
