import 'package:flutter/material.dart';
import 'package:job_portal/screens/chat_screen.dart';
import 'package:job_portal/screens/notification_screen.dart';
import 'package:job_portal/screens/posts_screen.dart';
import 'package:job_portal/screens/search_screen.dart';
import 'package:job_portal/widgets/drawer/drawer.dart';
import 'package:job_portal/widgets/post/post_candidiate.dart';
import 'package:job_portal/widgets/post/post_options.dart';

class CandidiateView extends StatefulWidget {
  String username;
  String userImage;
  CandidiateView(this.username, this.userImage);

  @override
  _CandidiateViewState createState() => _CandidiateViewState();
}

class _CandidiateViewState extends State<CandidiateView> {
  List<Widget> _pages = [];
  List<String> _titles = [];
  @override
  void initState() {
    super.initState();
    _pages = [
      PostsScreen(),
      ChatScreen(),
      SearchScreen(),
      NotificationScreen()
    ];
    _titles = [
      "Home",
      "Messages",
      "Search",
      "Notifications",
    ];
  }

  int _selectPageIndex = 0;
  int _previousPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: new Text((_selectPageIndex == 4)
              ? _titles[_previousPageIndex]
              : _titles[_selectPageIndex]),
          actions: [
            DropdownButton(
              onChanged: (item) {
                // if (item == "logout") {
                //   FirebaseAuth.instance.signOut();
                // }
              },
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).primaryIconTheme.color,
              ),
              items: [
                DropdownMenuItem(
                  value: 'Any Value',
                  child: Container(
                    child: Row(
                      children: [
                        Icon(Icons.ac_unit),
                        SizedBox(
                          width: 10,
                        ),
                        Text("Any option")
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        drawer: MainDrawer(widget.username, widget.userImage),
        body: (_selectPageIndex == 4)
            ? _pages[_previousPageIndex]
            : _pages[_selectPageIndex],
        bottomNavigationBar: new Theme(
          data: Theme.of(context).copyWith(
              // sets the background color of the `BottomNavigationBar`
              canvasColor: Colors.pink,
              // sets the active color of the `BottomNavigationBar` if `Brightness` is light

              textTheme: Theme.of(context)
                  .textTheme
                  .copyWith(caption: new TextStyle(color: Colors.yellow))),
          child: BottomNavigationBar(
            onTap: (index) {
              setState(() {
                _previousPageIndex = _selectPageIndex;
                if (index == 4) {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        // return PostCandidiate();
                         return PostOptions();
                      });
                  return;
                }
                _selectPageIndex = index;
              });
            },
            backgroundColor: Colors.pink,
            unselectedItemColor: Colors.white,
            selectedItemColor: Colors.amber.withOpacity(0.8),
            currentIndex: _selectPageIndex,
            selectedFontSize: 15,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                title: new Text("Home"),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.message),
                title: new Text("Messages"),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                title: new Text("Search"),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notification_important),
                title: new Text("Notifications"),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.camera),
                title: new Text("Post Now"),
              ),
            ],
          ),
        ));
  }
}
