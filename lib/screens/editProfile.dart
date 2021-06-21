import 'package:Shareout/models/user.dart';
import 'package:Shareout/screens/Home.dart';
import 'package:Shareout/widgets/progressbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;

  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController displayNamecontroller = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  User user;
  bool _biovalid = true;
  bool _displayvalid = true;
  final _scaffholdKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await userRef.document(widget.currentUserId).get();
    user = User.fromDocument(doc);
    displayNamecontroller.text = user.displayName;
    bioController.text = user.bio;
    setState(() {
      isLoading = false;
    });
  }

  buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "DisplayName",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        TextField(
          controller: displayNamecontroller,
          decoration: InputDecoration(
            hintText: "Update Display Name",
            errorText: _displayvalid ? null : "Display Name is too short",
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Bio",
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            hintText: "Update Bio",
            errorText: _biovalid ? null : "Your Bio is too short",
          ),
        ),
      ],
    );
  }

  updateProfileData() {
    setState(() {
      displayNamecontroller.text.trim().length < 3 ||
              displayNamecontroller.text.isEmpty
          ? _displayvalid = false
          : _displayvalid = true;

      bioController.text.trim().length > 100
          ? _biovalid = false
          : _biovalid = true;
    });
    if (_displayvalid && _biovalid) {
      userRef.document(widget.currentUserId).updateData({
        "displayName": displayNamecontroller.text,
        "bio": bioController.text,
      });
      SnackBar snackBar = SnackBar(content: Text("Profile Updated"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  logout() async {
    await googleSignIn.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Home()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffholdKey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Edit Profile",
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.done,
                  size: 30.0,
                  color: Colors.green,
                ))
          ],
        ),
        body: isLoading
            ? circularProgress()
            : ListView(
                children: [
                  Container(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
                          child: CircleAvatar(
                            radius: 50.0,
                            backgroundImage:
                                CachedNetworkImageProvider(user.photUrl),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [buildDisplayNameField()],
                          ),
                        ),
                        RaisedButton(
                          onPressed: updateProfileData,
                          child: Text(
                            "Update Profile",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: FlatButton.icon(
                            onPressed: logout,
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.red,
                            ),
                            label: Text(
                              "Logout",
                              style:
                                  TextStyle(color: Colors.red, fontSize: 20.0),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ));
  }
}
