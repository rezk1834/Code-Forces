import 'package:flutter/material.dart';

import '../ContestPage.dart';
import '../UserInfo.dart';
import '../UsersPage.dart';
import '../blogentry.dart';
import '../gym.dart';
import '../problemset.dart';

class TheDrawer extends StatelessWidget {
  const TheDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Center(
              child: Image.asset(
                "assets/icon.png",
                width: 100,
                height: 100,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person, size: 30, color: Theme.of(context).primaryColor),
            title: Text(
              "User Info",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserInfoPage()),
              );
            },
          ),ListTile(
            leading: Icon(Icons.code, size: 30, color: Theme.of(context).primaryColor),
            title: Text(
              "Problem Set",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProblemSet()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.fitness_center, size: 30, color: Theme.of(context).primaryColor),
            title: Text(
              "Gym",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GymListPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.article, size: 30, color: Theme.of(context).primaryColor),
            title: Text(
              "Blog",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BlogEntryPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.event, size: 30, color: Theme.of(context).primaryColor),
            title: Text(
              "Contests",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ContestPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.people, size: 30, color: Theme.of(context).primaryColor),
            title: Text(
              "Users",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
