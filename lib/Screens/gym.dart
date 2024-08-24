import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class GymListPage extends StatefulWidget {
  const GymListPage({Key? key}) : super(key: key);

  @override
  State<GymListPage> createState() => _GymListPageState();
}

Future<GetGymContests> fetchGymContests(int start, int count) async {
  final response = await http.get(Uri.https(
    'codeforces.com',
    '/api/contest.list',
    {'gym': 'true'},
  ));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return GetGymContests.fromJson(data);
  } else {
    throw Exception('Failed to load gym contests');
  }
}

class _GymListPageState extends State<GymListPage> {
  List<GymResult> _gymContests = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _start = 0;
  final int _count = 20;

  @override
  void initState() {
    super.initState();
    _loadMoreGymContests();
  }

  Future<void> _loadMoreGymContests() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final gymContestSet = await fetchGymContests(_start, _count);
      setState(() {
        _start += _count;
        _gymContests.addAll(gymContestSet.result);
        _hasMore = gymContestSet.result.length == _count;
      });
    } catch (e) {
      print('Error loading gym contests: $e');
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
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Gym Contests",
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
                  _gymContests.clear();
                  _hasMore = true;
                });
                await _loadMoreGymContests();
              },
              child: ListView.builder(
                itemCount: _gymContests.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _gymContests.length) {
                    if (_isLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      _loadMoreGymContests();
                      return SizedBox.shrink();
                    }
                  }
                  final gymContest = _gymContests[index];
                  return GestureDetector(
                    onTap: () {
                      final url = "https://codeforces.com/gym/${gymContest.id}";
                      _launchURL(url);
                    },
                    child: Card(
                      elevation: 5, // Increased elevation for better shadow effect
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                      ),
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12), // Adjusted margins
                      child: ListTile(
                        title: Text(gymContest.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          'Contest ID: ${gymContest.id}\n'
                              'Phase: ${gymContest.phase}\n'
                              'Date: ${gymContest.startTimeSeconds != null ? formatDate(gymContest.startTimeSeconds!) : "N/A"}\n'
                              'Start Time: ${gymContest.startTimeSeconds != null ? formatTime(gymContest.startTimeSeconds!) : "N/A"}\n'
                              'Duration: ${formatDuration(gymContest.durationSeconds)}\n'
                              'Type: ${gymContest.type}\n'
                              'Kind: ${gymContest.kind}\n'
                              'Season: ${gymContest.season}\n'
                              'Difficulty: ${gymContest.difficulty}\n'
                              'Prepared By: ${gymContest.preparedBy ?? "N/A"}\n'
                              'Location: ${gymContest.city != null ? "${gymContest.city}, " : ""}${gymContest.country ?? "N/A"}',
                          style: TextStyle(fontSize: 15),
                        ),
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

class GetGymContests {
  String status;
  List<GymResult> result;

  GetGymContests({
    required this.status,
    required this.result,
  });

  factory GetGymContests.fromJson(Map<String, dynamic> json) {
    var list = json['result'] as List;
    List<GymResult> resultList = list.map((i) => GymResult.fromJson(i)).toList();

    return GetGymContests(
      status: json['status'],
      result: resultList,
    );
  }
}

class GymResult {
  int id;
  String name;
  String type;
  String phase;
  bool frozen;
  int durationSeconds;
  String? description;
  int? difficulty;
  String? kind;
  String? season;
  String? preparedBy;
  int? startTimeSeconds;
  int? relativeTimeSeconds;
  String? country;
  String? city;
  String? icpcRegion;

  GymResult({
    required this.id,
    required this.name,
    required this.type,
    required this.phase,
    required this.frozen,
    required this.durationSeconds,
    this.description,
    this.difficulty,
    this.kind,
    this.season,
    this.preparedBy,
    this.startTimeSeconds,
    this.relativeTimeSeconds,
    this.country,
    this.city,
    this.icpcRegion,
  });

  factory GymResult.fromJson(Map<String, dynamic> json) {
    return GymResult(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      phase: json['phase'],
      frozen: json['frozen'],
      durationSeconds: json['durationSeconds'],
      description: json['description'],
      difficulty: json['difficulty'],
      kind: json['kind'],
      season: json['season'],
      preparedBy: json['preparedBy'],
      startTimeSeconds: json['startTimeSeconds'],
      relativeTimeSeconds: json['relativeTimeSeconds'],
      country: json['country'],
      city: json['city'],
      icpcRegion: json['icpcRegion'],
    );
  }
}
