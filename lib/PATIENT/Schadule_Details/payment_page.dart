import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Colors/colors.dart';
import 'package:myfatoorah_flutter/MFUtils.dart';
import 'package:myfatoorah_flutter/myfatoorah_flutter.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String? _response = '';
  MFInitiateSessionResponse? session;

  List<MFPaymentMethod> paymentMethods = [];
  List<bool> isSelected = [];
  int selectedPaymentMethodIndex = -1;

  String amount = "5.00";
  bool visibilityObs = false;
  late MFCardPaymentView mfCardView;
  late MFApplePayButton mfApplePayButton;
  late MFGooglePayButton mfGooglePayButton;

  @override
  void initState() {
    super.initState();
    initiate();
  }

  @override
  void dispose() {
    super.dispose();
  }

  initiate() async {
    // if (Config.testAPIKey.isEmpty) {
    //   setState(() {
    //     _response =
    //         "Missing API Token Key.. You can get it from here: https://myfatoorah.readme.io/docs/test-token";
    //   });
    //   return;
    // }

    // TODO, don't forget to init the MyFatoorah Plugin with the following line
    await MFSDK.init(
      'rLtt6JWvbUHDDhsZnfpAhpYk4dxYDQkbcPTyGaKp2TYqQgG7FGZ5Th_WD53Oq8Ebz6A53njUoo1w3pjU1D4vs_ZMqFiz_j0urb_BH9Oq9VZoKFoJEDAbRZepGcQanImyYrry7Kt6MnMdgfG5jn4HngWoRdKduNNyP4kzcp3mRv7x00ahkm9LAK7ZRieg7k1PDAnBIOG3EyVSJ5kK4WLMvYr7sCwHbHcu4A5WwelxYK0GMJy37bNAarSJDFQsJ2ZvJjvMDmfWwDVFEVe_5tOomfVNt6bOg9mexbGjMrnHBnKnZR1vQbBtQieDlQepzTZMuQrSuKn-t5XZM7V6fCW7oP-uXGX-sMOajeX65JOf6XVpk29DP6ro8WTAflCDANC193yof8-f5_EYY-3hXhJj7RBXmizDpneEQDSaSz5sFk0sV5qPcARJ9zGG73vuGFyenjPPmtDtXtpx35A-BVcOSBYVIWe9kndG3nclfefjKEuZ3m4jL9Gg1h2JBvmXSMYiZtp9MR5I6pvbvylU_PP5xJFSjVTIz7IQSjcVGO41npnwIxRXNRxFOdIUHn0tjQ-7LwvEcTXyPsHXcMD8WtgBh-wxR8aKX7WPSsT1O8d8reb2aR7K3rkV3K82K_0OgawImEpwSvp9MNKynEAJQS6ZHe_J_l77652xwPNxMRTMASk1ZsJL',
      MFCountry.KUWAIT,
      MFEnvironment.TEST,
    );
    // (Optional) un comment the following lines if you want to set up properties of AppBar.
    // MFSDK.setUpActionBar(
    //     toolBarTitle: 'Company Payment',
    //     toolBarTitleColor: '#FFEB3B',
    //     toolBarBackgroundColor: '#CA0404',
    //     isShowToolBar: true);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initiateSessionForCardView();
      await initiateSessionForGooglePay();
      await initiatePayment();
      // await initiateSession();
    });
  }

  log(Object object) {
    var json = const JsonEncoder.withIndent('  ').convert(object);
    setState(() {
      debugPrint(json);
      _response = json;
    });
  }

  // Initiate Payment
  initiatePayment() async {
    var request = MFInitiatePaymentRequest(
      invoiceAmount: double.parse(amount),
      currencyIso: MFCurrencyISO.SAUDIARABIA_SAR,
    );

    await MFSDK
        .initiatePayment(request, MFLanguage.ENGLISH)
        .then(
          (value) => {
            log(value),
            paymentMethods.addAll(value.paymentMethods!),
            for (int i = 0; i < paymentMethods.length; i++)
              isSelected.add(false),
          },
        )
        .catchError((error) => {log(error.message)});
  }

  // Execute Regular Payment
  executeRegularPayment(int paymentMethodId) async {
    var request = MFExecutePaymentRequest(
      paymentMethodId: paymentMethodId,
      invoiceValue: double.parse(amount),
    );
    request.displayCurrencyIso = MFCurrencyISO.SAUDIARABIA_SAR;

    // var recurring = MFRecurringModel();
    // recurring.intervalDays = 10;
    // recurring.recurringType = MFRecurringType.Custom;
    // recurring.iteration = 2;
    // request.recurringModel = recurring;

    await MFSDK
        .executePayment(request, MFLanguage.ENGLISH, (invoiceId) {
          debugPrint(' invoiceId $invoiceId success payment ');
          //TODO: Success Case Here
          log(invoiceId);
        })
        .then((value) => log(value))
        .catchError((error) => {log(error.message)});
  }

  setPaymentMethodSelected(int index, bool value) {
    for (int i = 0; i < isSelected.length; i++) {
      if (i == index) {
        isSelected[i] = value;
        if (value) {
          selectedPaymentMethodIndex = index;
          visibilityObs = paymentMethods[index].isDirectPayment!;
        } else {
          selectedPaymentMethodIndex = -1;
          visibilityObs = false;
        }
      } else {
        isSelected[i] = false;
      }
    }
  }

  executePayment() {
    if (selectedPaymentMethodIndex == -1) {
      setState(() {
        _response = "Please select payment method first";
      });
    } else {
      if (amount.isEmpty) {
        setState(() {
          _response = "Set the amount";
        });
      } else {
        executeRegularPayment(
          paymentMethods[selectedPaymentMethodIndex].paymentMethodId!,
        );
      }
    }
  }

  MFCardViewStyle cardViewStyle() {
    MFCardViewStyle cardViewStyle = MFCardViewStyle();
    cardViewStyle.cardHeight = 240;
    cardViewStyle.hideCardIcons = false;
    cardViewStyle.backgroundColor = getColorHexFromStr("#ccd9ff");
    cardViewStyle.input?.inputMargin = 3;
    cardViewStyle.label?.display = true;
    cardViewStyle.input?.fontFamily = MFFontFamily.TimesNewRoman;
    cardViewStyle.label?.fontWeight = MFFontWeight.Light;
    cardViewStyle.savedCardText?.saveCardText = "حفظ بيانات البطاقة";
    cardViewStyle.savedCardText?.addCardText = "استخدام كارت اخر";
    MFDeleteAlert deleteAlertText = MFDeleteAlert();
    deleteAlertText.title = "حذف البطاقة";
    deleteAlertText.message = "هل تريد حذف البطاقة";
    deleteAlertText.confirm = "نعم";
    deleteAlertText.cancel = "لا";
    cardViewStyle.savedCardText?.deleteAlertText = deleteAlertText;
    return cardViewStyle;
  }

  initiateSessionForCardView() async {
    /*
      If you want to use saved card option with embedded payment, send the parameter
      "customerIdentifier" with a unique value for each customer. This value cannot be used
      for more than one Customer.
     */
    // var request = MFInitiateSessionRequest("12332212");
    /*
      If not, then send null like this.
     */
    MFInitiateSessionRequest initiateSessionRequest = MFInitiateSessionRequest(
      customerIdentifier: "123",
    );

    await MFSDK
        .initSession(initiateSessionRequest, MFLanguage.ENGLISH)
        .then((value) => loadEmbeddedPayment(value))
        .catchError((error) => {log(error.message)});
  }

  loadCardView(MFInitiateSessionResponse session) {
    mfCardView.load(session, (bin) {
      log(bin);
    });
  }

  loadEmbeddedPayment(MFInitiateSessionResponse session) async {
    MFExecutePaymentRequest executePaymentRequest = MFExecutePaymentRequest(
      invoiceValue: 10,
    );
    executePaymentRequest.displayCurrencyIso = MFCurrencyISO.SAUDIARABIA_SAR;
    await loadCardView(session);
    if (Platform.isIOS) {
      applePayPayment(session);
    }
  }

  applePayPayment(MFInitiateSessionResponse session) async {
    MFExecutePaymentRequest executePaymentRequest = MFExecutePaymentRequest(
      invoiceValue: 0.01,
    );
    executePaymentRequest.displayCurrencyIso = MFCurrencyISO.SAUDIARABIA_SAR;

    await mfApplePayButton
        .displayApplePayButton(
          session,
          executePaymentRequest,
          MFLanguage.ENGLISH,
        )
        .then(
          (value) => {
            log(value),
            // mfApplePayButton
            //     .executeApplePayButton(null, (invoiceId) => log(invoiceId))
            //     .then((value) => log(value))
            //     .catchError((error) => {log(error.message)})
          },
        )
        .catchError((error) => {log(error.message)});
  }

  pay() async {
    var executePaymentRequest = MFExecutePaymentRequest(invoiceValue: 10);

    await mfCardView
        .pay(executePaymentRequest, MFLanguage.ENGLISH, (invoiceId) {
          debugPrint("-----------$invoiceId------------");
          log(invoiceId);
        })
        .then((value) => log(value))
        .catchError((error) => {log(error.message)});
  }

  // GooglePay Section
  initiateSessionForGooglePay() async {
    MFInitiateSessionRequest initiateSessionRequest = MFInitiateSessionRequest(
      // A uniquue value for each customer must be added
      customerIdentifier: "12332212",
    );

    await MFSDK
        .initSession(initiateSessionRequest, MFLanguage.ENGLISH)
        .then((value) => {setupGooglePayHelper(value.sessionId)})
        .catchError((error) => {log(error.message)});
  }

  setupGooglePayHelper(String sessionId) async {
    MFGooglePayRequest googlePayRequest = MFGooglePayRequest(
      totalPrice: "1",
      merchantId: null,
      merchantName: "Test Vendor",
      countryCode: MFCountry.KUWAIT,
      currencyIso: MFCurrencyISO.UAE_AED,
    );

    await mfGooglePayButton
        .setupGooglePayHelper(sessionId, googlePayRequest, (invoiceId) {
          log("-----------Invoice Id: $invoiceId------------");
        })
        .then((value) => log(value))
        .catchError((error) => {log(error.message)});
  }
  //#region aaa

  //endregion

  // UI Section
  @override
  Widget build(BuildContext context) {
    mfCardView = MFCardPaymentView(cardViewStyle: cardViewStyle());
    mfApplePayButton = MFApplePayButton(applePayStyle: MFApplePayStyle());
    mfGooglePayButton = const MFGooglePayButton();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Select payment method", style: textStyle()),
        //   title: const Text('Plugin example app'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  paymentMethodsList(),

                  // btn("Reload GooglePay", initiateSessionForGooglePay),
                  // ColoredBox(
                  //   color: const Color(0xFFD8E5EB),
                  //   child: SelectableText.rich(
                  //     TextSpan(
                  //       text: _response!,
                  //       style: const TextStyle(),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: selectedPaymentMethodIndex != -1
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: btn("Execute Payment", executePayment),
            )
          : null,
    );
  }

  Widget embeddedCardView() {
    return Column(
      children: [
        SizedBox(height: 180, child: mfCardView),
        Row(
          children: [
            const SizedBox(width: 2),
            Expanded(child: elevatedButton("Pay", pay)),
            const SizedBox(width: 2),
            elevatedButton("", initiateSessionForCardView),
          ],
        ),
      ],
    );
  }

  Widget applePayView() {
    return Column(children: [SizedBox(height: 50, child: mfApplePayButton)]);
  }

  Widget googlePayButton() {
    return SizedBox(height: 70, child: mfGooglePayButton);
  }

  Widget paymentMethodsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      itemCount: paymentMethods.length,
      itemBuilder: (BuildContext ctxt, int index) {
        return paymentMethodsItem(ctxt, index);
      },
    );
  }

  Widget paymentMethodsItem(BuildContext ctxt, int index) {
    return Container(
      margin: const EdgeInsetsDirectional.symmetric(vertical: 8),
      padding:
          const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 8),
      decoration: isSelected[index]
          ? BoxDecoration(
              border: Border.all(color: primaryColor, width: 2),
              borderRadius: BorderRadius.circular(8))
          : BoxDecoration(
              border:
                  Border.all(color: greyColor.withValues(alpha: 0.3), width: 1),
              borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Row(
          children: <Widget>[
            Image.network(paymentMethods[index].imageUrl!, height: 35.0),
            const SizedBox(
              width: 10,
            ),
            Text(
              paymentMethods[index].paymentMethodEn ?? "",
              style: TextStyle(
                fontSize: 12.0,
                fontWeight:
                    isSelected[index] ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            SizedBox(
              height: 24.0,
              width: 24.0,
              child: Checkbox(
                checkColor: primaryColor,
                activeColor: Colors.white,
                value: isSelected[index],
                onChanged: (bool? value) {
                  setState(() {
                    setPaymentMethodSelected(index, value!);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget btn(String title, Function onPressed) {
    return SizedBox(
      width: double.infinity, // <-- match_parent
      child: elevatedButton(title, onPressed),
    );
  }

  Widget elevatedButton(String title, Function onPressed) {
    return ElevatedButton(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
        backgroundColor: WidgetStateProperty.all<Color>(primaryColor),
        shape: WidgetStateProperty.resolveWith<RoundedRectangleBorder>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.pressed)) {
            return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: const BorderSide(color: Colors.red, width: 1.0),
            );
          } else {
            return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: const BorderSide(color: Colors.white, width: 1.0),
            );
          }
        }),
      ),
      child: (title.isNotEmpty)
          ? Text(title, style: textStyle())
          : const Icon(Icons.refresh),
      onPressed: () async {
        await onPressed();
      },
    );
  }

  Widget amountInput() {
    return TextField(
      style: const TextStyle(color: Colors.white),
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      controller: TextEditingController(text: amount),
      decoration: const InputDecoration(
        filled: true,
        fillColor: Color(0xff0495ca),
        hintText: "0.00",
        contentPadding: EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1.0),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
      onChanged: (value) {
        amount = value;
      },
    );
  }

  TextStyle textStyle() {
    return const TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic);
  }
}
