import 'dart:async';
import 'dart:io';

import 'package:auth_firebase_demo/route/route_constant.dart';
import 'package:auth_firebase_demo/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../firebase/firebase_database.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final List? isLoginScreen;
  const VerifyOtpScreen(
      {Key? key,
      required this.verificationId,
      this.isLoginScreen,
      required this.phoneNumber})
      : super(key: key);

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  void showSnackBar(text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  TextEditingController otpController = TextEditingController();
  bool _isLoad = false;
  late String _phoneNumber;
  late String _verificationId;
  Timer? _timer;

  int start = 30;
  void startTimer() {
    const onesec = Duration(seconds: 1);
    _timer = Timer.periodic(onesec, (timer) {
      if (start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          start--;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _phoneNumber = widget.phoneNumber;
    _verificationId = widget.verificationId;
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void verifyOTP() async {
    setState(() {
      _isLoad = true;
    });
    String otp = otpController.text.trim();

    if (otp == '' || otp.length != 6) {
      showSnackBar('Please Enter 6 digit Otp');
      setState(() {
        _isLoad = false;
      });
    } else {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId, smsCode: otp);

      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        if (userCredential.user != null) {
          User user = userCredential.user!;

          if (widget.isLoginScreen![0] == 'registerScreen') {
            if (widget.isLoginScreen!.length == 3 &&
                widget.isLoginScreen![2] != null) {
              String profileUrl = await FirebaseDatabase.uploadImageToFirebase(
                  File(widget.isLoginScreen![2]));
              if (profileUrl != 'error') {
                FirebaseDatabase.addUserWithProfile(user.uid, user.phoneNumber!,
                    profileUrl, widget.isLoginScreen![1]);

                // await FirebaseFirestore.instance
                //     .collection("users")
                //     .doc(user.uid)
                //     .set({
                //   "phone": user.phoneNumber,
                //   "name": widget.isLoginScreen![1],
                //   "profileUrl": profileUrl
                // });
              }
            } else {
              FirebaseDatabase.addUserWithOutProfile(
                  user.uid, user.phoneNumber!, widget.isLoginScreen![1]);
              // await FirebaseFirestore.instance
              //     .collection("users")
              //     .doc(user.uid)
              //     .set({
              //   "phone": user.phoneNumber,
              //   "name": widget.isLoginScreen![1]
              // });
            }
          }

          setState(() {
            _isLoad = false;
          });

          while (Navigator.canPop(context)) {
            Navigator.pop(context);
          }

          // GoRouter.of(context).replaceNamed(AppRouteConstant.home,
          //     pathParameters: {'reload': 'notReload'});
          // print(user.);

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomeScreen(
                        selectedScreen: '0',
                      )));

          // Get.offAll((_) => const HomeScreen(
          //       selectedScreen: '0',
          //     ));
          // GoRouter.of(context).replaceNamed(AppRouteConstant.home, extra: '0');
        }
      } on FirebaseAuthException catch (ex) {
        showSnackBar(ex.code.toString());
        setState(() {
          _isLoad = false;
        });
      }
    }
  }

  void resendOtp() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneNumber,
        codeSent: (verificationId, resendToken) {
          _verificationId = verificationId;
        },
        verificationCompleted: (credential) {},
        verificationFailed: (ex) {
          showSnackBar(ex.code.toString());
        },
        codeAutoRetrievalTimeout: (verificationId) {},
        timeout: const Duration(seconds: 30));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f0f0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text("Verify OTP"),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  TextField(
                    controller: otpController,
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: "6-Digit OTP", counterText: ""),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CupertinoButton(
                        onPressed: start == 0
                            ? () {
                                resendOtp();
                                setState(() {
                                  start = 30;
                                });
                                startTimer();
                              }
                            : null,
                        child: Text(
                          'Re-send',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: start == 0
                                  ? Colors.lightGreen
                                  : Colors.black),
                        ),
                      ),
                      start == 0 ? Container() : Text('otp in $start'),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CupertinoButton(
                    onPressed: !_isLoad
                        ? () {
                            verifyOTP();
                          }
                        : null,
                    color: Colors.lightGreen,
                    child: !_isLoad
                        ? const Text("Verify")
                        : const CircularProgressIndicator(),
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
