import 'package:codeforces/LoginPage.dart';
import 'package:flutter/material.dart';

import '../Screens/ContestPage.dart';
import '../Screens/UserLookup.dart';
import '../Screens/AllUsersPage.dart';
import '../Screens/blogentry.dart';
import '../Screens/gym.dart';
import '../Screens/problemset.dart';

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
              "User Lookup",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserInfoPage(handle: '', )),
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
          ListTile(
            leading: Icon(Icons.exit_to_app, size: 30, color: Theme.of(context).primaryColor),
            title: Text(
              "Sign Out",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
