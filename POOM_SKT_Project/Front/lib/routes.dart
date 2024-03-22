import 'package:flutter/widgets.dart';
import 'package:shop_app/screens/products/products_screen.dart';
import 'package:shop_app/screens/voicemail/voicemail_screen.dart'; // VoicemailScreen import

// 추가된 import 구문
import 'package:shop_app/screens/chat/chat_screen.dart'; // ChatScreen import
import 'package:shop_app/screens/voicerecord/voicerecord_screen.dart'; // VoiceRecordScreen import
import 'package:shop_app/screens/sharedcalender_screen/sharedcalender_screen.dart'; // SharedCalenderScreen import 추가

import 'screens/complete_profile/complete_profile_screen.dart';
import 'screens/details/details_screen.dart';
import 'screens/forgot_password/forgot_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/init_screen.dart';
import 'screens/login_success/login_success_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/sign_in/sign_in_screen.dart';
import 'screens/sign_up/sign_up_screen.dart';
import 'screens/splash/splash_screen.dart';
// import 'main.dart';

final Map<String, WidgetBuilder> routes = {
  InitScreen.routeName: (context) => const InitScreen(),
  SplashScreen.routeName: (context) => const SplashScreen(),
  SignInScreen.routeName: (context) => const SignInScreen(),
  ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
  LoginSuccessScreen.routeName: (context) => const LoginSuccessScreen(),
  SignUpScreen.routeName: (context) => const SignUpScreen(),
  CompleteProfileScreen.routeName: (context) => const CompleteProfileScreen(),
  HomeScreen.routeName: (context) => const HomeScreen(),
  ProductsScreen.routeName: (context) => const ProductsScreen(),
  DetailsScreen.routeName: (context) => const DetailsScreen(),
  ProfileScreen.routeName: (context) => const ProfileScreen(),
  VoicemailScreen.routeName: (context) => const VoicemailScreen(),
  ChatScreen.routeName: (context) => const ChatScreen(),
  VoiceRecordScreen.routeName: (context) => const VoiceRecordScreen(),
  SharedCalenderScreen.routeName: (context) => const SharedCalenderScreen(), // SharedCalenderScreen 라우트 추가
  // MyHomePage.routeName: (context) => MyHomePage(),
};
