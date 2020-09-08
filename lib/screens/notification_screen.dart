import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  Future getNotifications() {
    return FirebaseFirestore.instance
        .collection("notification")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("items")
        .orderBy("createdAt", descending: true)
        .limit(50)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: FutureBuilder(
      future: getNotifications(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (ctx, index) {
              print(snapshot.data.docs.length);

              return Column(children: [
                ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(50.0),
                    child: FadeInImage(
                      width: 50,
                      height: 50,
                      placeholder: AssetImage(
                          'assets/images/profile_image_placeholder.png'),
                      image: NetworkImage(
                        snapshot.data.docs[index].data()["userProfileImg"],
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    StringUtils.capitalize(
                        snapshot.data.docs[index].data()["username"]),
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle:
                      (snapshot.data.docs[index].data()["type"] == "comment")
                          ? Text("Commented on your post!")
                          : (snapshot.data.docs[index].data()["type"] == "like")
                              ? Text("Liked  your post!")
                              : Text("started Following you"),
                  trailing: Column(children: [
                    Text(
                      convertToAgo(snapshot.data.docs[index]
                          .data()["createdAt"]
                          .toDate()
                          .toString()),
                    ),
                    Container(
                      width: 70,
                      height: 30,
                      child: Image.network(
                        snapshot.data.docs[index].data()["post_url"],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ]),
                ),
                Divider(),
              ]);
            });
      },
    )));
  }

  convertToAgo(String time) {
    final fifteenAgo = DateTime.now()
        .subtract(DateTime.now().difference(DateTime.parse(time)));
    return timeago.format(fifteenAgo);
  }
}
