import 'package:Shareout/routes.dart';
import 'package:Shareout/screens/splash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firestore.instance.settings(timestampsInSnapshotsEnabled: true).then((_) {
    print("Timestamps enabled in snapshots\n");
  }, onError: (_) {
    print("Error enabling TimeStamps enabled in snapshots\n");
  });

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShareOut',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        accentColor: Colors.blueAccent,
      ),
      home: Splash(),
      routes: routes,
    );
  }
}
