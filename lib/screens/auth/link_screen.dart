import 'dart:async';

import 'package:auth_firebase_demo/firebase/firebase_database.dart';
import 'package:auth_firebase_demo/route/route_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LinkScreen extends StatefulWidget {
  final String phone;
  const LinkScreen({Key? key, required this.phone}) : super(key: key);

  @override
  State<LinkScreen> createState() => _LinkScreenState();
}

class _LinkScreenState extends State<LinkScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  void showSnackBar(text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  bool _isLoad = false;
  bool _isDisable = false;
  bool _isOtpDisable = true;
  bool _isOtpLoad = false;
  bool _isPassVisible = true;
  int start = 30;
  late String _verificationId;
  Timer? _timer;

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

  void sendOTP() async {
    setState(() {
      _isOtpLoad = true;
      _isDisable = true;
    });
    String phone = "+91" + phoneController.text.trim();

    if (phoneController.text.trim().length != 10) {
      showSnackBar('Please Enter valid 10 digit number');
      setState(() {
        _isOtpLoad = false;
        _isDisable = false;
      });
    } else {
      QuerySnapshot<Map<String, dynamic>> snap =
          await FirebaseDatabase.getUserByPhone(phone);

      if (snap.docs.isEmpty) {
        await FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: phone,
            codeSent: (verificationId, resendToken) {
              _verificationId = verificationId;
              setState(() {
                _isOtpLoad = false;
                _isDisable = true;
                _isOtpDisable = false;
              });
              startTimer();
            },
            verificationCompleted: (credential) {},
            verificationFailed: (ex) {
              setState(() {
                _isOtpLoad = false;
                _isDisable = false;
              });
              showSnackBar(ex.code.toString());
            },
            codeAutoRetrievalTimeout: (verificationId) {},
            timeout: const Duration(seconds: 30));
      } else {
        showSnackBar('Phone Number is Already register');
        setState(() {
          _isOtpLoad = false;
          _isDisable = false;
        });
      }
    }
  }

  void verifyOTP() async {
    setState(() {
      _isLoad = true;
      _isOtpDisable = true;
    });
    String otp = otpController.text.trim();

    if (otp == '' || otp.length != 6) {
      showSnackBar('Please Enter 6 digit Otp');
      setState(() {
        _isLoad = false;
        _isOtpDisable = false;
      });
    } else {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId, smsCode: otp);

      try {
        final userCredential = await FirebaseAuth.instance.currentUser
            ?.linkWithCredential(credential);

        if (userCredential?.user != null) {
          User user = userCredential!.user!;

          await FirebaseDatabase.updatePhone(user.phoneNumber!, user.uid);
          // await FirebaseFirestore.instance
          //     .collection("users")
          //     .doc(user.uid)
          //     .update({"phone": user.phoneNumber});
          // .set({"phone": user.phoneNumber});

          setState(() {
            _isLoad = false;
            _isDisable = false;
            _isOtpDisable = true;
            _isOtpLoad = false;
          });
          GoRouter.of(context).replaceNamed(AppRouteConstant.home, extra: '2');
        } else {
          showSnackBar('user not fetch');
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          otpController.clear();
          _timer?.cancel();
          start = 30;
          _isLoad = false;
          _isOtpDisable = true;
          _isDisable = false;
          _isOtpLoad = false;
        });
        showSnackBar(e.code.toString());
      }
    }
  }

  void linkWithEmail() async {
    setState(() {
      _isLoad = true;
    });

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email == "" || password == "") {
      showSnackBar('Fill all details');
      setState(() {
        _isLoad = false;
      });
    } else {
      try {
        AuthCredential credential =
            EmailAuthProvider.credential(email: email, password: password);

        final userCredential = await FirebaseAuth.instance.currentUser
            ?.linkWithCredential(credential);
        if (userCredential?.user != null) {
          setState(() {
            _isLoad = false;
          });

          GoRouter.of(context).replaceNamed(AppRouteConstant.home, extra: '2');
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoad = false;
        });
        showSnackBar(e.code.toString());
      }
    }
  }

  void resendOtp() async {
    String phone = "+91" + phoneController.text.trim();
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
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
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context)
                .replaceNamed(AppRouteConstant.home, extra: '2');
          },
        ),
        title: const Text('Enter detail'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            widget.phone == 'true'
                ? Column(
                    children: [
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: "Phone Number"),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      CupertinoButton(
                        onPressed: _isDisable
                            ? null
                            : () {
                                sendOTP();
                              },
                        color: Colors.lightGreen,
                        child: !_isOtpLoad
                            ? const Text('Get Otp')
                            : const CircularProgressIndicator(),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text('Enter 6 digit otp'),
                      TextField(
                        keyboardType: TextInputType.number,
                        controller: otpController,
                        decoration: const InputDecoration(
                            labelText: "Enter 6 digit otp"),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CupertinoButton(
                              onPressed: start == 0
                                  ? () {
                                      setState(() {
                                        start = 30;
                                      });
                                      resendOtp();
                                      startTimer();
                                    }
                                  : null,
                              child: start == 0
                                  ? const Text(
                                      "Re-send",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.lightGreen),
                                    )
                                  : const Text("Re-send",
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black))),
                          Text('Otp in $start')
                        ],
                      ),
                      CupertinoButton(
                        onPressed: _isOtpDisable
                            ? null
                            : () {
                                verifyOTP();
                              },
                        color: Colors.lightGreen,
                        child: !_isLoad
                            ? const Text('Submit')
                            : const CircularProgressIndicator(),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      TextField(
                        controller: emailController,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        decoration:
                            const InputDecoration(labelText: "Email Address"),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        obscureText: _isPassVisible,
                        controller: passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                            labelText: "Password",
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isPassVisible = !_isPassVisible;
                                  });
                                },
                                icon: _isPassVisible
                                    ? const Icon(Icons.visibility)
                                    : const Icon(Icons.visibility_off))),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CupertinoButton(
                        onPressed: !_isLoad
                            ? () {
                                linkWithEmail();
                              }
                            : null,
                        color: Colors.lightGreen,
                        child: !_isLoad
                            ? const Text("Login")
                            : const CircularProgressIndicator(),
                      ),
                    ],
                  )
          ],
        ),
      ),
    );
  }
}
