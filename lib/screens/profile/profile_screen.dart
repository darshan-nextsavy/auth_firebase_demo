import 'dart:async';
import 'dart:io';

import 'package:auth_firebase_demo/route/route_constant.dart';
import 'package:auth_firebase_demo/screens/auth/phone_login_screen.dart';
import 'package:auth_firebase_demo/screens/utils/bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../firebase/firebase_database.dart';

class ProfileScreen extends StatefulWidget {
  final String? reload;
  const ProfileScreen({Key? key, this.reload}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  String? email;
  String? phone;
  String? name;
  bool _isImageLoad = false;
  bool _isNameLoad = false;
  // bool _isLoad = false;
  // bool _isCurrentPass = true;
  // bool _isNewPass = true;
  File? profileImage;
  String? profileUrl;

  // this is not use currently
  TextEditingController currentPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();

  // this is use for show detail
  TextEditingController readEmailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController readPhoneController = TextEditingController();

  // this is for link email
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isPassVisible = true;
  bool _isEmailLoad = false;
  String _emailError = '';

  // this is for link phone
  TextEditingController phoneController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  bool _isLoad = false;
  bool _isDisable = false;
  bool _isOtpDisable = true;
  bool _isOtpLoad = false;
  int start = 30;
  late String _verificationId;
  Timer? _timer;
  String _phoneError = '';
  String _otpError = '';

  void startTimer(setModalState) {
    const onesec = Duration(seconds: 1);
    _timer = Timer.periodic(onesec, (timer) {
      if (start == 0) {
        setModalState(() {
          timer.cancel();
        });
      } else {
        setModalState(() {
          start--;
        });
      }
    });
  }

  void showSnackbar(text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      showCloseIcon: true,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void getUserData() async {
    DocumentSnapshot<Map<String, dynamic>> snap =
        await FirebaseDatabase.getUser(user!.uid);

    setState(() {
      name = snap.data()!['name'];
      nameController.text = snap.data()!['name'];
      profileUrl = snap.data()!['profileUrl'] ??
          'https://img.freepik.com/free-vector/illustration-businessman_53876-5856.jpg?w=740&t=st=1694756770~exp=1694757370~hmac=784a2fe19c90be061b47a57b31f312661eee8b3b24de11e4a36d46b8ab5a1014';
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    user = _auth.currentUser!;
    email = user?.email;
    phone = user?.phoneNumber;

    getUserData();

    if (email != null) {
      print('f');
      readEmailController.text = email!;
    }

    if (phone != null) {
      readPhoneController.text = phone!;
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print(state);
    if (state == AppLifecycleState.resumed) {
      setState(() {
        FirebaseAuth.instance.currentUser?.reload();
      });
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    Get.offAll((_) => const PhoneLoginScreen());
    // GoRouter.of(context).replaceNamed(AppRouteConstant.phoneLogin);
  }

  // void changePassword() async {
  //   setState(() {
  //     _isLoad = true;
  //   });
  //   String pass = currentPassword.text.trim();
  //   String newPass = newPassword.text.trim();

  //   if (pass == '' || newPass == '') {
  //     showSnackbar('Please enter all fields');
  //     setState(() {
  //       _isLoad = false;
  //     });
  //   } else {
  //     final cred = EmailAuthProvider.credential(email: email!, password: pass);

  //     user?.reauthenticateWithCredential(cred).then((value) {
  //       user?.updatePassword(newPass).then((value) {
  //         showSnackbar("password changed succesfull");
  //         setState(() {
  //           _isLoad = false;
  //         });
  //         currentPassword.clear();
  //         newPassword.clear();
  //       }).catchError((e) {
  //         showSnackbar(e.toString());
  //         setState(() {
  //           _isLoad = false;
  //         });
  //       });
  //     }).catchError((e) {
  //       // showSnackbar("Current Password is wrong");
  //       showSnackbar(e.toString());
  //       setState(() {
  //         _isLoad = false;
  //       });
  //     });
  //   }
  // }

  Future _pickImageFromGallery(ImageSource imageSource) async {
    final selectedImage = await ImagePicker().pickImage(source: imageSource);
    if (selectedImage != null) {
      setState(() {
        _isImageLoad = true;
      });
      profileImage = File(selectedImage.path);
      String profileUrlNew =
          await FirebaseDatabase.uploadImageToFirebase(profileImage!);
      setState(() {
        _isImageLoad = false;
      });

      if (profileUrlNew != 'error') {
        setState(() {
          _isImageLoad = true;
        });
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .update({"profileUrl": profileUrlNew});
        getUserData();

        setState(() {
          _isImageLoad = false;
        });
      }
    }
  }

  void _showBottomSheet(BuildContext context) {
    BottomSheetModal.showBottomSheet(context, _pickImageFromGallery);
  }

  void sendOTP(setModalState) async {
    setModalState(() {
      _isOtpLoad = true;
      _isDisable = true;
    });
    String phone = "+91" + phoneController.text.trim();

    if (phoneController.text.trim().length != 10) {
      // showSnackbar('Please Enter valid 10 digit number');
      _phoneError = 'Please Enter valid 10 digit number';
      setModalState(() {
        _isOtpLoad = false;
        _isDisable = false;
      });
    } else {
      _phoneError = '';
      QuerySnapshot<Map<String, dynamic>> snap =
          await FirebaseDatabase.getUserByPhone(phone);

      if (snap.docs.isEmpty) {
        await FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: phone,
            codeSent: (verificationId, resendToken) {
              _verificationId = verificationId;
              setModalState(() {
                _isOtpLoad = false;
                _isDisable = true;
                _isOtpDisable = false;
              });
              startTimer(setModalState);
            },
            verificationCompleted: (credential) {},
            verificationFailed: (ex) {
              setModalState(() {
                _isOtpLoad = false;
                _isDisable = false;
              });
              _phoneError = ex.code.toString();
              // showSnackbar(ex.code.toString());
            },
            codeAutoRetrievalTimeout: (verificationId) {},
            timeout: const Duration(seconds: 30));
      } else {
        showSnackbar('Phone Number is Already register');
        _phoneError = 'Phone Number is Already register';
        setModalState(() {
          _isOtpLoad = false;
          _isDisable = false;
        });
      }
    }
  }

  void verifyOTP(setModalState) async {
    setModalState(() {
      _isLoad = true;
      _isOtpDisable = true;
    });
    String otp = otpController.text.trim();
    _otpError = '';

    if (otp == '' || otp.length != 6) {
      _otpError = 'Please Enter 6 digit Otp';
      // showSnackbar('Please Enter 6 digit Otp');
      setModalState(() {
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

          setModalState(() {
            _isLoad = false;
            _isDisable = false;
            _isOtpDisable = true;
            _isOtpLoad = false;
            readPhoneController.text = user.phoneNumber!;
            phone = user.phoneNumber;
          });
          _timer?.cancel();

          Navigator.pop(context);
        } else {
          showSnackbar('user not fetch');
        }
      } on FirebaseAuthException catch (e) {
        _otpError = e.code.toString();
        setModalState(() {
          otpController.clear();
          // _timer?.cancel();
          // start = 30;
          _isLoad = false;
          _isOtpDisable = false;
          // _isDisable = false;
          // _isOtpLoad = false;
        });

        showSnackbar(e.code.toString());
      }
    }
  }

  void resendOtp() async {
    _otpError = '';
    String phone = "+91" + phoneController.text.trim();
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        codeSent: (verificationId, resendToken) {
          _verificationId = verificationId;
        },
        verificationCompleted: (credential) {},
        verificationFailed: (ex) {
          showSnackbar(ex.code.toString());
        },
        codeAutoRetrievalTimeout: (verificationId) {},
        timeout: const Duration(seconds: 30));
  }

  void linkWithEmail(setModalState) async {
    setModalState(() {
      _isEmailLoad = true;
    });

    String emailTrim = emailController.text.trim();
    String password = passwordController.text.trim();

    if (emailTrim == "" || password == "") {
      _emailError = 'Fill all details';
      // showSnackbar('Fill all details');
      setModalState(() {
        _isEmailLoad = false;
      });
    } else {
      _emailError = '';
      try {
        AuthCredential credential =
            EmailAuthProvider.credential(email: emailTrim, password: password);

        final userCredential = await FirebaseAuth.instance.currentUser
            ?.linkWithCredential(credential);
        if (userCredential?.user != null) {
          setModalState(() {
            _isEmailLoad = false;
            readEmailController.text = userCredential!.user!.email!;
            email = userCredential.user!.email!;
          });
          Navigator.pop(context);
        }
      } on FirebaseAuthException catch (e) {
        setModalState(() {
          _isEmailLoad = false;
        });
        _emailError = e.code.toString();
        // showSnackbar(e.code.toString());
      }
    }
  }

  void _showEmailBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
      ),
      builder: (BuildContext context) {
        // bool _isPassVisible = true;
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        onTap: () {
                          _emailError = '';
                        },
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration:
                            const InputDecoration(labelText: 'Enter Email'),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        onTap: () {
                          _emailError = '';
                        },
                        obscureText: _isPassVisible,
                        controller: passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                            labelText: 'Enter Password',
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setModalState(() {
                                    _isPassVisible = !_isPassVisible;
                                  });
                                },
                                icon: _isPassVisible
                                    ? const Icon(Icons.visibility)
                                    : const Icon(Icons.visibility_off))),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      _emailError == ''
                          ? Container()
                          : Text(
                              _emailError,
                              style: const TextStyle(color: Colors.red),
                            ),
                      const SizedBox(
                        height: 10,
                      ),
                      CupertinoButton(
                        onPressed: _isEmailLoad
                            ? null
                            : () {
                                linkWithEmail(setModalState);
                              },
                        color: Colors.green.shade600,
                        child: _isEmailLoad
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : const Text('Submit'),
                      )
                    ],
                  )));
        });
      },
    );
  }

  void _showPhoneBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        onTap: () {
                          setState(() {
                            _phoneError = '';
                          });
                        },
                        controller: phoneController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: "Phone Number"),
                      ),
                      _phoneError == ''
                          ? Container()
                          : Text(
                              _phoneError,
                              style: const TextStyle(color: Colors.red),
                            ),
                      const SizedBox(
                        height: 10,
                      ),
                      CupertinoButton(
                        onPressed: _isDisable
                            ? null
                            : () {
                                sendOTP(setModalState);
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
                        onTap: () {
                          setState(() {
                            _otpError = '';
                          });
                        },
                        keyboardType: TextInputType.number,
                        controller: otpController,
                        decoration: const InputDecoration(
                            labelText: "Enter 6 digit otp"),
                      ),
                      _otpError == ''
                          ? Container()
                          : Text(
                              _otpError,
                              style: const TextStyle(color: Colors.red),
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
                                      startTimer(setModalState);
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
                                verifyOTP(setModalState);
                              },
                        color: Colors.lightGreen,
                        child: !_isLoad
                            ? const Text('Submit')
                            : const CircularProgressIndicator(),
                      ),
                    ],
                  )));
        });
      },
    );
  }

  void changeName() async {
    setState(() {
      _isNameLoad = true;
    });
    if (nameController.text.trim() == name) {
      showSnackbar('Updated');
      setState(() {
        _isNameLoad = false;
      });
    } else if (nameController.text.trim().isEmpty) {
      showSnackbar('Please enter name');
      setState(() {
        _isNameLoad = false;
      });
    } else {
      await FirebaseDatabase.updateName(nameController.text.trim(), user!.uid);
      setState(() {
        _isNameLoad = false;
      });
      showSnackbar('Updated');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f0f0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Profile Screen'),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Are you sure?'),
                        content: const Text('You want to logout?'),
                        actions: [
                          InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'No',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16),
                              )),
                          const SizedBox(
                            width: 20,
                          ),
                          InkWell(
                              onTap: () {
                                logout();
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Yes',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 16),
                              )),
                        ],
                      );
                    });

                // logout();
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _isImageLoad
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Stack(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                                color: Colors.grey,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(70))),
                            padding: const EdgeInsets.all(1),
                            child: CircleAvatar(
                                radius: 70,
                                foregroundImage: NetworkImage(profileUrl ??
                                    'https://img.freepik.com/free-vector/illustration-businessman_53876-5856.jpg?w=740&t=st=1694756770~exp=1694757370~hmac=784a2fe19c90be061b47a57b31f312661eee8b3b24de11e4a36d46b8ab5a1014')),
                          ),
                          Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 0.5, color: Colors.grey),
                                    color: Colors.green,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(24))),
                                child: IconButton(
                                    iconSize: 24,
                                    onPressed: () {
                                      _showBottomSheet(context);
                                    },
                                    icon: const Icon(
                                      Icons.camera_alt_outlined,
                                      color: Colors.white,
                                    )),
                              ))
                        ],
                      ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),

                    TextField(
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                      ),
                      controller: nameController,
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    TextField(
                      onTap: () {
                        email == null
                            ? _showEmailBottomSheet(context)
                            : showSnackbar('Email id Already Register');
                      },
                      readOnly: true,
                      controller: readEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),

                    TextField(
                      readOnly: true,
                      onTap: () {
                        phone == null
                            ? _showPhoneBottomSheet(context)
                            : showSnackbar('Phone is Already register');
                      },
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                      ),
                      controller: readPhoneController,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CupertinoButton(
                      color: Colors.green,
                      onPressed: _isNameLoad
                          ? null
                          : () {
                              changeName();
                            },
                      child: _isNameLoad
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : const Text('Submit'),
                    ),
                    // Text(
                    //   name ?? 'Loading...',
                    //   style: const TextStyle(fontSize: 24),
                    //   textAlign: TextAlign.center,
                    // ),
                    // const SizedBox(
                    //   height: 20,
                    // ),
                    // Text(
                    //   email ?? '',
                    //   style: const TextStyle(fontSize: 24),
                    //   textAlign: TextAlign.center,
                    // ),
                    // const SizedBox(
                    //   height: 20,
                    // ),
                    // Text(
                    //   phone ?? '',
                    //   style: const TextStyle(fontSize: 24),
                    //   textAlign: TextAlign.center,
                    // ),
                    // const SizedBox(
                    //   height: 20,
                    // ),
                    // const Text('Change password'),
                    // TextField(
                    //   obscureText: _isCurrentPass,
                    //   decoration: InputDecoration(
                    //     labelText: 'Current Password',
                    //     suffixIcon: IconButton(
                    //         onPressed: () {
                    //           setState(() {
                    //             _isCurrentPass = !_isCurrentPass;
                    //           });
                    //         },
                    //         icon: _isCurrentPass
                    //             ? const Icon(Icons.visibility)
                    //             : const Icon(Icons.visibility_off)),
                    //   ),
                    //   controller: currentPassword,
                    // ),
                    // const SizedBox(
                    //   height: 10,
                    // ),
                    // TextField(
                    //   obscureText: _isNewPass,
                    //   controller: newPassword,
                    //   decoration: InputDecoration(
                    //     labelText: 'New Password',
                    //     suffixIcon: IconButton(
                    //         onPressed: () {
                    //           setState(() {
                    //             _isNewPass = !_isNewPass;
                    //           });
                    //         },
                    //         icon: _isNewPass
                    //             ? const Icon(Icons.visibility)
                    //             : const Icon(Icons.visibility_off)),
                    //   ),
                    // ),
                    // const SizedBox(
                    //   height: 20,
                    // ),
                    // CupertinoButton(
                    //   onPressed: !_isLoad
                    //       ? () {
                    //           email == null
                    //               ? showSnackbar(
                    //                   'Please Link email for change password')
                    //               : changePassword();
                    //         }
                    //       : null,
                    //   color: Colors.lightGreen,
                    //   child: !_isLoad
                    //       ? const Text('Submit')
                    //       : const CircularProgressIndicator(),
                    // ),
                    // const SizedBox(
                    //   height: 10,
                    // ),
                    // phone == null || email == null ? const Text('or') : Container(),
                    // const SizedBox(
                    //   height: 20,
                    // ),
                    // phone == null || email == null
                    //     ? CupertinoButton(
                    //         onPressed: () {
                    //           GoRouter.of(context).replaceNamed(
                    //               AppRouteConstant.link,
                    //               pathParameters: {
                    //                 'phone': phone == null ? 'true' : 'false'
                    //               });
                    //         },
                    //         color: Colors.lightGreen,
                    //         child: phone == null
                    //             ? const Text('Link with Phone')
                    //             : const Text('Link with Email'))
                    //     : Container(),
                  ],
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
