import 'package:timeago/timeago.dart' as timeago;

class Post {
  final String description;
  final String imageUrl;
  final String time;
  final String postedBy;
  final String uid;
  String location;
  String userImage;

  Post(this.description, this.imageUrl, this.time, this.postedBy, this.uid, {this.location, this.userImage});

  convertToAgo(String time) {
    final fifteenAgo = DateTime.now()
        .subtract(DateTime.now().difference(DateTime.parse(this.time)));
    return timeago.format(fifteenAgo);
  }
}
