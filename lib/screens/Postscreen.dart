import 'package:Shareout/screens/Home.dart';
import 'package:Shareout/widgets/header.dart';
import 'package:Shareout/widgets/post.dart';
import 'package:Shareout/widgets/progressbar.dart';
import 'package:flutter/material.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;

  PostScreen({this.postId, this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: postRef
            .document(userId)
            .collection('userPosts')
            .document(postId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          Post post = Post.fromDocument(snapshot.data);
          return Center(
            child: Scaffold(
              appBar: header(context, titletext: post.description),
              body: ListView(
                children: [
                  Container(
                    child: post,
                  )
                ],
              ),
            ),
          );
        });
  }
}
