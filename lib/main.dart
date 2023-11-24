import 'package:auth_firebase_demo/route/route_config.dart';
import 'package:auth_firebase_demo/screens/auth/phone_login_screen.dart';
import 'package:auth_firebase_demo/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // routerDelegate: AppRoute().router,
      home: FirebaseAuth.instance.currentUser != null
          ? const HomeScreen(selectedScreen: '0')
          : const PhoneLoginScreen(),
    );
    // return MaterialApp.router(
    //   title: 'Flutter Demo',
    //   debugShowCheckedModeBanner: false,
    //   theme: ThemeData(
    //     colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
    //     useMaterial3: true,
    //   ),
    //   routerConfig: AppRoute().router,
    //   // home: HomeScreen(),
    // );
  }
}
