import 'dart:io';

import 'package:Shareout/models/user.dart';
import 'package:Shareout/screens/Home.dart';
import 'package:Shareout/widgets/progressbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Upload extends StatefulWidget {
  final User currentuser;

  Upload({@required this.currentuser});
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  TextEditingController locationController = TextEditingController();
  TextEditingController captionController = TextEditingController();
  bool isUploading = false;
  PickedFile pickedfile;
  String postId = Uuid().v4();
  var imageFile;
  handleTakePhoto() async {
    Navigator.pop(context);
    pickedfile = await ImagePicker.platform
        .pickImage(source: ImageSource.camera, maxHeight: 675, maxWidth: 960);
    imageFile = File(pickedfile.path);
    setState(() {
      this.imageFile = imageFile;
    });
  }

  handleTakeFromGallery() async {
    Navigator.pop(context);
    pickedfile = await ImagePicker.platform
        .pickImage(source: ImageSource.gallery, maxHeight: 675, maxWidth: 960);
    imageFile = File(pickedfile.path);
    setState(() {
      this.imageFile = imageFile;
    });
  }

  selectImage(parentcontext) {
    return showDialog(
        context: parentcontext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Create Post"),
            children: [
              SimpleDialogOption(
                child: Text("Photo with Camera"),
                onPressed: handleTakePhoto,
              ),
              SimpleDialogOption(
                child: Text("Image from Gallery"),
                onPressed: handleTakeFromGallery,
              ),
              SimpleDialogOption(
                child: Text("Cance"),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        });
  }

  Container buildSplashScreen() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/images/upload.svg",
            height: 260.0,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                "Upload Image",
                style: TextStyle(color: Colors.white, fontSize: 22.0),
              ),
              color: Colors.deepOrange,
              onPressed: () => selectImage(context),
            ),
          )
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      imageFile = null;
    });
  }

  compressImage() async {
    final tempdir = await getExternalStorageDirectory();
    final path = tempdir.path;
    Im.Image image = Im.decodeImage(imageFile.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(image, quality: 85));

    setState(() {
      imageFile = compressedImageFile;
    });
  }

  Future<String> uploadImage(image) async {
    StorageUploadTask uploadTask =
        storageRef.child("post_$postId.jpg").putFile(imageFile);
    StorageTaskSnapshot storagesnapshot = await uploadTask.onComplete;
    String downloadUrl = await storagesnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFireStore(
      {String mediaUrl, String location, String description}) {
    postRef
        .document(widget.currentuser.id)
        .collection("userPosts")
        .document(postId)
        .setData({
      "postId": postId,
      "ownerId": widget.currentuser.id,
      "username": widget.currentuser.username,
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timestamp": timestamp,
      "likes": {}
    });
  }

  handlesubmitPost() async {
    setState(() {
      isUploading = true;
    });

    await compressImage();
    String mediaUrl = await uploadImage(imageFile);
    createPostInFireStore(
        mediaUrl: mediaUrl,
        location: locationController.text,
        description: captionController.text);

    captionController.clear();
    locationController.clear();

    setState(() {
      imageFile = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: clearImage,
        ),
        title: Text(
          "Caption Post",
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          FlatButton(
              onPressed: isUploading ? null : () => handlesubmitPost(),
              child: Text(
                "Post",
                style: TextStyle(
                    color: Colors.deepOrangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0),
              ))
        ],
      ),
      body: ListView(
        children: [
          isUploading ? linearProgress() : Text(""),
          Container(
            height: 220.0,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(imageFile),
                  )),
                ),
              ),
            ),
          ),
          Padding(
              padding: EdgeInsets.only(
            top: 10.0,
          )),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentuser.photUrl),
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                    hintText: "Write a caption....", border: InputBorder.none),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.deepOrangeAccent,
              size: 35.0,
            ),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: "Where was this photo taken?",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 200.0,
            height: 100.0,
            alignment: Alignment.center,
            child: RaisedButton.icon(
              label: Text(
                "Use Current Location",
                style: TextStyle(color: Colors.white),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              color: Colors.deepOrangeAccent,
              onPressed: getUserLocation,
              icon: Icon(
                Icons.my_location,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  getUserLocation() async {
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark placemark = placemarks[0];

    String completeAddress =
        '${placemark.subThoroughfare} ${placemark.thoroughfare} , ${placemark.subLocality} ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea} ${placemark.postalCode},${placemark.country}';

    print(completeAddress);
    String formatedAddress = "${placemark.locality},${placemark.country}";
    locationController.text = formatedAddress;
  }

  @override
  Widget build(BuildContext context) {
    return imageFile == null ? buildSplashScreen() : buildUploadForm();
  }
}
