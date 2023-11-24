import 'package:auth_firebase_demo/route/route_constant.dart';
import 'package:auth_firebase_demo/screens/auth/email_login_screen.dart';
import 'package:auth_firebase_demo/screens/auth/link_screen.dart';
import 'package:auth_firebase_demo/screens/auth/phone_login_screen.dart';
import 'package:auth_firebase_demo/screens/auth/register_email_screen.dart';
import 'package:auth_firebase_demo/screens/auth/register_phone_screen.dart';
import 'package:auth_firebase_demo/screens/auth/verify_otp_screen.dart';
import 'package:auth_firebase_demo/screens/home/home_screen.dart';
import 'package:auth_firebase_demo/screens/profile/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class AppRoute {
  GoRouter router = GoRouter(
    // redirect: (context, state) {
    //   User user = FirebaseAuth.instance.currentUser!;
    //   if (user != null) {
    //     return '/home';
    //   } else {
    //     return '/';
    //   }
    // },
    routes: [
      GoRoute(
          name: AppRouteConstant.emailLogin,
          path: '/email-login',
          builder: (context, state) {
            return const EmailLoginScreen();
          }),
      GoRoute(
          name: AppRouteConstant.emailRegistration,
          path: '/email-registration',
          builder: (context, state) {
            return const RegisterEmailScreen();
          }),
      GoRoute(
          name: AppRouteConstant.phoneLogin,
          path: '/',
          builder: (context, state) {
            // return const PhoneLoginScreen();
            return (FirebaseAuth.instance.currentUser != null)
                ? const HomeScreen()
                : const PhoneLoginScreen();
          }),
      GoRoute(
          name: AppRouteConstant.phoneRegistration,
          path: '/phone-registration',
          builder: (context, state) {
            return const RegisterPhoneScreen();
          }),
      GoRoute(
          name: AppRouteConstant.home,
          path: '/home',
          builder: (context, state) {
            return HomeScreen(
              selectedScreen: state.extra as String,
              // reload: state.pathParameters['reload'],
            );
          }),
      GoRoute(
          name: AppRouteConstant.verifyOtp,
          path: '/verify-otp/:verificationId/:phoneNumber',
          builder: (context, state) {
            return VerifyOtpScreen(
              verificationId: state.pathParameters['verificationId']!,
              phoneNumber: state.pathParameters['phoneNumber']!,
              isLoginScreen: state.extra as List,
            );
          }),
      GoRoute(
          name: AppRouteConstant.link,
          path: '/link-screen/:phone',
          builder: (context, state) {
            return LinkScreen(
              phone: state.pathParameters['phone']!,
            );
          }),
      GoRoute(
          name: AppRouteConstant.profileScreen,
          path: '/profile/:reload',
          builder: (context, state) {
            return ProfileScreen(
              reload: state.pathParameters['reload'],
            );
          }),
    ],
    // redirect: (context, state) {
    //   if (FirebaseAuth.instance.currentUser!=null) {
    //     return context.namedLocation(AppRouteConstant.home);
    //   } else {
    //     return null;
    //   }
    // },
  );
}
