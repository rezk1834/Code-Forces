import 'dart:convert';
import 'package:codeforces/Screens/ContestStanding.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// Define the ProblemSet widget
class ContestPage extends StatefulWidget {
   ContestPage({Key? key}) : super(key: key);

  @override
  State<ContestPage> createState() => _ContestPageState();

}

Future<GetContest> fetchContests(int start, int count) async {
  final response = await http.get(Uri.https(
    'codeforces.com',
    '/api/contest.list',
  ));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return GetContest.fromJson(data);
  } else {
    throw Exception('Failed to load contests');
  }
}

// Define the state for ProblemSet
class _ContestPageState extends State<ContestPage> {
  List<Result> _contests = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _start = 0;
  final int _count = 20;
  TextStyle labelStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 15,color: Colors.black);
  TextStyle valueStyle = TextStyle(fontSize: 15,color: Colors.black);

  @override
  void initState() {
    super.initState();
    _loadMoreContests();
  }

  Future<void> _loadMoreContests() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final contestSet = await fetchContests(_start, _count);
      setState(() {
        _start += _count;
        _contests.addAll(contestSet.result);
        _hasMore = contestSet.result.length == _count;
      });
    } catch (e) {
      print('Error loading contests: $e');
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

  String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '$hours hours, $minutes minutes';
  }

  String formatTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  String formatDate(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Contests",
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
                  _contests.clear();
                  _hasMore = true;
                });
                await _loadMoreContests();
              },
              child: ListView.builder(
                itemCount: _contests.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _contests.length) {
                    if (_isLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      _loadMoreContests();
                      return SizedBox.shrink();
                    }
                  }
                  final contest = _contests[index];
                  return GestureDetector(
                    onTap: () {
                      final url = "https://codeforces.com/contest/${contest.id}";
                      _launchURL(url);
                    },
              child: Card(
                elevation: 5, // Increased elevation for better shadow effect
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12), // Adjusted margins
                child: ListTile(
                  contentPadding: EdgeInsets.all(16), // Increased padding for better spacing
                  tileColor: Colors.grey[200], // Added background color for ListTile
                  trailing: contest.phase != 'BEFORE'
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ContestStanding(
                                id: contest.id,
                                contestName: contest.name,
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.rate_review,
                          color: Theme.of(context).primaryColor, // Icon color to match theme
                        ),
                      ),
                    ],
                  )
                      : SizedBox.shrink(), // Changed Text("") to SizedBox.shrink() for better spacing
                  title: Text(
                    contest.name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87, // Consistent text color
                    ),
                  ),
                  subtitle: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Contest ID: ',
                          style: labelStyle,
                        ),
                        TextSpan(
                          text: '${contest.id}\n',
                          style: valueStyle,
                        ),
                        TextSpan(
                          text: 'Phase: ',
                          style: labelStyle,
                        ),
                        TextSpan(
                          text: '${contest.phase == 'BEFORE' ? 'Upcoming' : contest.phase}\n',
                          style: valueStyle,
                        ),
                        TextSpan(
                          text: 'Date: ',
                          style: labelStyle,
                        ),
                        TextSpan(
                          text: '${formatDate(contest.startTimeSeconds)}\n',
                          style: valueStyle,
                        ),
                        TextSpan(
                          text: 'Start Time: ',
                          style: labelStyle,
                        ),
                        TextSpan(
                          text: '${formatTime(contest.startTimeSeconds)}\n',
                          style: valueStyle,
                        ),
                        TextSpan(
                          text: 'Duration: ',
                          style: labelStyle,
                        ),
                        TextSpan(
                          text: '${formatDuration(contest.durationSeconds)}',
                          style: valueStyle,
                        ),
                      ],
                    ),
                  ),
                ),
              )
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

class GetContest {
  String status;
  List<Result> result;

  GetContest({
    required this.status,
    required this.result,
  });

  factory GetContest.fromJson(Map<String, dynamic> json) {
    var list = json['result'] as List;
    List<Result> resultList = list.map((i) => Result.fromJson(i)).toList();

    return GetContest(
      status: json['status'],
      result: resultList,
    );
  }
}

class Result {
  int id;
  String name;
  String phase;
  int durationSeconds;
  int startTimeSeconds;
  int relativeTimeSeconds;

  Result({
    required this.id,
    required this.name,
    required this.phase,
    required this.durationSeconds,
    required this.startTimeSeconds,
    required this.relativeTimeSeconds,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      id: json['id'],
      name: json['name'],
      phase: json['phase'],
      durationSeconds: json['durationSeconds'],
      startTimeSeconds: json['startTimeSeconds'],
      relativeTimeSeconds: json['relativeTimeSeconds'],
    );
  }
}
