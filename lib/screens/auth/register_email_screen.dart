import 'dart:io';
import 'package:auth_firebase_demo/route/route_constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../firebase/firebase_database.dart';
import '../utils/bottom_sheet.dart';

class RegisterEmailScreen extends StatefulWidget {
  const RegisterEmailScreen({Key? key}) : super(key: key);

  @override
  State<RegisterEmailScreen> createState() => _RegisterEmailScreenState();
}

class _RegisterEmailScreenState extends State<RegisterEmailScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();
  bool _isLoad = false;
  bool _isPassVisible = true;
  bool _isConfirmPassVisible = true;
  File? profileImage;

  void showSnackBar(text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void createAccount() async {
    setState(() {
      _isLoad = true;
    });
    String email = emailController.text.trim();
    String name = nameController.text.trim();
    String password = passwordController.text.trim();
    String cPassword = cPasswordController.text.trim();

    if (email == "" || password == "" || cPassword == "" || name == "") {
      showSnackBar('Fill all details');
      setState(() {
        _isLoad = false;
      });
    } else if (password != cPassword) {
      showSnackBar('Password and confirm password not match');
      setState(() {
        _isLoad = false;
      });
    } else {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        showSnackBar('User created');

        if (userCredential.user != null) {
          User user = userCredential.user!;
          if (profileImage != null) {
            String profileUrl =
                await FirebaseDatabase.uploadImageToFirebase(profileImage!);
            if (profileUrl != 'error') {
              await FirebaseDatabase.addUserWithProfile(
                  user.uid, email, profileUrl, name);
              // await FirebaseFirestore.instance
              //     .collection("users")
              //     .doc(user.uid)
              //     .set(
              //         {"phone": email, "name": name, "profileUrl": profileUrl});

              setState(() {
                _isLoad = false;
              });

              if (context.canPop()) {
                context.pop();
                GoRouter.of(context)
                    .replaceNamed(AppRouteConstant.home, extra: '0');
                // GoRouter.of(context).replaceNamed(AppRouteConstant.home,
                // pathParameters: {'reload': 'notReload'});
              }
            }
          } else {
            // await FirebaseFirestore.instance
            //     .collection("users")
            //     .doc(user.uid)
            //     .set({"phone": email, "name": name});

            FirebaseDatabase.addUserWithOutProfile(user.uid, email, name);
            // context.pop();
            setState(() {
              _isLoad = false;
            });

            if (context.canPop()) {
              context.pop();
              GoRouter.of(context)
                  .replaceNamed(AppRouteConstant.home, extra: '0');
            }
          }
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoad = false;
        });
        if (e.code.toString() == "email-already-in-use") {
          showSnackBar("Email id is already register.");
        } else {
          showSnackBar(e.code.toString());
        }
      }
    }
  }

  Future _pickImageFromGallery(ImageSource imageSource) async {
    final selectedImage = await ImagePicker().pickImage(source: imageSource);
    setState(() {
      profileImage = File(selectedImage!.path);
    });
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
        title: const Text("Create an account"),
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
                              ? FileImage(profileImage!)
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
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Full name"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    controller: emailController,
                    decoration:
                        const InputDecoration(labelText: "Email Address"),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.next,
                    controller: passwordController,
                    obscureText: _isPassVisible,
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
                              : const Icon(Icons.visibility_off)),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    keyboardType: TextInputType.visiblePassword,
                    controller: cPasswordController,
                    obscureText: _isConfirmPassVisible,
                    decoration: InputDecoration(
                        labelText: "Confirm Password",
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isConfirmPassVisible = !_isConfirmPassVisible;
                              });
                            },
                            icon: _isConfirmPassVisible
                                ? const Icon(Icons.visibility)
                                : const Icon(Icons.visibility_off))),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CupertinoButton(
                    onPressed: !_isLoad
                        ? () {
                            createAccount();
                          }
                        : null,
                    color: Colors.lightGreen,
                    child: !_isLoad
                        ? const Text("Create Account")
                        : const CircularProgressIndicator(),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
