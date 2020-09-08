import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:job_portal/widgets/post/location_input.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';

class PostCandidiate extends StatefulWidget {
  static const routeName = "/post-candidiate";
  final String username;
  final String userImage;
  File _postImage;
  bool isCandidiate;

  PostCandidiate(
      this.username, this.userImage, this._postImage, this.isCandidiate);
  @override
  _PostCandidiateState createState() => _PostCandidiateState();
}

class _PostCandidiateState extends State<PostCandidiate> {
  TextEditingController _descriptionController = new TextEditingController();
  TextEditingController _locationController = new TextEditingController();

  final uid = FirebaseAuth.instance.currentUser.uid;
  bool isLoading = false;
  String postId = Uuid().v4();

  Future<void> compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(widget._postImage.readAsBytesSync());
    final compressedFile = File("$path/img_$postId.jpg")
      ..writeAsBytesSync(Im.encodeJpg(
        imageFile,
        quality: 90,
      ));

    widget._postImage = compressedFile;
  }

  void _createPost() {
    setState(() {
      isLoading = true;
    });

    compressImage().then((value) {
      print("Compressed!");
      print("After compressing!");
      final ref = FirebaseStorage.instance
          .ref()
          .child("user_posts")
          .child("post_$postId.jpg");

      ref.putFile(widget._postImage).onComplete.then((value) {
        ref.getDownloadURL().then((url) {
          FirebaseFirestore.instance.collection("/posts").doc(postId).set({
            'username': widget.username,
            'userImage': widget.userImage,
            'post_image_url': url,
            'createdAt': Timestamp.now(),
            'is_candidiate': widget.isCandidiate,
            'post_description': _descriptionController.text,
            "location": _locationController.text,
            'posted_by': uid,
            "likes": {}
          }).then((_) {
            print("Completed");
            setState(() {
              isLoading = false;
              Navigator.of(context).pop();
            });
          });
        });
      });
    });
  }

  Widget createPostCaption() {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(50.0),
        child: FadeInImage(
          width: 40,
          height: 40,
          placeholder:
              AssetImage('assets/images/profile_image_placeholder.png'),
          image: NetworkImage(
            widget.userImage,
          ),
          fit: BoxFit.cover,
        ),
      ),
      title: Container(
          width: 250,
          child: TextField(
            decoration: InputDecoration(
                labelText: "Write a caption",
                labelStyle: TextStyle(fontFamily: 'Raleway'),
                border: InputBorder.none),
            keyboardType: TextInputType.multiline,
            maxLines: null,
            controller: _descriptionController,
          )),
    );
  }

  getUserLocation(var lat, var long) async {
    List<Placemark> placemarks =
        await Geolocator().placemarkFromCoordinates(lat, long);
    Placemark placemark = placemarks[0];
    String completeAddress =
        '${placemark.subThoroughfare} ${placemark.thoroughfare}, ${placemark.subLocality} ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea} ${placemark.postalCode}, ${placemark.country}';
    print(completeAddress);
    String formattedAddress = "${placemark.locality}, ${placemark.country}";
    setState(() {
      _locationController.text = formattedAddress;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Build Called");
    print(widget._postImage);
    return Scaffold(
      appBar: AppBar(
        title: new Text("Caption Post"),
        actions: [
          FlatButton(
            child: Text(
              'Post Now',
              style: TextStyle(
                fontFamily: 'Raleway',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            textColor: Colors.pink,
            onPressed: _createPost,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              isLoading ? LinearProgressIndicator() : Text(""),
              Container(
                height: 220,
                width: MediaQuery.of(context).size.width * 0.90,
                child: Center(
                    child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(widget._postImage)),
                    ),
                  ),
                )),
              ),
              SizedBox(height: 10),
              createPostCaption(),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.pin_drop,
                  color: Colors.amber,
                  size: 35,
                ),
                title: Container(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Where was this photo taken?",
                      labelStyle: TextStyle(fontFamily: 'Raleway'),
                      border: InputBorder.none,
                    ),
                    controller: _locationController,
                  ),
                ),
              ),
              LocationInput((lat, long) {
                getUserLocation(lat, long);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
