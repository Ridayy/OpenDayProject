import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/chat/message_bubble.dart';

class Messages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("/chat")
          .orderBy("createdAt", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView.builder(
            reverse: true,
            itemCount: snapshot.data.docs.length,
            itemBuilder: (ctx, index) {
              print(snapshot.data.docs[index].data()['userId']);
              return MessageBubble(
                snapshot.data.docs[index].data()['text'],
                snapshot.data.docs[index].data()['userId'] ==
                    FirebaseAuth.instance.currentUser.uid,
                snapshot.data.docs[index].data()['username'],
                snapshot.data.docs[index].data()['user_image'],
                key: ValueKey(snapshot.data.docs[index].documentID),
              );
            });
      },
    );
  }
}
