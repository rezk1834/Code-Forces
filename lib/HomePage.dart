import 'dart:convert';
import 'package:flutter/material.dart';
import 'Service/api_service.dart';
import 'UserContests.dart';

import 'UserPage.dart';
import 'UserStatus.dart';
import 'components/Drawer.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final String handle;

  const HomePage({super.key, required this.handle});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late Future<GetInfo> _futureInfo;
  late Future<Contests> _futureContests;
  late Future<Status> _futureStatus;

  @override
  void initState() {
    super.initState();
    _futureInfo = getInfo(widget.handle);
    _futureContests = getContests(widget.handle);
    _futureStatus = getStatus(widget.handle);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      UserPage(futureInfo: _futureInfo, handle: widget.handle,futureContests: _futureContests,futureStatus: _futureStatus),
      ContestsPage(futureContests: _futureContests, Mainuser: true,),
      StatusPage(futureStatus: _futureStatus,handle: widget.handle, Mainuser: true,),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.handle}'s Profile",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: TheDrawer(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.person, size: 30.0),
            label: 'User Info',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.timeline, size: 30.0,),
            label: 'Contests',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.list, size: 30.0,),
            label: 'Status',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple[900],
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        selectedFontSize: 16.0,
        unselectedFontSize: 14.0,
        backgroundColor: Colors.deepPurple[200],
      ),
    );
  }

  Future<GetInfo> getInfo(String handle) async {
    final response = await http.get(Uri.https('codeforces.com', '/api/user.info', {'handles': handle}));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return GetInfo.fromJson(data);
    } else {
      throw Exception('Failed to load user info');
    }
  }

  Future<Contests> getContests(String handle) async {
    final response = await http.get(Uri.https('codeforces.com', '/api/user.rating', {'handle': handle}));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Contests.fromJson(data);
    } else {
      throw Exception('Failed to load contests');
    }
  }

  Future<Status> getStatus(String handle) async {
    final response = await http.get(Uri.https('codeforces.com', '/api/user.status', {'handle': handle, 'from': '1', 'count': '10'}));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Status.fromJson(data);
    } else {
      throw Exception('Failed to load status');
    }
  }
}
