import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewMessage extends StatefulWidget {
  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  var enteredMessage = "";
  final messageController = TextEditingController();

  void sendMessage() {
    FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser.uid;
    FirebaseFirestore.instance
        .collection("/users")
        .doc(user)
        .get()
        .then((userData) {
      FirebaseFirestore.instance.collection("/chat").add({
        'text': enteredMessage,
        'createdAt': Timestamp.now(),
        'userId': user,
        'username': userData.data()['username'],
        'user_image': userData.data()['image_url'],
      });
      messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(10),
      child: new Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                labelText: "Send a message",
              ),
              onChanged: (value) {
                setState(() {
                  enteredMessage = value;
                });
              },
            ),
          ),
          IconButton(
            color: Theme.of(context).primaryColor,
            icon: Icon(Icons.send),
            onPressed: enteredMessage.trim().isEmpty ? null : sendMessage,
          ),
        ],
      ),
    );
  }
}
