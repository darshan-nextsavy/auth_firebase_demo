import 'dart:async';
import 'dart:developer';
import 'package:auth_firebase_demo/contoller/global_controller.dart';
import 'package:auth_firebase_demo/screens/requirement/user_requested_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class Dashboard extends StatefulWidget {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  List<DocumentSnapshot> posts = [];

  // comment when driver is login
  Stream<QuerySnapshot> requirementsStream = FirebaseFirestore.instance
      .collection("requirements")
      .where("status", whereIn: ["active"])
      .where("hasPostedByUser", isEqualTo: false)
      .snapshots();

  // comment when user is login
  // Stream<QuerySnapshot> requirementsStream = FirebaseFirestore.instance
  //     .collection("requirements")
  //     .where("status", whereIn: ["active"])
  //     .where("hasPostedByUser", isEqualTo: true)
  //     .snapshots();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = _auth.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: requirementsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error fetching data'),
                    );
                  }
                  if (snapshot.hasData) {
                    final docu = snapshot.data!.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docu.length,
                      // itemCount: posts.length,
                      itemBuilder: (context, index) {
                        return getRequirementCards(docu[index]);
                      },
                    );
                  }

                  return const Center(
                    child: Text('Error'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(const UserRequestedPage());
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Card getRequirementCards(DocumentSnapshot<Object?> post) {
    log("inside getRequirementCards");
    final docId = post.reference.id;
    Map<String, dynamic>? data = post.data() as Map<String, dynamic>?;
    List reqList = data?['request'] ?? [];

    bool isReqSent = true;
    void checkReqSent() {
      if (reqList.isNotEmpty) {
        print("this is one " + isReqSent.toString());
        isReqSent = reqList.every((element) => element['uid'] != user!.uid);
        print("this is two " + isReqSent.toString());
      }
    }

    checkReqSent();
    String driverPhoto = data?['driverPhoto'] == "null"
        ? 'https://firebasestorage.googleapis.com/v0/b/flutter-auth-sample-41958.appspot.com/o/images%2Fimage_picker_04E08C39-3A00-4DF8-8B19-BCCE8751C6EF-2741-000003977D02EBE4.jpg?alt=media&token=4a2332af-3fe1-4f45-9112-922d5197c0c4'
        : data?['driverPhoto']; // Replace with appropriate default value
    String driverName = data?['driverName'] ?? '';
    String driverUid = data?['driverUid'] ?? '';
    String driverPhone = data?['driverPhone'] ?? '';

    String status = data?['status'] ?? '';
    String source = data?['source'] ?? '';
    String destination = data?['destination'] ?? '';
    String weight = data?['weight'] ?? '';
    String date = data?['date'] ?? '';
    String vehicleType = data?['vehicleType'] ?? '';

    bool hasPostedByUser = data?['hasPostedByUser'] ?? false;
    bool hasDriverRequested = data?['hasDriverRequested'] ?? false;
    bool hasUserCalledToDriver = data?['hasUserCalledToDriver'] ?? false;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(child: Image.network(driverPhoto)),
                        SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driverName, // Replace with the driver's name
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (status == "booked")
                              Row(
                                children: [
                                  SizedBox(width: 3),
                                  Icon(Icons.book_rounded,
                                      color: Colors.red,
                                      semanticLabel: "Status",
                                      size: 25),
                                  Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            if (status == "cancelled")
                              Row(
                                children: [
                                  SizedBox(width: 3),
                                  Icon(Icons.cancel,
                                      color: Colors.red,
                                      semanticLabel: "Status",
                                      size: 25),
                                  Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            if (status == "delivered")
                              Row(
                                children: [
                                  const SizedBox(width: 3),
                                  const Icon(Icons.done_all,
                                      color: Colors.green,
                                      semanticLabel: "Status",
                                      size: 25),
                                  Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                    isReqSent
                        ? IconButton(
                            onPressed: () async {
                              reqList.add(
                                  {"uid": user!.uid, "isAccept": "pending"});
                              await FirebaseFirestore.instance
                                  .collection("requirements")
                                  .doc(docId)
                                  .update({"request": reqList});

                              await FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(user!.uid)
                                  .update({
                                "request": FieldValue.arrayUnion([
                                  {
                                    "requirementId": docId,
                                    "isAccepted": "pending"
                                  }
                                ])
                              });
                            },
                            icon: const Icon(Icons.add_reaction))
                        : SizedBox.shrink(),
                    IconButton(
                        icon: const Icon(Icons.call),
                        onPressed: () async {
                          var docRef = FirebaseFirestore.instance
                              .collection("requirements");

                          final user = FirebaseAuth.instance.currentUser!;

                          final CollectionReference userCollection =
                              FirebaseFirestore.instance.collection('users');
                          final DocumentSnapshot snapshot =
                              await userCollection.doc(user.uid).get();

                          String userName = "";
                          if (snapshot.exists) {
                            // The document exists, you can access its data
                            Map<String, dynamic> userData =
                                snapshot.data() as Map<String, dynamic>;

                            setState(() {
                              userName = userData['name'];
                            });
                          } else {
                            print(
                                'User document does not exist for UID: ${user.uid}');
                          }

                          String userPhoto =
                              FirebaseAuth.instance.currentUser!.photoURL!;

                          FirebaseAuth auth = FirebaseAuth.instance;
                          FirebaseFirestore firestore =
                              FirebaseFirestore.instance;
                          String userPhone = (await firestore
                                  .collection("users")
                                  .doc(auth.currentUser!.uid)
                                  .get())
                              .data()!['phoneNumber']
                              .toString();
                          if (userPhone.isEmpty) {
                            {
                              Get.snackbar(
                                "Failed",
                                "Please update your phone number in profile section",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                barBlur: 0,
                                icon: const Icon(
                                  Icons.error,
                                  color: Colors.white,
                                ),
                                colorText: Colors.white,
                                progressIndicatorBackgroundColor: Colors.white,
                              );
                            }
                            return;
                          }

                          String userUid = auth.currentUser!.uid;
                          print(userName);
                          print(userPhone);
                          print(userName);

                          if (driverPhone.isEmpty) {
                            {
                              Get.snackbar(
                                "Failed",
                                "Please update your phone number in profile section",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                barBlur: 0,
                                icon: const Icon(
                                  Icons.error,
                                  color: Colors.white,
                                ),
                                colorText: Colors.white,
                                progressIndicatorBackgroundColor: Colors.white,
                              );
                            }
                            return;
                          }
                          if (userPhone != null ||
                              userName != null ||
                              userUid != null ||
                              userPhoto != null) {
                            docRef
                                .doc(post.id)
                                .update({
                                  "hasUserCalledToDriver": true,
                                  "userUid": userUid,
                                  "userrName": userName,
                                  "userPhone": userPhone,
                                  "userPhoto": userPhoto,
                                })
                                .then(
                                    (value) => log("Data updated successfully"))
                                .onError((error, stackTrace) =>
                                    log("Failed to update data"));

                            Get.snackbar(
                              "Success",
                              "Calling to the Driver",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green,
                              barBlur: 0,
                              icon: const Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                              colorText: Colors.white,
                              progressIndicatorBackgroundColor: Colors.white,
                            );

                            // Delay the call action by 1 second (adjust as needed)
                            await Future.delayed(Duration(seconds: 1));
                            await launch('tel:$driverPhone');
                          } else {
                            errorSnackBar(
                                "Some error occured, please try again later");
                          }
                        }),
                    PopupMenuButton(
                      onSelected: (value) {},
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          value: "edit",
                          child: Text("Edit"),
                          onTap: () {},
                        ),
                        PopupMenuItem(
                          onTap: () async {
                            try {
                              await FirebaseFirestore.instance
                                  .collection("requirements")
                                  .doc(post.id)
                                  .delete();
                              setState(() {
                                posts.remove(post);
                              });
                              Get.snackbar(
                                  "Success", "Order Deleted Successfully");
                            } catch (error) {
                              Get.snackbar("Error", "Failed to Delete Order");
                            }
                          },
                          value: "delete",
                          child: Text("Delete"),
                        ),
                      ],
                      icon: Icon(Icons.more_vert), // Three dot menu icon
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Text(source + " FROM"),
                        ],
                      ),
                      Column(
                        children: [
                          Text(" TO  +${destination}}"),
                        ],
                      ),
                      SizedBox(width: 20),
                      Column(
                        children: [
                          Text("$weight KG"),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.line_weight_sharp),
                        ],
                      ),
                      SizedBox(width: 20),
                      Column(
                        children: [
                          Text(date,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                true
                    ? ExpansionTile(
                        title: Text(
                          "View More",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        children: [
                          SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            height: 160,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0.0, 2.0),
                                  blurRadius: 6.0,
                                ),
                              ],
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage(
                                  "https://bsmedia.business-standard.com/_media/bs/img/article/2016-01/05/full/1451939922-2731.jpg",
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    : Container()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
