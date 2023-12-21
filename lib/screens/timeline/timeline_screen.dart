import 'dart:async';

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
  final StreamController<List<DocumentSnapshot>> _streamController =
      StreamController<List<DocumentSnapshot>>();
  ScrollController scrollController = ScrollController();
  final List<DocumentSnapshot> _posts = [];

  bool _isRequesting = false;
  bool _isFinish = false;

  void onChangeData(List<DocumentChange> documentChanges) {
    var isChange = false;
    documentChanges.forEach((postChange) {
      if (postChange.type == DocumentChangeType.modified) {
        int indexWhere = _posts.indexWhere((product) {
          return postChange.doc.id == product.id;
        });

        if (indexWhere >= 0) {
          _posts[indexWhere] = postChange.doc;
        }
        isChange = true;
      }
    });

    if (isChange) {
      _streamController.add(_posts);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance
        .collection('posts')
        .snapshots()
        .listen((data) => onChangeData(data.docChanges));
    requestNextPage();
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      print("at the end of list");
      requestNextPage();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _streamController.close();

    super.dispose();
  }

  void requestNextPage() async {
    if (!_isRequesting && !_isFinish) {
      QuerySnapshot querySnapshot;
      _isRequesting = true;
      if (_posts.isEmpty) {
        querySnapshot =
            await FirebaseFirestore.instance.collection('posts').limit(3).get();
      } else {
        querySnapshot = await FirebaseFirestore.instance
            .collection('posts')
            .startAfterDocument(_posts[_posts.length - 1])
            .limit(3)
            .get();
      }

      if (querySnapshot != null) {
        int oldSize = _posts.length;
        _posts.addAll(querySnapshot.docs);
        int newSize = _posts.length;
        if (oldSize != newSize) {
          _streamController.add(_posts);
        } else {
          _isFinish = true;
        }
      }
      _isRequesting = false;
    }
  }

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
        // child: StreamBuilder<QuerySnapshot>(
        child: StreamBuilder<List<DocumentSnapshot>>(
            // stream: FirebaseDatabase.getPosts(),
            stream: _streamController.stream,
            builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
              // QuerySnapshot? querySnapshot = snapshot.data;
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final querySnapshot = snapshot.data;

              if (querySnapshot!.isEmpty) {
                return const Center(child: Text('No Post Listed Here'));
              }
              return ListView.builder(
                  controller: scrollController,
                  itemCount: querySnapshot.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data =
                        querySnapshot[index].data() as Map<String, dynamic>;
                    final docId = querySnapshot[index].id;

                    return Container(
                      height: 300,
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
                                ;
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
                                      ),
                                      const SizedBox(
                                        width: 16,
                                      ),
                                      data['status']
                                          ? ElevatedButton(
                                              onPressed: () {},
                                              child: const Text("Requested"))
                                          : FilledButton(
                                              onPressed: () async {
                                                await FirebaseFirestore.instance
                                                    .collection('posts')
                                                    .doc(docId)
                                                    .update({"status": true});
                                              },
                                              child: const Text("Request"))
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
