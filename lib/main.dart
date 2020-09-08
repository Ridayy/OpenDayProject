import 'package:flutter/material.dart';
import 'package:job_portal/screens/edit_profile_screen.dart';
import 'package:job_portal/screens/news_feed_screen.dart';
import 'package:job_portal/screens/profile_screen.dart';
import 'package:job_portal/widgets/post/post_candidiate.dart';
import 'screens/auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Storm',
      theme: ThemeData(
        // canvasColor: Colors.pink,
        primarySwatch: Colors.pink,
        backgroundColor: Colors.pink,
        accentColor: Colors.deepPurple,
        accentColorBrightness: Brightness.dark,
        textTheme: ThemeData.light().textTheme.copyWith(
              body1: TextStyle(
                color: Color.fromRGBO(20, 51, 51, 1),
              ),
              body2: TextStyle(
                fontFamily: 'Raleway',
                color: Colors.pink,
                fontWeight: FontWeight.bold,
              ),
              title: TextStyle(
                fontSize: 22,
                fontFamily: 'RobotoCondensed',
                fontWeight: FontWeight.bold,
              ),
            ),
        fontFamily: 'Raleway',
        buttonTheme: ButtonTheme.of(context).copyWith(
            buttonColor: Colors.pink,
            textTheme: ButtonTextTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            )),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            return NewsFeedScreen();
          }
          return AuthScreen();
        },
      ),
      routes: {
        ProfileScreen.routeName: (ctx) {
          return ProfileScreen();
        },
        EditProfileScreen.routeName: (ctx) {
          return EditProfileScreen();
        }
        // PostCandidiate.routeName: (ctx) {
        //   return PostCandidiate();
        // }
      },
    );
  }
}
