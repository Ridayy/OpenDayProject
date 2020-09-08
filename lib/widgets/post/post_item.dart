import 'dart:async';

import 'package:flutter/material.dart';
import 'package:job_portal/screens/comments_screen.dart';
import 'package:job_portal/screens/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:job_portal/models/UserDetailsProvider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animator/animator.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostItem extends StatefulWidget {
  final String description;
  final String timePosted;
  final String image;
  final String uid;
  final String postedBy;
  final String userImage;
  final String location;
  Map likes = {};
  String id = "";

  bool isLiked = false;

  PostItem(
      {this.description,
      this.timePosted,
      this.image,
      this.uid,
      this.postedBy,
      this.userImage,
      this.location,
      this.likes,
      this.id});

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  var likesCount;
  var showHeart = false;
  @override
  void initState() {
    super.initState();
    isLiked();
    likesCount = getLikeCount(widget.likes);
  }

  convertToAgo(String time) {
    final fifteenAgo = DateTime.now()
        .subtract(DateTime.now().difference(DateTime.parse(time)));
    return timeago.format(fifteenAgo);
  }

  int getLikeCount(likes) {
    // if no likes, return 0
    if (likes == null) {
      return 0;
    }
    int count = 0;
    // if the key is explicitly set to true, add a like
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  void handleComment() {
    print("Handling comments!");
    Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return CommentsScreen(widget.id, widget.uid, widget.image);
    }));
  }

  Future<bool> isLiked() {
    print("I am called");
    return FirebaseFirestore.instance
        .collection("/posts")
        .doc(widget.id)
        .get()
        .then((postData) {
      var likesArray = postData.data()["likes"];
      setState(() {
        print("Yes liked!");
        widget.isLiked =
            (likesArray[FirebaseAuth.instance.currentUser.uid] == true);
      });

      return Future.value(widget.isLiked);
    });
  }

  void addNotification() {
    if (FirebaseAuth.instance.currentUser.uid == widget.uid) {
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
          .doc(widget.uid)
          .collection("items")
          .doc(widget.id)
          .set({
        "type": "like",
        "username": username,
        "userId": currentUserId,
        "userProfileImg": currentUserPhotoUrl,
        "post_url": widget.image,
        "createdAt": Timestamp.now(),
      });
    });
  }

  void handleLike() {
    print("Liking post!");
    isLiked().then((value) {
      widget.isLiked = value;
    });
    if (widget.isLiked) {
      setState(() {
        likesCount -= 1;
        widget.isLiked = false;
        FirebaseFirestore.instance.collection("/posts").doc(widget.id).update({
          'likes.${FirebaseAuth.instance.currentUser.uid}': false,
        });
      });
    } else {
      setState(() {
        likesCount += 1;
        widget.isLiked = true;
        FirebaseFirestore.instance.collection("/posts").doc(widget.id).update({
          'likes.${FirebaseAuth.instance.currentUser.uid}': true,
        });
        showHeart = true;
        addNotification();
      });

      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onDoubleTap: handleLike,
      child: Container(
        margin: EdgeInsets.all(10),
        child: new Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
          margin: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.image != null)
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: Stack(children: [
                    FadeInImage(
                        placeholder:
                            AssetImage("assets/images/post_loading.png"),
                        fit: BoxFit.cover,
                        height: 250,
                        width: double.infinity,
                        image: NetworkImage(
                          this.widget.image,
                        )),
                    showHeart
                        ? Positioned(
                            top: 50,
                            left: 120,
                            child: Animator(
                                duration: Duration(milliseconds: 300),
                                tween: Tween(begin: 0.8, end: 1.4),
                                curve: Curves.elasticOut,
                                cycles: 0,
                                builder: (ctx, anim, _) {
                                  return Transform.scale(
                                    scale: anim.value,
                                    child: Icon(
                                      Icons.favorite,
                                      size: 80.0,
                                      color: Colors.red,
                                    ),
                                  );
                                }),
                          )
                        : Text("")
                  ]),
                ),
              SizedBox(height: 10),
              InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(ProfileScreen.routeName,
                      arguments: this.widget.uid);
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  child: Row(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: FadeInImage(
                        width: 20,
                        height: 20,
                        placeholder: AssetImage(
                            'assets/images/profile_image_placeholder.png'),
                        image: NetworkImage(
                          widget.userImage,
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              this.widget.postedBy,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                                fontSize: 17,
                              ),
                            ),
                            Row(
                              children: [
                                if (this.widget.location != "")
                                  Icon(Icons.my_location,
                                      color: Colors.amber[900]),
                                SizedBox(width: 5),
                                Text(this.widget.location,
                                    style: TextStyle(
                                      color: Colors.amber[900],
                                    )),
                              ],
                            )
                          ]),
                    ),
                  ]),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Text(
                  this.widget.description,
                  style: TextStyle(),
                  // textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.all(20),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    new Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            widget.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.red,
                            size: 24,
                          ),
                          onPressed: () {
                            handleLike();
                          },
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.comment,
                            color: Colors.blue,
                            size: 24,
                          ),
                          onPressed: handleComment,
                        ),
                        Text("( " + getLikeCount(this.widget.likes).toString()),
                        SizedBox(
                          width: 6,
                        ),
                        Text("like(s) )")
                      ],
                    ),
                    new Row(
                      children: [
                        Icon(Icons.schedule),
                        SizedBox(
                          width: 6,
                        ),
                        Text(convertToAgo(this.widget.timePosted),
                            style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
