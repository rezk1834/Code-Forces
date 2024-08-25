import 'package:flutter/material.dart';
import 'Service/api_service.dart';
import 'UserContests.dart';
import 'UserPage.dart';
import 'UserStatus.dart';
import 'components/Drawer.dart';

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
      UserPage(futureInfo: _futureInfo,
          handle: widget.handle,
          futureContests: _futureContests,
          futureStatus: _futureStatus),
      ContestsPage(futureContests: _futureContests, Mainuser: true,),
      StatusPage(
        futureStatus: _futureStatus, handle: widget.handle, Mainuser: true,),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.handle}'s Profile",
          style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.white
          ),
        ),
        backgroundColor: Theme
            .of(context)
            .primaryColor,
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
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        selectedFontSize: 16.0,
        unselectedFontSize: 14.0,
        backgroundColor: Theme
            .of(context)
            .primaryColor,
      ),
    );
  }
}