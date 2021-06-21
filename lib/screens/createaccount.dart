import 'dart:async';

import 'package:Shareout/constants.dart';
import 'package:Shareout/widgets/header.dart';
import 'package:flutter/material.dart';

class CreateAccount extends StatefulWidget {
  static const String routename = '/create-account';
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scafholdkey = GlobalKey<ScaffoldState>();

  final _formkey = GlobalKey<FormState>();
  String username;

  submit() {
    final form = _formkey.currentState;
    if (form.validate()) {
      form.save();
      SnackBar snackBar = SnackBar(content: Text("Welcome $username"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scafholdkey,
      appBar: header(context,
          titletext: "Set up Your Profile", isBackbutton: false),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Center(
                    child: Text(
                      "create a username",
                      style: TextStyle(fontSize: 25.0),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    child: Form(
                        key: _formkey,
                        child: TextFormField(
                          onSaved: (val) => username = val,
                          autovalidate: true,
                          validator: (val) {
                            if (val.trim().length < 3 || val.isEmpty) {
                              return "username is too short";
                            } else if (val.trim().length > 12) {
                              return "username is too long";
                            } else {
                              return null;
                            }
                          },
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Username",
                              labelStyle: TextStyle(fontSize: 15.0),
                              hintText: "Must be atleast 3 characters"),
                        )),
                  ),
                ),
                GestureDetector(
                  onTap: submit,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: kPrimaryGradientColor,
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Text(
                      "Submit",
                      style: TextStyle(
                          fontSize: 15.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
