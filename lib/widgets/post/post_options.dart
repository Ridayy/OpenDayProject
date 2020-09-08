import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:job_portal/widgets/post/post_candidiate.dart';

class PostOptions extends StatefulWidget {
  @override
  _PostOptionsState createState() => _PostOptionsState();
}

class _PostOptionsState extends State<PostOptions> {
  final uid = FirebaseAuth.instance.currentUser.uid;
  String username;
  String userImage;
  bool isCandidiate;
  Future getCurrentUserInfo() {
    return FirebaseFirestore.instance
        .collection("/users")
        .doc(uid)
        .get()
        .then((userData) {
      username = userData.data()["username"];
      userImage = userData.data()["image_url"];
      isCandidiate = userData.data()["sign_up_as"] == 0 ? true : false;
    });
  }

  File _pickedImage;
  Future<void> handleTakePicture() {
    Navigator.of(context).pop();
    return ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    ).then((pickedImage) {
      return getCurrentUserInfo().then((_) {
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
          return PostCandidiate(
            username,
            userImage,
            pickedImage,
            isCandidiate,
          );
        }));
      });
    });
  }

  Future<void> handleChooseFromGallery() {
    Navigator.of(context).pop();
    return ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 675,
      maxWidth: 960,
    ).then((pickedImage) {
      return getCurrentUserInfo().then((_) {
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
          return PostCandidiate(
            username,
            userImage,
            pickedImage,
            isCandidiate,
          );
        }));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            Theme.of(context).accentColor.withOpacity(0.2),
            Theme.of(context).primaryColor.withOpacity(0.3)
          ])),
          height: 320,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/images/upload.svg",
                height: 200,
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: RaisedButton.icon(
                  icon: Icon(
                    Icons.camera_alt,
                    size: 17,
                  ),
                  label: new Text(
                    "Upload Image",
                    style: TextStyle(
                      fontFamily: 'Raleway',
                    ),
                  ),
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
                ),
              ),
            ],
          )),
    );
  }
}
