import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:job_portal/screens/profile_screen.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:basic_utils/basic_utils.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  final String userId;
  final String postImageUrl;

  CommentsScreen(this.postId, this.userId, this.postImageUrl);

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  TextEditingController commentsController = new TextEditingController();
  buildComments() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("/post_comments")
            .doc(widget.postId)
            .collection("comments")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (ctx, index) {
                print(snapshot.data.docs[index].data());
                return Comment(
                    snapshot.data.docs[index].data()["username"],
                    snapshot.data.docs[index].data()["uid"],
                    snapshot.data.docs[index].data()["avatarUrl"],
                    snapshot.data.docs[index].data()["comment"],
                    convertToAgo(snapshot.data.docs[index]
                        .data()["createdAt"]
                        .toDate()
                        .toString()));
              });
        });
  }

  convertToAgo(String time) {
    final fifteenAgo = DateTime.now()
        .subtract(DateTime.now().difference(DateTime.parse(time)));
    return timeago.format(fifteenAgo);
  }

  void addComment() {
    var username;
    var currentUserPhotoUrl;
    var currentUserId = FirebaseAuth.instance.currentUser.uid;
    FirebaseFirestore.instance
        .collection("/users")
        .doc(currentUserId)
        .get()
        .then((userData) {
      username = userData.data()["username"];
      currentUserPhotoUrl = userData.data()["image_url"];
      print("Adding comment by " + username);
      FirebaseFirestore.instance
          .collection("/post_comments")
          .doc(widget.postId)
          .collection("comments")
          .add({
        "username": username,
        "uid": currentUserId,
        "comment": commentsController.text,
        "createdAt": Timestamp.now(),
        "avatarUrl": currentUserPhotoUrl,
      }).then((_) {
        commentsController.clear();
        addNotification();
      });
    });
  }

  void addNotification() {
    if (FirebaseAuth.instance.currentUser.uid == widget.userId) {
      return;
    }
    print("Adding Notification!");
    var currentUserId = FirebaseAuth.instance.currentUser.uid;
    var username;
    var currentUserPhotoUrl;
    FirebaseFirestore.instance
        .collection("/users")
        .doc(currentUserId)
        .get()
        .then((userData) {
      username = userData.data()["username"];
      currentUserPhotoUrl = userData.data()["image_url"];
      FirebaseFirestore.instance
          .collection("notification")
          .doc(widget.userId)
          .collection("items")
          .add({
        "type": "comment",
        "username": username,
        "userId": currentUserId,
        "userProfileImg": currentUserPhotoUrl,
        "post_url": widget.postImageUrl,
        "createdAt": Timestamp.now(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Commments")),
        body: Column(children: [
          Expanded(child: buildComments()),
          Row(children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: commentsController,
                  decoration: InputDecoration(
                      labelText: "Post a comment",
                      labelStyle: TextStyle(fontFamily: 'Raleway')),
                  // onChanged: (value) {
                  //   setState(() {
                  //     // enteredMessage = value;
                  //   });
                  // },
                ),
              ),
            ),
            IconButton(
              color: Theme.of(context).primaryColor,
              icon: Icon(Icons.send),
              onPressed: addComment,
            ),
          ]),
        ]));
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final String time;

  const Comment(
      this.username, this.userId, this.avatarUrl, this.comment, this.time);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(children: [
      ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(50.0),
          child: FadeInImage(
            width: 50,
            height: 50,
            placeholder:
                AssetImage('assets/images/profile_image_placeholder.png'),
            image: NetworkImage(
              avatarUrl,
            ),
            fit: BoxFit.cover,
          ),
        ),
        title: InkWell(
          onTap: () {
            Navigator.of(context)
                .pushNamed(ProfileScreen.routeName, arguments: userId);
          },
          child: Text(
            StringUtils.capitalize(username),
            style: TextStyle(
              fontFamily: 'Raleway',
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        subtitle: Text(comment),
        trailing: Text(time),
      ),
      Divider(),
    ]);
  }
}
