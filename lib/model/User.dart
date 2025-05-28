import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String name;
  String image;
  String email;
  String password;
  User(
      {required this.id,
      required this.name,
      required this.image,
      required this.email,
      required this.password});

  factory User.fromToJson(DocumentSnapshot data) {
    final json = data.data() as Map<String, dynamic>;
    return User(
      id: data.id,
      image: json['image'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
    );
  }
}
