import 'package:flutter/material.dart';

Widget header(BuildContext context,
    {bool isapptitle = false, String titletext, bool isBackbutton = true}) {
  return AppBar(
    automaticallyImplyLeading: isBackbutton ? true : false,
    backgroundColor: Colors.white,
    centerTitle: true,
    iconTheme: IconThemeData(color: Colors.black),
    elevation: 0,
    title: Text(
      isapptitle ? "Shareout" : titletext,
      style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: isapptitle ? 50 : 25,
          fontFamily: isapptitle ? 'Signatra' : " "),
      overflow: TextOverflow.ellipsis,
    ),
  );
}
