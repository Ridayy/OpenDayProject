import 'package:flutter/material.dart';
import 'package:job_portal/models/post.dart';
import 'package:job_portal/widgets/post/post_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PostsScreen extends StatefulWidget {
  @override
  _PostsScreenState createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final postItemsArray = [
    // Post(
    //   "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad",
    //   "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_960_720.jpg",
    //   "Just Now",
    // ),
    // Post(
    //   "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad",
    //   "https://cdn.pixabay.com/photo/2018/02/08/22/27/flower-3140492_960_720.jpg",
    //   "Just Now",
    // ),
    // Post(
    //   "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad",
    //   "https://cdn.pixabay.com/photo/2016/08/11/23/48/italy-1587287_960_720.jpg",
    //   "Just Now",
    // ),
    // Post(
    //   "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad",
    //   null,
    //   "Just Now",
    // ),
  ];

  Future<void> refresh() {
    setState(() {});
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser.uid;
    return RefreshIndicator(
      onRefresh: refresh,
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("/posts")
              .orderBy("createdAt", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.data.docs.length == 0) {
              return Center(
                  child: Column(children: [
                Container(
                    margin: EdgeInsets.only(top: 200),
                    width: 150,
                    height: 150,
                    child: SvgPicture.asset("assets/images/no_content.svg")),
                Text("No Posts Yet!", style: Theme.of(context).textTheme.title),
              ]));
            }

            return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (ctx, index) {
                  return PostItem(
                    id: snapshot.data.docs[index].documentID,
                    description:
                        snapshot.data.docs[index].data()["post_description"],
                    image: snapshot.data.docs[index].data()["post_image_url"] ==
                            ""
                        ? null
                        : snapshot.data.docs[index].data()["post_image_url"],
                    timePosted: snapshot.data.docs[index]
                        .data()["createdAt"]
                        .toDate()
                        .toString(),
                    postedBy: StringUtils.capitalize(
                        snapshot.data.docs[index].data()["username"]),
                    uid: snapshot.data.docs[index].data()["posted_by"],
                    userImage: snapshot.data.docs[index].data()["userImage"],
                    location: snapshot.data.docs[index].data()["location"],
                    likes: snapshot.data.docs[index].data()["likes"],
                  );
                });
          }),
    );
  }
}
