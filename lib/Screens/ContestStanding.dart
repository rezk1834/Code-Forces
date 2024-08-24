import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:codeforces/components/rating%20color.dart';

class ContestStanding extends StatefulWidget {
  final int id;
  final String contestName;

  ContestStanding({super.key, required this.id, required this.contestName});

  @override
  State<ContestStanding> createState() => _ContestStandingState();
}

Future<GetContestStanding> fetchContestsStanding(int start, int count, int id) async {
  final response = await http.get(Uri.https(
      'codeforces.com',
      '/api/contest.ratingChanges',
      {'contestId': id.toString()}
  ));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return GetContestStanding.fromJson(data);
  } else {
    throw Exception('Failed to load contests');
  }
}

class _ContestStandingState extends State<ContestStanding> {
  List<Result> _ranks = [];
  List<Result> _filteredRanks = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _start = 0;
  final int _count = 20;
  TextEditingController _searchController = TextEditingController();
  TextStyle labelStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black);
  TextStyle valueStyle = TextStyle(fontSize: 15, color: Colors.black);

  @override
  void initState() {
    super.initState();
    _loadMoreRanks();
    _searchController.addListener(_filterRanks);
  }

  Future<void> _loadMoreRanks() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final contestSet = await fetchContestsStanding(_start, _count, widget.id);
      setState(() {
        _start += _count;
        _ranks.addAll(contestSet.result);
        _filteredRanks = _ranks; // Initialize filtered ranks
        _hasMore = contestSet.result.length == _count;
      });
    } catch (e) {
      print('Error loading Standing: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterRanks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredRanks = _ranks.where((rank) {
        return rank.handle.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.contestName} Standing",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by handle...',
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: Icon(Icons.search, color: Colors.deepPurple),
              ),
            ),

          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _start = 0;
                  _ranks.clear();
                  _filteredRanks.clear();
                  _hasMore = true;
                });
                await _loadMoreRanks();
              },
              child: ListView.builder(
                itemCount: _filteredRanks.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _filteredRanks.length) {
                    if (_isLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      _loadMoreRanks();
                      return SizedBox.shrink();
                    }
                  }
                  final rank = _filteredRanks[index];
                  return Card(
                    elevation: 5, // Increased elevation for better shadow effect
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Rounded corners
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12), // Adjusted margins
                    child: ListTile(
                      title: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${rank.rank} - ',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // Color for the rank
                              ),
                            ),
                            TextSpan(
                              text: '${rank.handle[0]}', // First character
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: getColorForRating(rank.newRating), // Color based on rating
                              ),
                            ),
                            TextSpan(
                              text: '${rank.handle.substring(1)}', // Rest of the name
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: getColorForRating(rank.newRating), // Color based on rating
                              ),
                            ),
                          ],
                        ),
                      ),
                      subtitle: RichText(
                          text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Old Rank ',
                                  style: labelStyle,
                                ),
                                TextSpan(
                                  text: rank.oldRating.toString(),
                                  style: valueStyle,
                                ),
                                TextSpan(
                                  text: '\nNew Rank ',
                                  style: labelStyle,
                                ),
                                TextSpan(
                                  text: rank.newRating.toString(),
                                  style: valueStyle,
                                ),
                                TextSpan(
                                  text: '\nRank Change ',
                                  style: labelStyle,
                                ),
                                TextSpan(
                                  text: (rank.newRating - rank.oldRating).toString(),
                                  style: valueStyle,
                                ),
                              ]
                          )
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

class GetContestStanding {
  String status;
  List<Result> result;

  GetContestStanding({
    required this.status,
    required this.result,
  });

  factory GetContestStanding.fromJson(Map<String, dynamic> json) {
    var list = json['result'] as List;
    List<Result> resultList = list.map((i) => Result.fromJson(i)).toList();

    return GetContestStanding(
      status: json['status'],
      result: resultList,
    );
  }
}

class Result {
  String handle;
  int rank;
  int oldRating;
  int newRating;

  Result({
    required this.handle,
    required this.rank,
    required this.oldRating,
    required this.newRating,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      handle: json['handle'],
      rank: json['rank'],
      oldRating: json['oldRating'],
      newRating: json['newRating'],
    );
  }
}
