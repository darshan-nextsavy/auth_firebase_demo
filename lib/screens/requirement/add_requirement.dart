import 'package:auth_firebase_demo/contoller/global_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddRequirement extends StatefulWidget {
  const AddRequirement({super.key});

  @override
  State<AddRequirement> createState() => _AddRequirementState();
}

class _AddRequirementState extends State<AddRequirement> {
  TextEditingController sourceController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController vehicleTypeController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  bool isEverythingOk = false;

  List<TextEditingController> stopsTextControllerList = [];
  List<String> stopsList = [];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _submitData() async {
    String source = sourceController.text;
    String destination = destinationController.text;
    String weight = weightController.text;
    String vehicleType = vehicleTypeController.text;

    if (source.isEmpty ||
        destination.isEmpty ||
        weight.isEmpty ||
        vehicleType.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all the fields'),
        ),
      );
    } else {
      String selectedDateString =
          selectedDate.toLocal().toString().split(' ')[0];
      print('Source: $source');
      print('Destination: $destination');
      print('Weight: $weight');
      print('Selected Date: $selectedDateString');
      print('Vehicle Type: $vehicleType');

      FirebaseAuth auth = FirebaseAuth.instance;
      print(" user " + auth.currentUser.toString());
      User? driver = auth.currentUser;
      String? name = driver!.displayName;
      String profilePhoto = driver.photoURL ??
          "https://firebasestorage.googleapis.com/v0/b/flutter-auth-sample-41958.appspot.com/o/images%2Fimage_picker_04E08C39-3A00-4DF8-8B19-BCCE8751C6EF-2741-000003977D02EBE4.jpg?alt=media&token=4a2332af-3fe1-4f45-9112-922d5197c0c4";
      String uid = driver.uid;
      String phoneNumber = "";
      String userType = "user";

      // Get Phone from cloud firestore using uid
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (snapshot.exists) {
        phoneNumber = snapshot.data()!['phone'].toString();
        userType = snapshot.data()!['type'];
        name = driver.displayName == ''
            ? snapshot.data()!['name']
            : driver.displayName;

        if (phoneNumber.isEmpty || phoneNumber == "null") {
          {
            errorSnackBar("Please update your phone number in profile section");
          }
          return;
        }
      } else {
        print('No such user');
        errorSnackBar("No such user");
        return;
      }
      // Add data in Cloud Firestore
      try {
        var docRef =
            await FirebaseFirestore.instance.collection("requirements").add({
          "source": source,
          "destination": destination,
          "weight": weight,
          "date": selectedDateString,
          "vehicleType": userType == "user" ? "null" : vehicleType,

          "userUid": userType == "user" ? uid : "null",
          "userName": userType == "user" ? name : "null",
          "userPhone": userType == "user" ? phoneNumber : "null",
          "userPhoto": userType == "user" ? profilePhoto : "null",

          "hasPostedByUser": userType == "user" ? true : false,
          "driverUid": userType == "user" ? "null" : uid,
          "driverName": userType == "user" ? "null" : name,
          "driverPhone": userType == "user" ? "null" : phoneNumber,
          "driverPhoto": userType == "user" ? "null" : profilePhoto,

          "status": "active", //Status will be active / Booked

          "hasDriverCalledToUser": false,
          "hasUserCalledToDriver": false,
          "request": []
        });

        // print("Data added successfully with ID: ${docRef.id}");
        successSnackBar("Order Added Successfully");
        // Get.offAll(Tra_Home());
      } catch (e) {
        print("Failed to add data: $e");
        errorSnackBar("Failed to Add Order");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Requirement"),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: sourceController,
              decoration: const InputDecoration(
                labelText: "Source",
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ),
          ...stopsList.asMap().entries.map((ele) {
            int index = ele.key;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                onChanged: (val) {
                  stopsList[index] = val;
                },
                decoration: InputDecoration(
                  labelText: "Stop ${index + 1}",
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
            );
          }).toList(),
          TextButton.icon(
              onPressed: () {
                setState(() {
                  stopsList.add("");
                });
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Stops")),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: destinationController,
              decoration: const InputDecoration(
                labelText: "Destination",
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.number,
              controller: weightController,
              decoration: const InputDecoration(
                labelText: "Weight",
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: vehicleTypeController,
              decoration: const InputDecoration(
                labelText: "Vehicle Type",
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                    "Selected Date: ${selectedDate.toLocal().toString().split(' ')[0]}"),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Select date'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              onPressed: () {
                // if (isEverythingOk) {
                _submitData();
                // } else {
                //   Get.snackbar(
                //     "Failed",
                //     "Please complete payment",
                //     snackPosition: SnackPosition.BOTTOM,
                //     backgroundColor: Colors.red,
                //     barBlur: 0,
                //     icon: const Icon(
                //       Icons.error,
                //       color: Colors.white,
                //     ),
                //     colorText: Colors.white,
                //     progressIndicatorBackgroundColor: Colors.white,
                //   );
                // }
              },
              child: const Text('Add Requirements'),
            ),
          ),
        ],
      ),
    );
  }
}
