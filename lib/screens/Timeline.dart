import 'package:Shareout/screens/Home.dart';
import 'package:Shareout/widgets/header.dart';
import 'package:Shareout/widgets/post.dart';
import 'package:Shareout/widgets/progressbar.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Timeline extends StatefulWidget {
  String profileId;

  Timeline({this.profileId});

  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List followingList = ['105325078393103429888'];
  int followingCount = 0;
  List timeLinePosts = [];
  List<Post> posts = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getFollowing();
  }

  getFollowing() async {
    setState(() {
      isLoading = true;
    });
    List<Post> posts = [];

    QuerySnapshot snapshot = await followingRef
        .document(widget.profileId)
        .collection("userFollowing")
        .getDocuments();

    setState(() {
      followingList += snapshot.documents.map((doc) => doc.documentID).toList();
      print(followingList);
    });
    for (int i = 0; i < followingList.length; i++) {
      QuerySnapshot snapshots = await Firestore.instance
          .collection('posts/${followingList[i]}/userPosts')
          .orderBy('timestamp', descending: true)
          .getDocuments();

      posts +=
          snapshots.documents.map((doc) => Post.fromDocument(doc)).toList();
    }
    setState(() {
      isLoading = false;
      this.posts = posts;
      isLoading = false;
      print(posts);
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
        appBar: header(context, isapptitle: true),
        body: isLoading
            ? Center(
                child: circularProgress(),
              )
            : SingleChildScrollView(
                child: Column(
                  children: posts,
                ),
              ));
  }
}
