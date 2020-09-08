import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:job_portal/models/UserDetailsProvider.dart';
import 'package:job_portal/widgets/drawer/drawer.dart';
import 'package:job_portal/widgets/newsfeed_views/employer_view.dart';
import 'package:provider/provider.dart';
import '../widgets/newsfeed_views/candidiate_view.dart';
import '../widgets/newsfeed_views/employer_view.dart';

class NewsFeedScreen extends StatelessWidget {
  final uid = FirebaseAuth.instance.currentUser.uid;
  bool isCandidiate = true;
  String username;
  String userImage;

  @override
  Widget build(BuildContext context) {
    // FirebaseAuth.instance.signOut();
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("/users")
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.data.data() == null) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          username = snapshot.data.data()["username"];
          userImage = snapshot.data.data()["image_url"];
          isCandidiate = snapshot.data.data()["sign_up_as"] == 0 ? true : false;

          if (isCandidiate) {
            // print(username);
            // print(userImage);

            return CandidiateView(username, userImage);
          } else {
            return EmployerView(username, userImage);
          }
        });
  }
}
