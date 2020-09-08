import 'dart:io';

import 'package:flutter/material.dart';
import '../widgets/auth/auth_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:basic_utils/basic_utils.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;

  Future<File> compressImage(File image) async {
    String image_Id = Uuid().v4();
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(image.readAsBytesSync());
    final compressedFile = File("$path/img_$image_Id.jpg")
      ..writeAsBytesSync(Im.encodeJpg(
        imageFile,
        quality: 90,
      ));

    return Future.value(compressedFile);
    ;
  }

  var _isLoading = false;
  void _submitAuthForm(
      String email,
      String password,
      String username,
      File image,
      int signUpAs,
      DateTime dateTime,
      bool isLogin,
      BuildContext ctx) {
    setState(() {
      _isLoading = true;
    });
    if (isLogin) {
      print("Logging in!");
      print(email);
      print(password);
      _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then(
            (authResult) {},
          )
          .catchError(
        (error) {
          if (error.message != null) {
            Scaffold.of(ctx).showSnackBar(new SnackBar(
              content: Text(error.message),
              backgroundColor: Theme.of(ctx).errorColor,
            ));
            setState(() {
              _isLoading = false;
            });
          }
          print(error);
        },
      );
    } else {
      _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then(
        (authResult) {
          final ref = FirebaseStorage.instance
              .ref()
              .child("user_images")
              .child(authResult.user.uid);

          compressImage(image).then((compressed_image) {
            ref.putFile(compressed_image).onComplete.then((value) {
              ref.getDownloadURL().then((url) {
                FirebaseFirestore.instance
                    .collection("/users")
                    .doc(authResult.user.uid)
                    .set({
                  'username': username.toLowerCase(),
                  'email': email,
                  'image_url': url,
                  'sign_up_as': 0,
                  'birthdate': DateFormat.yMd().format(dateTime),
                  "bio": ""
                }).then((value) => null);
              });
            });
          });

          // Actual Upload
        },
      ).catchError((error) {
        if (error != null) {
          Scaffold.of(ctx).showSnackBar(
            new SnackBar(
              content: Text(error.message),
              backgroundColor: Theme.of(ctx).errorColor,
            ),
          );
          print(error);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor.withOpacity(0.6),
            ],
          ),
        ),
        child: AuthForm(
          _submitAuthForm,
          _isLoading,
        ),
      ),
    );
  }
}
