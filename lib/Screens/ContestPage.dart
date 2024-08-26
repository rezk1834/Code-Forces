import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../Service/api_service.dart';
import 'ContestStanding.dart';

// Define the ContestPage widget
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

// Define the state for ContestPage
class _ContestPageState extends State<ContestPage> {
  List<ContestResult> _upcomingContests = [];
  List<ContestResult> _finishedContests = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _start = 0;
  final int _count = 20;

  TextStyle labelStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black);
  TextStyle valueStyle = TextStyle(fontSize: 15, color: Colors.black);

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
        for (var contest in contestSet.result) {
          if (contest.phase == 'BEFORE') {
            _upcomingContests.add(contest);
          } else {
            _finishedContests.add(contest);
          }
        }
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

  void _addToCalendar(ContestResult contest) async {
    final Uri calendarUrl = Uri.parse(
        'https://www.google.com/calendar/render?action=TEMPLATE&text=${Uri.encodeComponent(contest.name)}'
            '&dates=${formatGoogleCalendarDate(contest.startTimeSeconds, contest.durationSeconds)}'
            '&details=Codeforces%20Contest%20ID:%20${contest.id}&sf=true&output=xml');
    if (!await launchUrl(calendarUrl, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $calendarUrl';
    }
  }

  String formatGoogleCalendarDate(int startTimeSeconds, int durationSeconds) {
    final start = DateTime.fromMillisecondsSinceEpoch(startTimeSeconds * 1000).toUtc();
    final end = start.add(Duration(seconds: durationSeconds)).toUtc();
    final startDate = '${start.year}${start.month.toString().padLeft(2, '0')}${start.day.toString().padLeft(2, '0')}T'
        '${start.hour.toString().padLeft(2, '0')}${start.minute.toString().padLeft(2, '0')}00Z';
    final endDate = '${end.year}${end.month.toString().padLeft(2, '0')}${end.day.toString().padLeft(2, '0')}T'
        '${end.hour.toString().padLeft(2, '0')}${end.minute.toString().padLeft(2, '0')}00Z';
    return '$startDate/$endDate';
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
                  _upcomingContests.clear();
                  _finishedContests.clear();
                  _hasMore = true;
                });
                await _loadMoreContests();
              },
              child: ListView.builder(
                itemCount: _upcomingContests.length + _finishedContests.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < _upcomingContests.length) {
                    return _buildContestCard(_upcomingContests[index], true);
                  } else if (index < _upcomingContests.length + _finishedContests.length) {
                    return _buildContestCard(_finishedContests[index - _upcomingContests.length], false);
                  } else {
                    if (_isLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      _loadMoreContests();
                      return SizedBox.shrink();
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContestCard(ContestResult contest, bool isUpcoming) {
    return GestureDetector(
      onTap: () {
        final url = "https://codeforces.com/contest/${contest.id}";
        _launchURL(url);
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Stack(
          children: [
            ListTile(
              contentPadding: EdgeInsets.all(16),
              tileColor: Colors.grey[200],
              trailing: contest.phase != 'BEFORE'
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isUpcoming)
                    IconButton(
                      onPressed: () => _addToCalendar(contest),
                      icon: Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                ],
              )
                  : SizedBox.shrink(),
              title: Text(
                contest.name,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
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
                      text: '${formatDuration(contest.durationSeconds)}\n',
                      style: valueStyle,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                decoration: BoxDecoration(
                  color: isUpcoming ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isUpcoming ? 'Upcoming' : 'Finished',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (isUpcoming)
              Positioned(
                bottom: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => _addToCalendar(contest),
                  icon: Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            if (!isUpcoming)
              Positioned(
                bottom: 8,
                right: 8,
                child: IconButton(
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
                    Icons.stacked_bar_chart_sharp,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}