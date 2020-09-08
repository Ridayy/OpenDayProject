import 'package:flutter/material.dart';
import 'package:job_portal/widgets/drawer/drawer.dart';

class EmployerView extends StatelessWidget {
  String username;
  String userImage;
  EmployerView(this.username, this.userImage);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("Storm"),
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
      drawer: MainDrawer(username, userImage),
      body: Center(child: new Text("EMPLOYER")),
    );
  }
}
