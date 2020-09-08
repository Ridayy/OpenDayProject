import 'dart:io';

import 'package:flutter/material.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfileScreen extends StatefulWidget {
  static const routeName = "/edit-profile";

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool isLoading = false;
  File _pickedImage;
  TextEditingController usernameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  final uid = FirebaseAuth.instance.currentUser.uid;
  bool usernameValid = true;
  bool bioValid = true;
  String userProfilePic;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> handleTakePicture() {
    Navigator.of(context).pop();
    return ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    ).then((pickedImage) {
      setState(() {
        _pickedImage = pickedImage;
      });
    });
  }

  Future<File> compressImage(image) async {
    String image_id = Uuid().v4();
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(image.readAsBytesSync());
    final compressedFile = File("$path/img_$image_id.jpg")
      ..writeAsBytesSync(Im.encodeJpg(
        imageFile,
        quality: 90,
      ));
    return Future.value(compressedFile);
  }

  Future<void> handleChooseFromGallery() {
    Navigator.of(context).pop();
    return ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 675,
      maxWidth: 960,
    ).then((pickedImage) {
      setState(() {
        _pickedImage = pickedImage;
      });
    });
  }

  void updateProfileData() {
    if (usernameController.text.trim().isEmpty ||
        usernameController.text.trim().length < 4) {
      usernameValid = false;
    }

    if (!bioController.text.trim().isEmpty) {
      if (bioController.text.trim().length < 20) {
        bioValid = false;
      }
    }

    if (bioValid && usernameValid) {
      setState(() {
        isLoading = true;
      });

      if (_pickedImage != null) {
        final ref =
            FirebaseStorage.instance.ref().child("user_images").child(uid);

        compressImage(_pickedImage).then((compressed_image) {
          ref.putFile(compressed_image).onComplete.then((value) {
            ref.getDownloadURL().then((url) {
              FirebaseFirestore.instance.collection("/users").doc(uid).update({
                "username": usernameController.text.toLowerCase(),
                "bio": bioController.text,
                "image_url": url,
              }).then((userData) {
                setState(() {
                  isLoading = false;
                });
                _scaffoldKey.currentState.showSnackBar(SnackBar(
                  content: Text(
                    "Profile Updated!",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                    textAlign: TextAlign.center,
                  ),
                  backgroundColor: Colors.black,
                ));
              });
            });
          });
        });
      } else {
        FirebaseFirestore.instance.collection("/users").doc(uid).update({
          "username": usernameController.text.toLowerCase(),
          "bio": bioController.text,
        }).then((userData) {
          setState(() {
            isLoading = false;
          });
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text(
              "Profile Updated!",
              style: TextStyle(color: Theme.of(context).primaryColor),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.black,
          ));
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments =
        ModalRoute.of(context).settings.arguments as Map<String, String>;
    usernameController.text = StringUtils.capitalize(arguments["username"]);
    bioController.text = arguments["bio"];
    userProfilePic = arguments['userImage'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Edit Profile"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: isLoading
                ? null
                : () {
                    updateProfileData();
                  },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          isLoading ? LinearProgressIndicator() : Text(""),
          Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50.0),
                  child: FadeInImage(
                    width: 100,
                    height: 100,
                    placeholder: AssetImage(
                        'assets/images/profile_image_placeholder.png'),
                    image: _pickedImage == null
                        ? NetworkImage(
                            userProfilePic,
                          )
                        : FileImage(_pickedImage),
                    fit: BoxFit.cover,
                  ),
                ),
                FlatButton.icon(
                  icon: Icon(Icons.image),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (ctx) {
                          return SimpleDialog(
                            title: new Text("Create Post"),
                            children: [
                              SimpleDialogOption(
                                child: Row(children: [
                                  Icon(Icons.camera_alt,
                                      color: Theme.of(context).primaryColor),
                                  SizedBox(width: 10),
                                  Text("Take Picture"),
                                ]),
                                onPressed: handleTakePicture,
                              ),
                              SimpleDialogOption(
                                child: Row(children: [
                                  Icon(Icons.photo_library,
                                      color: Theme.of(context).primaryColor),
                                  SizedBox(width: 10),
                                  Text("Choose From Gallery"),
                                ]),
                                onPressed: handleChooseFromGallery,
                              ),
                              SimpleDialogOption(
                                child: Row(children: [
                                  Icon(Icons.cancel,
                                      color: Theme.of(context).primaryColor),
                                  SizedBox(width: 10),
                                  Text("Cancel"),
                                ]),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        });
                  },
                  label: new Text(
                    "Change Image",
                    style: TextStyle(
                        fontFamily: 'Raleway', fontWeight: FontWeight.bold),
                  ),
                  textColor: Theme.of(context).primaryColor,
                ),
                TextField(
                  decoration: InputDecoration(
                      labelText: "Username",
                      labelStyle: TextStyle(fontFamily: 'Raleway'),
                      errorText:
                          usernameValid ? null : "Username is too short"),
                  controller: usernameController,
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  decoration: InputDecoration(
                      labelText: "Bio",
                      labelStyle: TextStyle(fontFamily: 'Raleway'),
                      errorText: bioValid ? null : "Bio is too short"),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  controller: bioController,
                ),
                SizedBox(
                  height: 20,
                ),
                isLoading
                    ? CircularProgressIndicator()
                    : RaisedButton.icon(
                        icon: Icon(
                          Icons.create,
                          size: 17,
                        ),
                        color: Theme.of(context).primaryColor,
                        label: Text(
                          "Update",
                          style: TextStyle(
                            fontFamily: 'Raleway',
                          ),
                        ),
                        onPressed: () {
                          updateProfileData();
                        },
                      )
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
