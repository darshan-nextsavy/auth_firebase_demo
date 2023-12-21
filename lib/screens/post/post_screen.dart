import 'package:auth_firebase_demo/firebase/firebase_database.dart';
import 'package:auth_firebase_demo/model/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/time.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  TextEditingController postText = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  void showSnackbar(text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser!;
  }

  void onAddPost() async {
    if (postText.text.trim() != '') {
      try {
        FirebaseDatabase.addPost(Post(
            status: false,
            text: postText.text.trim(),
            uid: user!.uid,
            timestamp: DateTime.now().microsecondsSinceEpoch));

        postText.clear();
        Navigator.pop(context);
      } catch (e) {
        Navigator.pop(context);
        showSnackbar(e.toString());
      }
    } else {
      showSnackbar('Enter text');
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.text,
                      controller: postText,
                      maxLength: 100,
                      maxLines: 3,
                      decoration:
                          const InputDecoration(labelText: 'Enter text'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CupertinoButton(
                      onPressed: () {
                        onAddPost();
                      },
                      color: Colors.green.shade600,
                      child: const Text('Add Post'),
                    )
                  ],
                )));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f0f0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Posts'),
        actions: [
          IconButton(
              onPressed: () {
                _showBottomSheet(context);
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseDatabase.getUsersPost(user?.uid),
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
                          Text(
                            data["text"],
                            style: const TextStyle(fontSize: 18),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              Time.getTimeTitle(data['timestamp']),
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
