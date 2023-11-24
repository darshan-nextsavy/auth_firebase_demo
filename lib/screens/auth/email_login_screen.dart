import 'package:auth_firebase_demo/route/route_constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({Key? key}) : super(key: key);

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _isLoad = false;
  bool _isPassVisible = true;

  void showSnackBar(text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void login() async {
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
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        if (userCredential.user != null) {
          setState(() {
            _isLoad = false;
          });
          GoRouter.of(context).replaceNamed(AppRouteConstant.home, extra: '0');
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoad = false;
        });
        if (e.code.toString() == "user-not-found") {
          showSnackBar('Email id not register. Please register first');
        } else if (e.code.toString() == "wrong-password") {
          showSnackBar('Please enter correct password');
        } else {
          showSnackBar(e.code.toString());
        }
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
        title: const Text('Login with email'),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  TextField(
                    textInputAction: TextInputAction.next,
                    controller: emailController,
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
                    textInputAction: TextInputAction.done,
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
                            login();
                          }
                        : null,
                    color: Colors.lightGreen,
                    child: !_isLoad
                        ? const Text("Login")
                        : const CircularProgressIndicator(),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CupertinoButton(
                    onPressed: () {
                      GoRouter.of(context)
                          .replaceNamed(AppRouteConstant.phoneLogin);
                    },
                    child: const Text("Login With Phone"),
                  ),
                  const Text(
                    'Or',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      GoRouter.of(context)
                          .pushNamed(AppRouteConstant.emailRegistration);
                    },
                    child: const Text("Create an Account"),
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
