import 'dart:io';
import 'package:auth_firebase_demo/model/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

class FirebaseDatabase {
  static Future<void> addPost(Post post) async {
    await FirebaseFirestore.instance.collection('posts').add(post.toJson());
  }

  static Stream<QuerySnapshot> getUsersPost(uid) {
    return FirebaseFirestore.instance
        .collection('posts')
        .where('uid', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getUserByPhone(
      String phone) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("phone", isEqualTo: phone)
        .get();
  }

  static Stream<QuerySnapshot> getPosts() {
    return FirebaseFirestore.instance
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  static Future<String> uploadImageToFirebase(File imageFile) async {
    try {
      String fileName = basename(imageFile.path);
      Reference storageReference =
          FirebaseStorage.instance.ref().child('images/$fileName');

      UploadTask uploadTask = storageReference.putFile(imageFile);
      await uploadTask.whenComplete(() => print('Image uploaded'));
      String downloadURL = await storageReference.getDownloadURL();

      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      return 'error';
    }
  }

  static Future<void> updatePhone(String phone, String uid) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update({"phone": phone});
  }

  static Future<void> updateName(String name, String uid) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update({"name": name});
  }

  static Future<void> addUserWithProfile(
      String uid, String phone, String url, String name) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .set({"phone": phone, "name": name, "profileUrl": url});
  }

  static Future<void> addUserWithOutProfile(
      String uid, String phone, String name) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .set({"phone": phone, "name": name});
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> getUser(
      String uid) async {
    return await FirebaseFirestore.instance.collection("users").doc(uid).get();
  }
}
