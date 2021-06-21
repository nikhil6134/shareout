import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String photUrl;
  final String displayName;
  final String bio;

  User(
      {this.id,
      this.bio,
      this.username,
      this.displayName,
      this.email,
      this.photUrl});

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
        id: doc['id'],
        email: doc['email'],
        bio: doc['bio'],
        displayName: doc['displayName'],
        photUrl: doc['photoUrl'],
        username: doc['username']);
  }
}
