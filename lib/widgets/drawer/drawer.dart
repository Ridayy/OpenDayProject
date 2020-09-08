import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:job_portal/screens/profile_screen.dart';

class MainDrawer extends StatelessWidget {
  final username;
  final userImage;
  MainDrawer(this.username, this.userImage);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Theme.of(context).accentColor.withOpacity(0.5),
                Theme.of(context).primaryColor.withOpacity(0.7),
              ]),
            ),
            height: 200,
            width: double.infinity,
            padding: EdgeInsets.all(50),
            // color: Theme.of(context).accentColor,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50.0),
                child: FadeInImage(
                  width: 100,
                  height: 100,
                  placeholder:
                      AssetImage('assets/images/profile_image_placeholder.png'),
                  image: NetworkImage(
                    userImage,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            leading: Icon(
              Icons.person,
              size: 26,
            ),
            title: new Text(
              'My Profile',
              style: TextStyle(
                fontFamily: 'RobotoCondensed',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.of(context).pushNamed(ProfileScreen.routeName,
                  arguments: FirebaseAuth.instance.currentUser.uid);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              size: 26,
            ),
            title: new Text(
              'Filters',
              style: TextStyle(
                fontFamily: 'RobotoCondensed',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.of(context).pushReplacementNamed("/");
            },
          ),
          ListTile(
            leading: Icon(
              Icons.add_to_home_screen,
              size: 26,
            ),
            title: new Text(
              'My Activity',
              style: TextStyle(
                fontFamily: 'RobotoCondensed',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.of(context).pushReplacementNamed("/");
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.exit_to_app,
              size: 26,
            ),
            title: new Text(
              'Logout',
              style: TextStyle(
                fontFamily: 'RobotoCondensed',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
          )
        ],
      ),
    );
  }
}
