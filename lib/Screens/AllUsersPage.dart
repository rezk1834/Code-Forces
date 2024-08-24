import 'dart:convert';
import 'package:codeforces/components/rating%20color.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// Define the ProblemSet widget
class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

Future<GetUserList> fetchUsers(int start, int count) async {
  final response = await http.get(Uri.https(
    'codeforces.com',
    '/api/user.ratedList',
  ));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return GetUserList.fromJson(data);
  } else {
    throw Exception('Failed to load users');
  }
}

// Define the state for UserPage
class _UserPageState extends State<UserPage> {
  List<User> _users = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _start = 0;
  final int _count = 20;
  TextStyle labelStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 15,color: Colors.black);
  TextStyle valueStyle = TextStyle(fontSize: 15,color: Colors.black);

  @override
  void initState() {
    super.initState();
    _loadMoreUsers();
  }

  Future<void> _loadMoreUsers() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userList = await fetchUsers(_start, _count);
      setState(() {
        _start += _count;
        _users.addAll(userList.result);
        _hasMore = userList.result.length == _count;
      });
    } catch (e) {
      print('Error loading users: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load users: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  String formatDate(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Users",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _start = 0;
                  _users.clear();
                  _hasMore = true;
                });
                await _loadMoreUsers();
              },
              child: ListView.builder(
                itemCount: _users.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _users.length) {
                    if (_isLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      _loadMoreUsers();
                      return SizedBox.shrink();
                    }
                  }
                  final user = _users[index];
                  return GestureDetector(
                    onTap: () {
                      final url = "https://codeforces.com/profile/${user.handle}";
                      _launchURL(url);
                    },
                    child: Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(user.avatar),
                        ),
                        title: Text('${user.firstName} ${user.lastName}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        subtitle: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Handle: ',
                                style: labelStyle,
                              ),
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${user.handle[0]}', // First character in black
                                    style: user.rating>=2900?labelStyle:valueStyle.copyWith(color: getColorForRating(user.rating)),
                                  ),
                                  TextSpan(
                                    text: '${user.handle.substring(1)}\n', // Rest of the text with normal style
                                    style: valueStyle.copyWith(color: getColorForRating(user.rating)),
                                  ),
                                ],
                              ),
                              TextSpan(
                                text: 'Rank: ',
                                style: labelStyle,
                              ),
                              TextSpan(
                                text: '${user.rank}\n',
                                style: valueStyle.copyWith(color: getColorForRating(user.rating)),
                              ),
                              TextSpan(
                                text: 'Max Rank: ',
                                style: labelStyle,
                              ),
                              TextSpan(
                                text: '${user.maxRank}\n',
                                style: valueStyle.copyWith(color: getColorForRating(user.maxRating)),
                              ),
                              TextSpan(
                                text: 'Country: ',
                                style: labelStyle,
                              ),
                              TextSpan(
                                text: '${user.country}\n',
                                style: valueStyle,
                              ),
                              TextSpan(
                                text: 'Rating: ',
                                style: labelStyle,
                              ),
                              TextSpan(
                                text: '${user.rating}\n',
                                style: valueStyle.copyWith(color: getColorForRating(user.rating)),
                              ),
                              TextSpan(
                                text: 'Max Rating: ',
                                style: labelStyle,
                              ),
                              TextSpan(
                                text: '${user.maxRating}\n',
                                style: valueStyle.copyWith(color: getColorForRating(user.maxRating)),
                              ),
                              TextSpan(
                                text: 'Friends of: ',
                                style: labelStyle,
                              ),
                              TextSpan(
                                text: '${user.friendOfCount}\n',
                                style: valueStyle,
                              ),
                              TextSpan(
                                text: 'Contributions: ',
                                style: labelStyle,
                              ),
                              TextSpan(
                                text: '${user.contribution}\n',
                                style: valueStyle,
                              ),
                              TextSpan(
                                text: 'Last Online: ',
                                style: labelStyle,
                              ),
                              TextSpan(
                                text: '${formatDate(user.lastOnlineTimeSeconds)}',
                                style: valueStyle,
                              ),
                            ],
                          ),
                        ),
                        isThreeLine: true,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GetUserList {
  String status;
  List<User> result;

  GetUserList({
    required this.status,
    required this.result,
  });

  factory GetUserList.fromJson(Map<String, dynamic> json) {
    var list = json['result'] as List;
    List<User> userList = list.map((i) => User.fromJson(i)).toList();

    return GetUserList(
      status: json['status'],
      result: userList,
    );
  }
}

class User {
  String handle;
  String? firstName;
  String? lastName;
  String? country;
  String rank;
  String maxRank;
  int rating;
  int maxRating;
  int friendOfCount;
  String avatar;
  int lastOnlineTimeSeconds;
  int registrationTimeSeconds;
  int contribution;

  User({
    required this.handle,
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.rank,
    required this.maxRank,
    required this.rating,
    required this.maxRating,
    required this.friendOfCount,
    required this.avatar,
    required this.lastOnlineTimeSeconds,
    required this.registrationTimeSeconds,
    required this.contribution,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      handle: json['handle'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      country: json['country'] ?? '',
      rank: json['rank'],
      maxRank: json['maxRank'],
      rating: json['rating'],
      maxRating: json['maxRating'],
      friendOfCount: json['friendOfCount'],
      avatar: json['avatar'],
      lastOnlineTimeSeconds: json['lastOnlineTimeSeconds'],
      registrationTimeSeconds: json['registrationTimeSeconds'],
      contribution: json['contribution'] ?? 0,
    );
  }
}