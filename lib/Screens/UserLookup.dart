import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Service/api_service.dart';
import '../UserContests.dart';
import '../UserStatus.dart';
import '../components/rating color.dart';

class UserInfoPage extends StatefulWidget {
  final String? handle;
  final Future<GetInfo>? futureInfo;

  const UserInfoPage({super.key,  this.handle, this.futureInfo});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final TextEditingController _controller = TextEditingController();
  TextStyle labelStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 20,color: Colors.black);
  TextStyle valueStyle = TextStyle(fontSize: 20,color: Colors.black);
  Future<GetInfo>? _futureInfo;
  Future<Contests>? _futureContests;
  Future<Status>? _futureStatus;

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
    final response = await http.get(Uri.https('codeforces.com', '/api/user.status', {
      'handle': handle,
      'from': '1',
      'count': '10',
    }));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Status.fromJson(data);
    } else {
      throw Exception('Failed to load Status');
    }
  }

  void _fetchUserInfo() {
    setState(() {
      _futureInfo = getInfo(_controller.text);
      _futureContests = getContests(_controller.text);
      _futureStatus = getStatus(_controller.text) ;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Lookup", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter handle',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _fetchUserInfo,
                ),
              ),
              onSubmitted: (_) => _fetchUserInfo(),
            ),
            SizedBox(height: 16),
            FutureBuilder<GetInfo>(
              future: _futureInfo,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('No user info available'));
                } else if (!snapshot.hasData || snapshot.data!.result.isEmpty) {
                  return Center(child: Text('No user info available'));
                } else {
                  final info = snapshot.data!;
                  final result = info.result[0];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 70,
                          height: 90,
                          margin: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                            image: DecorationImage(
                              image: NetworkImage(result.avatar),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${result.rank}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: getColorForRating(result.rating),
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${result.handle[0]}',
                                    style: result.rating <= 2900
                                        ? labelStyle.copyWith(color: getColorForRating(result.rating), fontWeight: FontWeight.bold)
                                        : TextStyle(fontSize: 20, color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: '${result.handle.substring(1)}', // Rest of the text with normal style
                                    style: TextStyle(fontSize: 20, color: getColorForRating(result.rating), fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            RichText(
                                text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text:'Rating: ',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                      ),
                                      TextSpan(
                                        text:result.rating.toString(),
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: getColorForRating(result.rating)),
                                      )
                                    ]
                                )
                            ),
                            RichText(
                                text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text:'Max Rating: ',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                      ),
                                      TextSpan(
                                        text:result.maxRating.toString(),
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: getColorForRating(result.maxRating)),
                                      )
                                    ]
                                )
                            ),

                            Text(
                              'Friends of: ${result.friendOfCount} users',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ContestsPage( futureContests: _futureContests, Mainuser: false,)),
                    );
                  },
                  child: Text('Contests'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StatusPage( futureStatus: _futureStatus,handle: _controller.text, Mainuser: false,),
                    ));
                  },
                  child: Text('Status'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

