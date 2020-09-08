import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:job_portal/models/post.dart';
import 'package:job_portal/widgets/post/create_profile_post.dart';
import 'package:job_portal/widgets/post/post_item.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = "/user-profile";

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isMe = false;
  String uid;
  String username;
  String userDescription;
  String profilePic;
  String bio;
  bool isLoading = false;
  var postsCount = 0;
  var userId;
  List userPosts = [];
  String postOrientation = "grid";
  bool isFollowing = false;
  int followerCount = 0;
  int followingCount = 0;

  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  bool checkIfMe(BuildContext context) {
    uid = ModalRoute.of(context).settings.arguments;
    userId = uid;
    print(uid);
    print("user..");
    print(FirebaseAuth.instance.currentUser.uid == uid);
    return FirebaseAuth.instance.currentUser.uid == uid;
  }

  Future<void> getUserDetails() {
    return FirebaseFirestore.instance
        .collection("/users")
        .doc(uid)
        .get()
        .then((userData) {
      username = StringUtils.capitalize(userData.data()['username']);
      profilePic = userData.data()['image_url'];
      bio = userData.data()['bio'];
    });
  }

  void _selectHandler(BuildContext context) {
    if (isMe) {
      Navigator.of(context).pushNamed(EditProfileScreen.routeName, arguments: {
        "uid": uid,
        "username": username,
        "userImage": profilePic,
        "bio": bio
      }).then((value) {
        setState(() {});
      });
    } else if (isFollowing) {
      handleUnfollowUser();
    } else {
      handleFollowUser();
    }
  }

  void addNotification() {
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
          .doc(userId)
          .collection("items")
          .add({
        "type": "following",
        "username": username,
        "userId": currentUserId,
        "userProfileImg": currentUserPhotoUrl,
        "post_url": "",
        "createdAt": Timestamp.now(),
      });
    });
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection("followers")
        .doc(userId)
        .collection("userFollowers")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("followers")
        .doc(userId)
        .collection("userFollowers")
        .getDocuments();
    setState(() {
      followerCount = snapshot.documents.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("following")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("userFollowing")
        .getDocuments();
    setState(() {
      followingCount = snapshot.documents.length;
    });
  }

  void handleUnfollowUser() {
    setState(() {
      isFollowing = false;
      followerCount -= 1;
    });
    FirebaseFirestore.instance
        .collection("followers")
        .doc(userId)
        .collection("userFollowers")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .delete();
    FirebaseFirestore.instance
        .collection("following")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("userFollowing")
        .doc(userId)
        .delete();
  }

  void handleFollowUser() {
    setState(() {
      isFollowing = true;
      followerCount += 1;
    });

    FirebaseFirestore.instance
        .collection("followers")
        .doc(userId)
        .collection("userFollowers")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .set({});
    FirebaseFirestore.instance
        .collection("following")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("userFollowing")
        .doc(userId)
        .set({});
    addNotification();
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(Icons.grid_on),
          color: Theme.of(context).primaryColor,
          onPressed: () {
            setState(() {
              postOrientation = "grid";
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.list),
          color: Colors.grey,
          onPressed: () {
            setState(() {
              postOrientation = "list";
            });
          },
        ),
      ],
    );
  }

  void getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    final uid = FirebaseAuth.instance.currentUser.uid;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("/posts")
        .where("posted_by", isEqualTo: userId)
        .orderBy("createdAt", descending: true)
        .get();

    setState(() {
      isLoading = false;
      postsCount = snapshot.docs.length;
      print("GOT IT");

      userPosts = snapshot.docs.map((doc) {
        print(doc.data());
        return Post(
            doc.data()["post_description"],
            doc.data()["post_image_url"],
            doc.data()["createdAt"].toDate().toString(),
            doc.data()["username"],
            userId,
            location: doc.data()["location"],
            userImage: doc.data()["post_image_url"]);
      }).toList();
    });
  }

  Widget buildListPosts() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: userPosts.length,
        itemBuilder: (ctx, index) {
          return PostItem(
            description: userPosts[index].description,
            image: userPosts[index].imageUrl,
            timePosted: userPosts[index].time,
            postedBy: StringUtils.capitalize(userPosts[index].postedBy),
            userImage: userPosts[index].userImage,
            location: userPosts[index].location,
            likes: {},
          );
        });
  }

  buildProfilePosts() {
    print("I am called!");
    if (isLoading) {
      return CircularProgressIndicator();
    }
    if (userPosts.length == 0) {
      return Column(children: [
        Center(
            child: Container(
          width: 100,
          height: 100,
          child: SvgPicture.asset(
            "assets/images/no_content.svg",
          ),
        )),
        Center(
          child: Text("No content to show!",
              style: Theme.of(context).textTheme.title),
        ),
      ]);
    }
    if (postOrientation == "grid") {
      return GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            mainAxisSpacing: 1.5,
            crossAxisSpacing: 1.5,
          ),
          itemCount: userPosts.length,
          itemBuilder: (ctx, index) {
            print(index);
            print(userPosts.length);
            print(userPosts[index]);
            print(userPosts[index]
                .convertToAgo(userPosts[index].time)
                .toString());

            return CreateProfilePost(userPosts[index].imageUrl);
          });
    } else if (postOrientation == "list") {
      return buildListPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    isMe = checkIfMe(context);
    return FutureBuilder(
      future: getUserDetails(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: new Text(
                      username,
                      // style: TextStyle(backgroundColor: Colors.purple),
                    ),
                    background: Hero(
                      tag: "123",
                      child: Stack(children: [
                        Container(
                          width: double.infinity,
                          height: 350,
                          child: Image.network(
                            profilePic,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(width: double.infinity, color: Colors.black38)
                      ]),
                    ),
                  )),
              SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    width: 100,
                    margin: EdgeInsets.only(
                        top: 10, left: 80, right: 80, bottom: 10),
                    child: RaisedButton.icon(
                        onPressed: () {
                          _selectHandler(context);
                        },
                        icon: Icon(isMe ? Icons.edit : Icons.directions_run),
                        label: new Text(
                          isMe
                              ? "Edit Profile"
                              : (isFollowing) ? "UnFollow" : "Follow",
                          style: TextStyle(fontFamily: 'Raleway'),
                        )),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: new Row(
                      children: [
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                new Text(this.followerCount.toString(),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    )),
                                new SizedBox(
                                  height: 10,
                                ),
                                new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 10,
                                      child: new Icon(Icons.person, size: 14),
                                    ),
                                    new SizedBox(width: 5),
                                    new Text(
                                      "Followers",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                                new SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                          flex: 1,
                          fit: FlexFit.tight,
                        ),
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                new Text(this.postsCount.toString(),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    )),
                                new SizedBox(
                                  height: 10,
                                ),
                                new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 10,
                                      child: new Icon(Icons.edit, size: 14),
                                    ),
                                    new SizedBox(width: 5),
                                    new Text(
                                      "Posts",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                                new SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                          flex: 1,
                          fit: FlexFit.tight,
                        ),
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                new Text(this.followingCount.toString(),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    )),
                                new SizedBox(
                                  height: 10,
                                ),
                                new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 10,
                                      child: new Icon(Icons.person, size: 14),
                                    ),
                                    new SizedBox(width: 5),
                                    new Text(
                                      "Following",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                  ],
                                ),
                                new SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                          flex: 1,
                          fit: FlexFit.tight,
                        ),
                      ],
                    ),
                  ),
                  new SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.all(10),
                    height: 180,
                    width: 300,
                    child: ListView(children: [
                      new Text(
                        "About Me",
                        style: TextStyle(
                          fontFamily: 'Roboto Condensed',
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).primaryColor,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      new SizedBox(
                        height: 10,
                      ),
                      new SizedBox(
                        width: 10,
                        height: 3,
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 0, horizontal: 150),
                          color: Colors.amber,
                        ),
                      ),
                      new SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new Text(
                          bio.length == 0 ? "No Content To Dislay!" : bio,
                          textAlign: TextAlign.center,
                        ),
                      )
                    ]),
                  ),
                  Divider(),
                  buildTogglePostOrientation(),
                  buildProfilePosts(),
                  new SizedBox(height: 800),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }
}
