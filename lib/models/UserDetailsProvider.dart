import 'package:flutter/cupertino.dart';

class UserDetailsProvider with ChangeNotifier {
  var username;
  var imageUrl;

  void setDetails(username, imageUrl){
    this.username = username;
    this.imageUrl = imageUrl;
  }
}
