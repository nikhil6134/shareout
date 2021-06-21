import 'package:Shareout/constants.dart';
import 'package:Shareout/models/user.dart';
import 'package:Shareout/screens/ActivityFeed.dart';
import 'package:Shareout/screens/Profile.dart';
import 'package:Shareout/screens/Search.dart';
import 'package:Shareout/screens/Timeline.dart';
import 'package:Shareout/screens/Upload.dart';
import 'package:Shareout/screens/createaccount.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final storageRef = FirebaseStorage.instance.ref();
final userRef = Firestore.instance.collection("users");
final postRef = Firestore.instance.collection("posts");
final commentRef = Firestore.instance.collection("comments");
final activityFeedRef = Firestore.instance.collection("feed");
final followersRef = Firestore.instance.collection("followers");
final followingRef = Firestore.instance.collection("following");
final timestamp = DateTime.now();

User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    pageController = PageController();
    super.initState();
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }, onError: (err) {
      print("Error Signing in: $err");
    });
    //function to aunthicate the user first time
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print("Error signing in: $err");
    });
    //reaunthicate user when app is opened
  }

  handleSignIn(GoogleSignInAccount account) {
    createUserInFireStore();
    if (account != null) {
      print("User signed in:$account");
      setState(() {
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFireStore() async {
    //1 . check if user exists in users collection in database(accoridng to the user id)
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await userRef.document(user.id).get();
    // 2. if user doesnt exits then create the user in collection using create account page
    if (!doc.exists) {
      final username =
          await Navigator.pushNamed(context, CreateAccount.routename);

      //3. get username from create account use it to make a new user document in users collection
      userRef.document(user.id).setData({
        "id": user.id,
        "username": username,
        "photoUrl": user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "bio": "",
        "timestamp": timestamp
      });
      doc = await userRef.document(user.id).get();
    }

    currentUser = User.fromDocument(doc);
    print(currentUser);
    print(currentUser.username);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  login() {
    googleSignIn.signIn();
  }

  logout() {
    googleSignIn.signOut();
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(
    int pageIndex,
  ) {
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 300), curve: Curves.bounceInOut);
  }

  Scaffold buildAuthscreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          //TextButton(onPressed: logout, child: Text("Log Out")),

          Timeline(profileId: currentUser?.id),
          ActivityFeed(),
          Upload(currentuser: currentUser),
          Search(),
          Profile(profileId: currentUser?.id),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: pageIndex,
          onTap: onTap,
          selectedItemColor: Theme.of(context).primaryColor,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.whatshot), label: ''),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications_active), label: ''),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.photo_camera,
                  size: 35.0,
                ),
                label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle), label: ''),
          ]),
    );
  }

  buildunAuthscreen(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(gradient: kPrimaryGradientColor),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "ShareOut",
                style: TextStyle(
                    fontFamily: "Signatra",
                    fontSize: 90.0,
                    color: Colors.white),
              ),
              SizedBox(
                height: 5,
              ),
              InkWell(
                onTap: () {
                  login();
                },
                child: Container(
                  width: 260.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage("assets/images/google_signin_button.png"),
                    fit: BoxFit.cover,
                  )),
                ),
              )
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthscreen() : buildunAuthscreen(context);
  }
}
