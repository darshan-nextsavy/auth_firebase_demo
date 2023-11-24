import 'package:auth_firebase_demo/screens/post/post_screen.dart';
import 'package:auth_firebase_demo/screens/profile/profile_screen.dart';
import 'package:auth_firebase_demo/screens/requirement/add_requirement.dart';
import 'package:auth_firebase_demo/screens/requirement/dashboard.dart';
import 'package:auth_firebase_demo/screens/timeline/timeline_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String selectedScreen;
  const HomeScreen({Key? key, this.selectedScreen = '0'}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedScreen = 0;

  Widget getScreen() {
    switch (selectedScreen) {
      case 0:
        return Dashboard();
      // return const TimeLineScreen();
      case 1:
        return const AddRequirement();
      // return const PostScreen();
      case 2:
        return const ProfileScreen();
      default:
        return const TimeLineScreen();
    }
  }

  @override
  void initState() {
    super.initState();
    selectedScreen = int.parse(widget.selectedScreen);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getScreen(),
      bottomNavigationBar: BottomNavigationBar(
          onTap: (value) {
            selectedScreen = value;
            setState(() {});
          },
          currentIndex: selectedScreen,
          items: const [
            // BottomNavigationBarItem(
            // icon: Icon(Icons.view_timeline), label: 'Time Line'),
            BottomNavigationBarItem(
                icon: Icon(Icons.view_timeline), label: 'Time Line'),
            // BottomNavigationBarItem(icon: Icon(Icons.post_add), label: 'Posts'),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add Req'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ]),
    );
  }
}
