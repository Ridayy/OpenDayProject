import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:job_portal/screens/profile_screen.dart';
import 'package:basic_utils/basic_utils.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Future<QuerySnapshot> searchResultsFuture;
  TextEditingController _searchController = TextEditingController();

  void handleSearch(String searchText) {
    Future<QuerySnapshot> users = FirebaseFirestore.instance
        .collection("/users")
        .where("username", isGreaterThanOrEqualTo: searchText.toLowerCase())
        .get();
    setState(() {
      searchResultsFuture = users;
    });
  }

  Widget buildSearchField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
      child: TextFormField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: "Search For User",
          labelStyle: Theme.of(context).textTheme.bodyText2,
          prefixIcon: Icon(
            Icons.account_box,
            size: 28,
            color: Theme.of(context).accentColor,
          ),
          suffixIcon: IconButton(
              icon: Icon(
                Icons.clear,
                color: Theme.of(context).accentColor,
              ),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  searchResultsFuture = null;
                });
              }),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  Widget buildNoContent() {
    final orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          children: [
            buildSearchField(),
            SvgPicture.asset(
              "assets/images/search.svg",
              height: (orientation == Orientation.portrait) ? 300 : 90,
            ),
            Text(
              "Find Users",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'RobotoCondensed',
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildSearchResults() {
    return FutureBuilder(
        future: searchResultsFuture,
        builder: (ctx, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          List<UserResult> searchResults = [];
          snapshot.data.documents.forEach((doc) {
            print(doc.documentID);
            searchResults.add(UserResult(doc.data()["username"],
                doc.data()["image_url"], doc.documentID));
          });

          return Column(
            children: [
              buildSearchField(),
              (searchResults.length == 0)
                  ? Center(child: new Text("No Results Found!"))
                  : Expanded(
                      child: ListView.builder(
                          itemCount: searchResults.length,
                          itemBuilder: (ctx, index) {
                            return searchResults[index];
                          }),
                    ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (searchResultsFuture == null)
          ? buildNoContent()
          : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final String username;
  final String userImage;
  final String uid;
  UserResult(this.username, this.userImage, this.uid);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            ProfileScreen.routeName,
            arguments: uid,
          );
        },
        child: ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(this.userImage),
            ),
            title: new Text(StringUtils.capitalize(this.username),
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'RobotoCondensed'))),
      ),
      Divider(),
    ]);
  }
}
