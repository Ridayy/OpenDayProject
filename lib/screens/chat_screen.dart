import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/chat/new_message.dart';
import '../widgets/chat/messages.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    final fbm = FirebaseMessaging();
    fbm.configure(onMessage: (msg) {
      print(msg);
      return;
    }, onLaunch: (msg) {
      print("LAUNCHED");
      print(msg);
      return;
    }, onResume: (msg) {
      print("RESUMED!");
      print(msg);
      return;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: [
            // Expanded(
            // child: Messages(),
            // ),
            // NewMessage(),
          ],
        ),
      ),
    );
  }
}
