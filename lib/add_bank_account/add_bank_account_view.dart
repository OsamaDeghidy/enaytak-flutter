import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/constant.dart';
import 'package:flutter_sanar_proj/core/widgets/custom_button.dart';
import 'package:flutter_sanar_proj/core/widgets/custom_gradiant_text_widget.dart';
import 'package:flutter_sanar_proj/core/widgets/custom_text_form_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/helper/app_helper.dart';
import '../core/helper/validators.dart';
import 'service/bank_accoutn_service.dart';

class AddBankAccountView extends StatefulWidget {
  const AddBankAccountView({super.key});

  @override
  State<AddBankAccountView> createState() => _AddBankAccountViewState();
}

class _AddBankAccountViewState extends State<AddBankAccountView> {
  final _cardHolderNameController = TextEditingController();
  // final _cardNumberController = TextEditingController();
  // final _expiryDateController = TextEditingController();
  // final _cvvController = TextEditingController();
  final _ibanController = TextEditingController();
  final _bankNameController = TextEditingController();
  // final _userNameController = TextEditingController();
  final _userAddressController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  int? userId;
  String? token;
  @override
  void initState() {
    // TODO: implement initState
    getUserId();
    super.initState();
  }

  getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    token = prefs.getString('access');
    debugPrint('userId: $userId');
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        await ApiServiceForBankAccount.addBankAccount(
          iban: _ibanController.text,
          cardHolderName: _cardHolderNameController.text,
          bankName: _bankNameController.text,
          userId: userId.toString(),
          context: context,
          token: token ?? '',
        );
      } catch (e) {
        debugPrint("Submission Error: $e");
        AppHelper.errorSnackBar(context: context, message: 'Unexpected error');
      }

      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.whiteColor,
      appBar: AppBar(
        backgroundColor: Constant.whiteColor,
        title: const CustomGradiantTextWidget(
            text: 'Add Bank Account', fontSize: 22),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const CustomGradiantTextWidget(text: 'IBAN', fontSize: 16),
                const SizedBox(height: 10),
                CustomTextFormField(
                  hint: 'IBAN',
                  inputType: TextInputType.number,
                  validation: AppValidators.isValidIban,
                  controller: _ibanController,
                  maxLength: 34,
                ),
                const SizedBox(height: 10),
                const CustomGradiantTextWidget(text: 'Bank Name', fontSize: 16),
                const SizedBox(height: 10),
                CustomTextFormField(
                  hint: 'Bank Name',
                  inputType: TextInputType.name,
                  validation: AppValidators.isNotEmptyValidator,
                  controller: _bankNameController,
                ),
                const SizedBox(height: 10),
                const CustomGradiantTextWidget(
                    text: 'Card Holder Name', fontSize: 16),
                const SizedBox(height: 10),
                CustomTextFormField(
                  hint: 'Card Holder Name',
                  inputType: TextInputType.name,
                  validation: AppValidators.isNotEmptyValidator,
                  controller: _cardHolderNameController,
                ),
                // const SizedBox(height: 20),
                // const CustomGradiantTextWidget(
                //     text: 'Card Number', fontSize: 16),
                // const SizedBox(height: 10),
                // CustomTextFormField(
                //   hint: 'Card Number',
                //   inputType: TextInputType.number,
                //   maxLength: 16,
                //   validation: AppValidators.isNotEmptyValidator,
                //   controller: _cardNumberController,
                // ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         const CustomGradiantTextWidget(
                //             text: 'Expiry Date', fontSize: 16),
                //         const SizedBox(height: 10),
                //         SizedBox(
                //           width: MediaQuery.sizeOf(context).width / 2 - 30,
                //           child: CustomTextFormField(
                //             hint: 'MM/YY',
                //             inputType: TextInputType.number,
                //             validation: AppValidators.isNotEmptyValidator,
                //             controller: _expiryDateController,
                //             inputFormatters: [
                //               FilteringTextInputFormatter
                //                   .digitsOnly, // Ensure only digits can be entered
                //               ExpiryDateFormatter(), // Use the custom formatter
                //             ],
                //           ),
                //         ),
                //       ],
                //     ),
                //     Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         const CustomGradiantTextWidget(
                //             text: 'CVV', fontSize: 16),
                //         const SizedBox(height: 10),
                //         SizedBox(
                //           width: MediaQuery.sizeOf(context).width / 2 - 30,
                //           child: CustomTextFormField(
                //             hint: 'CVV',
                //             inputType: TextInputType.number,
                //             maxLength: 3,
                //             validation: AppValidators.isNotEmptyValidator,
                //             controller: _cvvController,
                //           ),
                //         ),
                //       ],
                //     )
                //   ],
                // ),
                // const CustomGradiantTextWidget(text: 'Your Name', fontSize: 16),
                // const SizedBox(height: 10),
                // CustomTextFormField(
                //   hint: 'Your Name',
                //   inputType: TextInputType.name,
                //   validation: AppValidators.isNotEmptyValidator,
                //   controller: _userNameController,
                // ),
                const SizedBox(height: 10),
                const CustomGradiantTextWidget(
                    text: 'Your Address', fontSize: 16),
                const SizedBox(height: 10),
                CustomTextFormField(
                  hint: 'Your Address',
                  inputType: TextInputType.multiline,
                  validation: AppValidators.isNotEmptyValidator,
                  controller: _userAddressController,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding:
            const EdgeInsetsDirectional.symmetric(horizontal: 20, vertical: 20),
        child: CustomButtonNew(
          title: 'Confirm',
          isLoading: _isSubmitting,
          isBackgroundPrimary: true,
          onPressed: () {
            _submitForm();
          },
        ),
      ),
    );
  }
}
