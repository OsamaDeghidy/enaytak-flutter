import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

abstract class AppHelper {
  static errorSnackBar({
    required BuildContext context,
    required String message,
  }) {
    return showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.error(maxLines: 3, message: message),
    );
  }

  static successSnackBar({
    required BuildContext context,
    required String message,
  }) {
    return showTopSnackBar(
      Overlay.of(context),
      CustomSnackBar.success(maxLines: 2, message: message),
    );
  }
}
