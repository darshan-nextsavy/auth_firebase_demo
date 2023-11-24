import 'dart:io';
import 'package:auth_firebase_demo/firebase/firebase_database.dart';
import 'package:auth_firebase_demo/route/route_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/bottom_sheet.dart';

class RegisterPhoneScreen extends StatefulWidget {
  const RegisterPhoneScreen({Key? key}) : super(key: key);

  @override
  State<RegisterPhoneScreen> createState() => _RegisterPhoneScreenState();
}

class _RegisterPhoneScreenState extends State<RegisterPhoneScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  String? profileImage;

  bool _isLoad = false;

  void showSnackBar(text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future _pickImageFromGallery(ImageSource imageSource) async {
    final selectedImage = await ImagePicker().pickImage(source: imageSource);
    setState(() {
      profileImage = selectedImage!.path;
    });
  }

  void sendOtp() async {
    setState(() {
      _isLoad = true;
    });
    String phone = "+91" + phoneController.text.trim();
    String name = nameController.text.trim();

    if (phoneController.text.trim() == '' || name == '') {
      showSnackBar('Enter all the fields');
      setState(() {
        _isLoad = false;
      });
    } else if (phoneController.text.trim().length != 10) {
      showSnackBar('Enter 10 digit mobile number');
      setState(() {
        _isLoad = false;
      });
    } else {
      QuerySnapshot<Map<String, dynamic>> snap =
          await FirebaseDatabase.getUserByPhone(phone);

      if (snap.docs.isEmpty) {
        await FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: phone,
            codeSent: (verificationId, resendToken) {
              setState(() {
                _isLoad = false;
              });
              GoRouter.of(context).pushNamed(AppRouteConstant.verifyOtp,
                  pathParameters: {
                    'verificationId': verificationId,
                    'phoneNumber': phone
                  },
                  extra: [
                    'registerScreen',
                    name,
                    profileImage
                  ]);
            },
            verificationCompleted: (credential) {},
            verificationFailed: (ex) {
              showSnackBar(ex.code.toString());
              setState(() {
                _isLoad = false;
              });
            },
            codeAutoRetrievalTimeout: (verificationId) {},
            timeout: const Duration(seconds: 30));
      } else {
        showSnackBar("this number is already register");
        setState(() {
          _isLoad = false;
        });
      }
    }
  }

  void _showBottomSheet(BuildContext context) {
    BottomSheetModal.showBottomSheet(context, _pickImageFromGallery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f0f0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Register with phone'),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                            color: Colors.grey,
                            borderRadius:
                                BorderRadius.all(Radius.circular(70))),
                        padding: const EdgeInsets.all(1),
                        child: CircleAvatar(
                          radius: 70,
                          backgroundImage: const NetworkImage(
                              'https://cdn.dribbble.com/users/1787505/screenshots/7300251/media/a351d9e0236c03a539181b95faced9e0.gif'),
                          foregroundImage: profileImage != null
                              ? FileImage(File(profileImage!))
                                  as ImageProvider<Object>
                              : const NetworkImage(
                                  'https://img.freepik.com/free-vector/illustration-businessman_53876-5856.jpg?w=740&t=st=1694756770~exp=1694757370~hmac=784a2fe19c90be061b47a57b31f312661eee8b3b24de11e4a36d46b8ab5a1014'),
                        ),
                      ),
                      Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 0.5, color: Colors.grey),
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
                  TextField(
                    textCapitalization: TextCapitalization.words,
                    controller: nameController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: "Full Name"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    maxLength: 10,
                    keyboardType: TextInputType.phone,
                    controller: phoneController,
                    decoration:
                        const InputDecoration(labelText: "Phone Number"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CupertinoButton(
                    onPressed: !_isLoad
                        ? () {
                            sendOtp();
                          }
                        : null,
                    color: Colors.lightGreen,
                    child: !_isLoad
                        ? const Text("Register")
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
