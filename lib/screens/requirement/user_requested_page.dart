import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserRequestedPage extends StatefulWidget {
  const UserRequestedPage({super.key});

  @override
  State<UserRequestedPage> createState() => _UserRequestedPageState();
}

class _UserRequestedPageState extends State<UserRequestedPage>
    with TickerProviderStateMixin {
  FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  TabController? _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    user = _auth.currentUser!;
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("request list"),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(user!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasData) {
              final docu = snapshot.data!;
              final List requestList = docu['request'];
              return DefaultTabController(
                length: 2,
                child: NestedScrollView(
                    headerSliverBuilder: (context, _) {
                      return [
                        SliverList(
                            delegate: SliverChildListDelegate([
                          const Text("sdsd"),
                        ]))
                      ];
                    },
                    body: Column(
                      children: [
                        TabBar(controller: _tabController, tabs: const [
                          Tab(
                            text: "Requested",
                          ),
                          Tab(
                            text: "Own Requirements",
                          )
                        ]),
                        Expanded(
                            child: TabBarView(
                                controller: _tabController,
                                children: [
                              ListView.builder(
                                  itemCount: requestList.length,
                                  itemBuilder: (context, index) {
                                    return StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection("requirements")
                                            .doc(requestList[index]
                                                ['requirementId'])
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            final data = snapshot.data!.data()!;
                                            return Card(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        "${data['source']} to ${data['destination']}"),
                                                    Text(
                                                        "${data['weight']} Kg"),
                                                    Text(
                                                      "${data['status']}",
                                                      style: TextStyle(
                                                          color:
                                                              data['status'] ==
                                                                      'active'
                                                                  ? Colors.green
                                                                  : Colors.red),
                                                    ),
                                                    data['status'] == 'active'
                                                        ? Text(
                                                            "${requestList[index]['isAccepted']}",
                                                            style: TextStyle(
                                                                color: requestList[index]
                                                                            [
                                                                            'isAccepted'] ==
                                                                        'pending'
                                                                    ? Colors
                                                                        .yellow
                                                                    : Colors
                                                                        .green),
                                                          )
                                                        : const SizedBox
                                                            .shrink()
                                                  ],
                                                ),
                                              ),
                                            );
                                          } else {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }
                                        });
                                  }),
                              StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection("requirements")
                                      .where(
                                          docu['type'] == "user"
                                              ? "userUid"
                                              : "driverUid",
                                          whereIn: [user!.uid]).snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      final dataList = snapshot.data!.docs;
                                      return ListView.builder(
                                          itemCount: dataList.length,
                                          itemBuilder: (context, index) {
                                            final data = dataList[index].data();
                                            final List reqList =
                                                data['request'];
                                            return Card(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        "${data['source']} to ${data['destination']}"),
                                                    Text(
                                                        "${data['weight']} Kg"),
                                                    Text(
                                                      "${data['status']}",
                                                      style: TextStyle(
                                                          color:
                                                              data['status'] ==
                                                                      'active'
                                                                  ? Colors.green
                                                                  : Colors.red),
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    const Text("Requests"),
                                                    ...reqList.map((ele) {
                                                      return Row(
                                                        children: [
                                                          Text(ele['uid']),
                                                          IconButton(
                                                              onPressed: () {},
                                                              icon: const Icon(
                                                                  Icons.check)),
                                                          IconButton(
                                                              onPressed: () {},
                                                              icon: const Icon(
                                                                  Icons.close)),
                                                        ],
                                                      );
                                                    })

                                                    // data['status'] == 'active'
                                                    //     ? Text(
                                                    //         "${requestList[index]['isAccepted']}",
                                                    //         style: TextStyle(
                                                    //             color: requestList[
                                                    //                             index]
                                                    //                         [
                                                    //                         'isAccepted'] ==
                                                    //                     'pending'
                                                    //                 ? Colors.yellow
                                                    //                 : Colors.green),
                                                    //       )
                                                    //     : const SizedBox.shrink()
                                                  ],
                                                ),
                                              ),
                                            );
                                          });
                                    } else {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                  })
                            ]))
                      ],
                    )),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
    // return Scaffold(
    //   appBar: AppBar(
    //     title: const Text("request list"),
    //   ),
    //   body: Container(
    //     padding: const EdgeInsets.all(16),
    //     child: Column(
    //       children: [
    //         // Text(user!.email ?? ''),
    //         const SizedBox(
    //           height: 16,
    //         ),
    //         StreamBuilder(
    //             stream: FirebaseFirestore.instance
    //                 .collection("users")
    //                 .doc(user!.uid)
    //                 .snapshots(),
    //             builder: (context, snapshot) {
    //               if (snapshot.connectionState == ConnectionState.waiting) {
    //                 return const Center(
    //                   child: CircularProgressIndicator(),
    //                 );
    //               }
    //               if (snapshot.hasError) {
    //                 return const Center(
    //                   child: Text('Error fetching data'),
    //                 );
    //               }
    //               if (snapshot.hasData) {
    //                 final docu = snapshot.data!;
    //                 final List requestList = docu['request'];
    //                 if (requestList.isNotEmpty) {
    //                   return Column(children: [
    //                     TabBar(controller: _tabController, tabs: [
    //                       Tab(
    //                         text: "Requested",
    //                       ),
    //                       Tab(
    //                         text: "Own Requirements",
    //                       )
    //                     ]),
    //                     TabBarView(controller: _tabController, children: [
    //                       ListView.builder(
    //                           itemCount: requestList.length,
    //                           itemBuilder: (context, index) {
    //                             return StreamBuilder(
    //                                 stream: FirebaseFirestore.instance
    //                                     .collection("requirements")
    //                                     .doc(
    //                                         requestList[index]['requirementId'])
    //                                     .snapshots(),
    //                                 builder: (context, snapshot) {
    //                                   if (snapshot.hasData) {
    //                                     final data = snapshot.data!.data();
    //                                     return Text(data!['destination'] ?? '');
    //                                   } else {
    //                                     return const Center(
    //                                       child: CircularProgressIndicator(),
    //                                     );
    //                                   }
    //                                 });

    //                             // return Text(
    //                             //     requestList[index]['requirementId']);
    //                           }),
    //                       Text("d")
    //                     ])
    //                   ]);
    //                 } else {
    //                   return const Center(
    //                     child: Text('No Request'),
    //                   );
    //                 }

    //                 // return ListView.builder(
    //                 //   shrinkWrap: true,
    //                 //   physics: const NeverScrollableScrollPhysics(),
    //                 //   itemCount: docu.length,
    //                 //   // itemCount: posts.length,
    //                 //   itemBuilder: (context, index) {
    //                 //     return getRequirementCards(docu[index]);
    //                 //   },
    //                 // );
    //               }
    //               return const Center(
    //                 child: Text('Error'),
    //               );
    //             })
    //       ],
    //     ),
    //   ),
    // );
  }
}
