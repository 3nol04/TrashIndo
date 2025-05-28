import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trashindo/model/User.dart' as user;

class UserServices {

  Future <user.User> getUser(String id) async {
    final docUser = await FirebaseFirestore.instance.collection('users').doc(id).get();
    final userData = user.User.fromToJson(docUser);
    return userData;
  }
}