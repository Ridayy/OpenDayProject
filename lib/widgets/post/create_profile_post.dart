import 'package:flutter/material.dart';

class CreateProfilePost extends StatelessWidget {
  String postUrl;
  CreateProfilePost(this.postUrl);

  @override
  Widget build(BuildContext context) {
    return GridTile(
      child: Image.network(postUrl, fit: BoxFit.cover),
    );
  }
}
