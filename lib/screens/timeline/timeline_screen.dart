import 'package:auth_firebase_demo/firebase/firebase_database.dart';
import 'package:auth_firebase_demo/screens/utils/time.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TimeLineScreen extends StatefulWidget {
  const TimeLineScreen({Key? key}) : super(key: key);

  @override
  State<TimeLineScreen> createState() => _TimeLineScreenState();
}

class _TimeLineScreenState extends State<TimeLineScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f0f0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Time Line'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseDatabase.getPosts(),
            builder: (context, snapshot) {
              QuerySnapshot? querySnapshot = snapshot.data;
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (querySnapshot!.docs.isEmpty) {
                return const Center(child: Text('No Post Listed Here'));
              }
              return ListView.builder(
                  itemCount: querySnapshot.docs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data = querySnapshot.docs[index].data()
                        as Map<String, dynamic>;

                    return Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 10),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder(
                              future: FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(data['uid'])
                                  .get(),
                              builder: (context, snapshot) {
                                print(data['uid']);
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text('Loading...');
                                } else {
                                  // print(snapshot.data?.data()!['name']);

                                  return Row(
                                    children: [
                                      Container(
                                        decoration: const BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(30))),
                                        padding: const EdgeInsets.all(1),
                                        child: CircleAvatar(
                                          radius: 30,
                                          backgroundImage: const NetworkImage(
                                              'https://img.freepik.com/free-vector/illustration-businessman_53876-5856.jpg?w=740&t=st=1694756770~exp=1694757370~hmac=784a2fe19c90be061b47a57b31f312661eee8b3b24de11e4a36d46b8ab5a1014'),
                                          foregroundImage: NetworkImage(snapshot
                                                  .data
                                                  ?.data()?['profileUrl'] ??
                                              'https://img.freepik.com/free-vector/illustration-businessman_53876-5856.jpg?w=740&t=st=1694756770~exp=1694757370~hmac=784a2fe19c90be061b47a57b31f312661eee8b3b24de11e4a36d46b8ab5a1014'),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 16,
                                      ),
                                      Text(
                                        snapshot.data?.data()?['name'] ?? '',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      )
                                    ],
                                  );
                                }
                              }),
                          Text(
                            data["text"],
                            style: const TextStyle(fontSize: 20),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              Time.getTimeTitle(data['timestamp']),
                              style: const TextStyle(color: Colors.grey),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    );
                  });
            }),
      ),
    );
  }
}
