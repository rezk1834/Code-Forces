import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'rating color.dart';  // Adjust the import path if necessary

class UserInfoPage extends StatefulWidget {


  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final TextEditingController _controller = TextEditingController();
  Future<GetInfo>? _futureInfo;
  Future<Contests>? _futureContests;

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

  void _fetchUserInfo() {
    setState(() {
      _futureInfo = getInfo(_controller.text);
      _futureContests = getContests(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Info", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white)),
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
                  return Card(
                    elevation: 5, // Increased elevation for better shadow effect
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Rounded corners
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12), // Adjusted margins
                    child: Padding(
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
                                ),),
                              Text(
                                result.handle,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: getColorForRating(result.rating),
                                ),
                              ),
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Rating:',
                                        style: TextStyle(fontSize: 16,),
                                      ),
                                      Text(
                                        ' ${result.rating}  ',
                                        style: TextStyle(fontSize: 16,  fontWeight: FontWeight.bold,color: getColorForRating(result.rating),),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '(Max Rating:',
                                        style: TextStyle(fontSize: 12,),
                                      ),
                                      Text(
                                        ' ${result.maxRating}',
                                        style: TextStyle(fontSize: 12,color: getColorForRating(result.rating),),
                                      ), Text(
                                        ')',
                                        style: TextStyle(fontSize: 12,),
                                      ),
                                    ],
                                  ),

                                ],
                              ),
                              Text(
                                'Friends of: ${result.friendOfCount} users',
                                style: TextStyle(fontSize: 16),
                              ),


                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
            Divider(height: 32),
            Expanded(
              child: FutureBuilder<Contests>(
                future: _futureContests,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.result.isEmpty) {
                    return Center(child: Text('No contest data available'));
                  } else {
                    final contests = snapshot.data!;
                    contests.result.sort((a, b) => b.contestId.compareTo(a.contestId));

                    return ListView.builder(
                      itemCount: contests.result.length,
                      itemBuilder: (context, index) {
                        final result = contests.result[index];
                        return Card(
                          elevation: 2,
                          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(8),
                            title: Text(
                              result.contestName,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Rank: ${result.rank}\n',
                                    style: TextStyle(fontSize: 14, color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: 'Old Rating: ${result.oldRating}\n',
                                    style: TextStyle(fontSize: 14, color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: 'New Rating: ${result.newRating}\n',
                                    style: TextStyle(fontSize: 14, color: Colors.black),
                                  ),
                                  TextSpan(
                                    text: 'Rating Change: ',
                                    style: TextStyle(fontSize: 14, color: Colors.black),
                                  ),TextSpan(
                                    text: '${result.newRating - result.oldRating}',
                                    style: TextStyle(fontSize: 14, color: result.newRating - result.oldRating>0? Colors.green:Colors.red),
                                  ),
                                ],
                              ),
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class GetInfo {
  String status;
  List<Result> result;

  GetInfo({
    required this.status,
    required this.result,
  });

  factory GetInfo.fromJson(Map<String, dynamic> json) {
    var list = json['result'] as List;
    List<Result> resultList = list.map((i) => Result.fromJson(i)).toList();

    return GetInfo(
      status: json['status'],
      result: resultList,
    );
  }
}

class Result {
  String handle;
  String rank;
  int rating;
  int friendOfCount;
  String titlePhoto;
  int maxRating;
  String avatar;
  String maxRank;
  int lastOnlineTimeSeconds;
  int registrationTimeSeconds;

  Result({
    required this.rating,
    required this.friendOfCount,
    required this.titlePhoto,
    required this.rank,
    required this.handle,
    required this.maxRating,
    required this.avatar,
    required this.maxRank,
    required this.lastOnlineTimeSeconds,
    required this.registrationTimeSeconds,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
        handle: json['handle'],
        rank: json['rank'],
        rating: json['rating'],
        friendOfCount: json['friendOfCount'],
        titlePhoto: json['titlePhoto'],
        maxRating: json['maxRating'],
        avatar: json['avatar'],
        maxRank: json['maxRank'],
        lastOnlineTimeSeconds: json['lastOnlineTimeSeconds'],
        registrationTimeSeconds: json['registrationTimeSeconds']
    );
  }
}

class Contests {
  String status;
  List<ResultContest> result;

  Contests({
    required this.status,
    required this.result,
  });

  factory Contests.fromJson(Map<String, dynamic> json) {
    var list = json['result'] as List;
    List<ResultContest> resultList = list.map((i) => ResultContest.fromJson(i)).toList();

    return Contests(
      status: json['status'],
      result: resultList,
    );
  }
}

class ResultContest {
  int contestId;
  String contestName;
  String handle;
  int rank;
  int oldRating;
  int newRating;

  ResultContest({
    required this.contestId,
    required this.contestName,
    required this.handle,
    required this.rank,
    required this.oldRating,
    required this.newRating,
  });

  factory ResultContest.fromJson(Map<String, dynamic> json) {
    return ResultContest(
      contestId: json['contestId'],
      contestName: json['contestName'],
      handle: json['handle'],
      rank: json['rank'],
      oldRating: json['oldRating'],
      newRating: json['newRating'],
    );
  }
}
