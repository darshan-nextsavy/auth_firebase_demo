import 'package:auth_firebase_demo/firebase/firebase_database.dart';
import 'package:auth_firebase_demo/screens/auth/verify_otp_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../route/route_constant.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({Key? key}) : super(key: key);

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  TextEditingController phoneController = TextEditingController();
  bool _isLoad = false;

  void showSnackBar(text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void sendOTP() async {
    setState(() {
      _isLoad = true;
    });
    String phone = "+91" + phoneController.text.trim();

    if (phoneController.text.trim().length != 10) {
      showSnackBar('Please Enter valid 10 digit number');
      setState(() {
        _isLoad = false;
      });
    } else {
      QuerySnapshot<Map<String, dynamic>> snap =
          await FirebaseDatabase.getUserByPhone(phone);

      if (snap.docs.isEmpty) {
        showSnackBar('Please register first');
        setState(() {
          _isLoad = false;
        });
      } else {
        await FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: phone,
            codeSent: (verificationId, resendToken) {
              setState(() {
                _isLoad = false;
              });

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VerifyOtpScreen(
                            verificationId: verificationId,
                            phoneNumber: phone,
                            isLoginScreen: const ['loginScreen', 'false'],
                          )));

              // Get.off((_) => VerifyOtpScreen(
              //       verificationId: verificationId,
              //       phoneNumber: phone,
              //       isLoginScreen: ['loginScreen', 'false'],
              //     ));
              // GoRouter.of(context).pushNamed(AppRouteConstant.verifyOtp,
              //     pathParameters: {
              //       'verificationId': verificationId,
              //       'phoneNumber': phone
              //     },
              //     extra: [
              //       'loginScreen',
              //       'false'
              //     ]);
            },
            verificationCompleted: (credential) {},
            verificationFailed: (ex) {
              setState(() {
                _isLoad = false;
              });
              showSnackBar(ex.code.toString());
            },
            codeAutoRetrievalTimeout: (verificationId) {},
            timeout: const Duration(seconds: 30));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f0f0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Sign In with Phone"),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: phoneController,
                    decoration:
                        const InputDecoration(labelText: "Phone Number"),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CupertinoButton(
                    onPressed: !_isLoad
                        ? () {
                            sendOTP();
                          }
                        : null,
                    color: Colors.lightGreen,
                    child: !_isLoad
                        ? const Text("Login")
                        : const CircularProgressIndicator(),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CupertinoButton(
                    onPressed: () {
                      GoRouter.of(context)
                          .replaceNamed(AppRouteConstant.emailLogin);
                    },
                    child: const Text("Login with Email"),
                  ),
                  const Text(
                    'Or',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      GoRouter.of(context)
                          .pushNamed(AppRouteConstant.phoneRegistration);
                    },
                    child: const Text("Create Account"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
