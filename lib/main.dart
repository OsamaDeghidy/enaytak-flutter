import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_sanar_proj/PATIENT/Login-Signup/Login-Signup/login.dart';
import 'package:flutter_sanar_proj/PATIENT/Login-Signup/Login-Signup/login_signup.dart';
import 'package:flutter_sanar_proj/PATIENT/On_Board/on_boarding.dart';
import 'package:flutter_sanar_proj/PATIENT/Screens/HomeScreen.dart';
import 'package:flutter_sanar_proj/PATIENT/Screens/Screen1.dart';
import 'package:flutter_sanar_proj/PATIENT/Screens/SettingPage.dart';
import 'package:flutter_sanar_proj/PATIENT/User_Profile/user_profileScreen.dart';
import 'package:flutter_sanar_proj/PATIENT/Widgets/Constant_Widgets/custom_bottomNAVbar.dart';
import 'package:flutter_sanar_proj/STTAFF/Staff_Registration/Staff_Selection_Screen.dart';
import 'package:flutter_sanar_proj/STTAFF/Widgets/customDoctor_bottomNAVbar.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize flutter_inappwebview
  await InAppWebViewController.setWebContentsDebuggingEnabled(true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: '/screen1',
          routes: {
            '/screen1': (context) => const Screen1(),
            '/on_boarding': (context) => const on_boarding(),
            '/Login_Signup': (context) => const LoginSignup(),
            '/Login': (context) => const Login(),
            '/settingPage': (context) => const SettingPage(),
            '/HomePage': (context) => HomePage(),
            '/MainScreen': (context) => const MainScreen(),
            '/UserProfileScreen': (context) => const UserProfileScreen(),
            '/StaffSelectionScreen': (context) => const StaffSelectionScreen(),
            '/StaffMainScreen': (context) => const StaffMainScreen(),
          },
        );
      },
    );
  }
}