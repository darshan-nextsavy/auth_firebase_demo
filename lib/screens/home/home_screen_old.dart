import 'dart:developer';

import 'package:auth_firebase_demo/route/route_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  final String? reload;
  const HomeScreen({Key? key, this.reload}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  String? email;
  String? phone;
  String? name;
  bool _isLoad = false;
  bool _isCurrentPass = true;
  bool _isNewPass = true;
  TextEditingController currentPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  int selectedScreen = 0;

  void showSnackbar(text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void getUserData() async {
    DocumentSnapshot<Map<String, dynamic>> snap = await FirebaseFirestore
        .instance
        .collection("users")
        .doc(user?.uid)
        .get();

    setState(() {
      name = snap.data()!['name'];
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
    log(state.toString());
    if (state == AppLifecycleState.resumed) {
      print('df');
      setState(() {
        FirebaseAuth.instance.currentUser?.reload();
      });
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    GoRouter.of(context).replaceNamed(AppRouteConstant.phoneLogin);
  }

  void changePassword() async {
    setState(() {
      _isLoad = true;
    });
    String pass = currentPassword.text.trim();
    String newPass = newPassword.text.trim();

    if (pass == '' || newPass == '') {
      showSnackbar('Please enter all fields');
      setState(() {
        _isLoad = false;
      });
    } else {
      final cred = EmailAuthProvider.credential(email: email!, password: pass);

      user?.reauthenticateWithCredential(cred).then((value) {
        user?.updatePassword(newPass).then((value) {
          showSnackbar("password changed succesfull");
          setState(() {
            _isLoad = false;
          });
          currentPassword.clear();
          newPassword.clear();
        }).catchError((e) {
          showSnackbar(e.toString());
          setState(() {
            _isLoad = false;
          });
        });
      }).catchError((e) {
        // showSnackbar("Current Password is wrong");
        showSnackbar(e.toString());
        setState(() {
          _isLoad = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(phone);
    print(email);
    if (widget.reload == 'reload') {
      FirebaseAuth.instance.currentUser?.reload();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
              onPressed: () {
                logout();
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.view_timeline), label: 'Time Line'),
        BottomNavigationBarItem(icon: Icon(Icons.post_add), label: 'Posts'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile')
      ]),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: ListView(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                name ?? 'Loading...',
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              Text(
                email ?? '',
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              Text(
                phone ?? '',
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              const Text('Change password'),
              TextField(
                obscureText: _isCurrentPass,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isCurrentPass = !_isCurrentPass;
                        });
                      },
                      icon: _isCurrentPass
                          ? const Icon(Icons.visibility)
                          : const Icon(Icons.visibility_off)),
                ),
                controller: currentPassword,
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                obscureText: _isNewPass,
                controller: newPassword,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isNewPass = !_isNewPass;
                        });
                      },
                      icon: _isNewPass
                          ? const Icon(Icons.visibility)
                          : const Icon(Icons.visibility_off)),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              CupertinoButton(
                onPressed: !_isLoad
                    ? () {
                        email == null
                            ? showSnackbar(
                                'Please Link email for change password')
                            : changePassword();
                      }
                    : null,
                color: Colors.lightGreen,
                child: !_isLoad
                    ? const Text('Submit')
                    : const CircularProgressIndicator(),
              ),
              const SizedBox(
                height: 10,
              ),
              phone == null || email == null ? const Text('or') : Container(),
              const SizedBox(
                height: 20,
              ),
              phone == null || email == null
                  ? CupertinoButton(
                      onPressed: () {
                        GoRouter.of(context).replaceNamed(AppRouteConstant.link,
                            pathParameters: {
                              'phone': phone == null ? 'true' : 'false'
                            });
                      },
                      color: Colors.lightGreen,
                      child: phone == null
                          ? const Text('Link with Phone')
                          : const Text('Link with Email'))
                  : Container(),
            ],
          ),
        ]),
      ),
    );
  }
}
