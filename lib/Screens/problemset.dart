import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

// Define the ProblemSet widget
class ProblemSet extends StatefulWidget {
  const ProblemSet({Key? key}) : super(key: key);

  @override
  State<ProblemSet> createState() => _ProblemSetState();
}


Future<GetProblemSet> getProblemSet(String handle, int start, int count) async {
  final response = await http.get(Uri.https(
    'codeforces.com',
    '/api/problemset.problems',
    {
     'tags':'',
      'handles': handle,
      'start': start.toString(),
      'count': count.toString(),
    },
  ));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return GetProblemSet.fromJson(data);
  } else {
    throw Exception('Failed to load problem set');
  }
}

// Define the state for ProblemSet
class _ProblemSetState extends State<ProblemSet> {
  late Future<GetProblemSet> _futureProblemSet;
  List<Result> _problems = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _start = 0;
  final int _count = 20;
  final String _handle = 'your_handle_here';  // Replace with your handle
  String _sortBy = 'rating'; // Field for sorting
  bool _ascending = false;
  int? _minRating;
  int? _maxRating;

  @override
  void initState() {
    super.initState();
    _loadMoreProblems();
  }

  Future<void> _loadMoreProblems() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final problemSet = await getProblemSet(_handle, _start, _count);
      setState(() {
        _start += _count;
        _problems.addAll(problemSet.result);
        _hasMore = problemSet.result.length == _count;
        _sortProblems(); // Sort problems after fetching
      });
    } catch (e) {
      print('Error loading problems: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _sortProblems() {
    if (_sortBy == 'rating') {
      _problems.sort((a, b) {
        final comparison = (b.rating ?? 0).compareTo(a.rating ?? 0);
        return _ascending ? comparison : -comparison;
      });
    } else {
      _problems.sort((a, b) {
        final comparison = a.name.compareTo(b.name);
        return _ascending ? comparison : -comparison;
      });
    }
  }
  void _filterProblems() {
    setState(() {
      _problems = _problems.where((problem) {
        final rating = problem.rating;
        return (rating != null) &&
            (_minRating == null || rating >= _minRating!) &&
            (_maxRating == null || rating <= _maxRating!);
      }).toList();
      _sortProblems();
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
          "Problem Set",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Sorting and filtering controls
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _sortBy,
                    onChanged: (String? newValue) {
                      setState(() {
                        _sortBy = newValue!;
                        _sortProblems();
                      });
                    },
                    items: <String>['rating', 'name'].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value.capitalize()),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(width: 16),
                IconButton(
                  icon: Icon(
                    _ascending ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _ascending = !_ascending;
                      _sortProblems();
                    });
                  },
                ),
              ],
            ),
          ),
          // Rating filter controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Min Rating'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _minRating = int.tryParse(value);
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(labelText: 'Max Rating'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _maxRating = int.tryParse(value);
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search, color: Theme.of(context).primaryColor),
                  onPressed: () {
                    setState(() {
                      _filterProblems();
                    });
                  },
                ),
              ],
            ),
          ),
          // Problem list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _start = 0;
                  _problems.clear();
                  _hasMore = true;
                });
                await _loadMoreProblems();
              },
              child: ListView.builder(
                itemCount: _problems.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _problems.length) {
                    _loadMoreProblems();
                    return Text("");
                  }
                  final problem = _problems[index];
                  return GestureDetector(
                    onTap: () {
                      final url = "https://codeforces.com/contest/${problem.contestID}/problem/${problem.index}";
                      _launchURL(url);
                    },
                    child: Card(
                      elevation: 5, // Increased elevation for better shadow effect
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                      ),
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12), // Adjusted margins
                      child: ListTile(
                        title: Text(problem.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contest ID: ${problem.contestID}\nIndex: ${problem.index}${problem.rating != null ? ', \nRating: ${problem.rating}' : ''}',
                              style: TextStyle(fontSize: 15),
                            ),
                            SizedBox(height: 4),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: problem.tags.map((tag) {
                                return Chip(
                                  labelStyle: TextStyle(fontSize: 10),
                                  label: Text(tag.split('.').last.replaceAll('_', ' ').capitalize()),
                                );
                              }).toList(),
                            ),
                          ],
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

// Define the GetProblemSet class
class GetProblemSet {
  String status;
  List<Result> result;

  GetProblemSet({
    required this.status,
    required this.result,
  });

  factory GetProblemSet.fromJson(Map<String, dynamic> json) {
    var list = json['result']['problems'] as List;
    List<Result> resultList = list.map((i) => Result.fromJson(i)).toList();

    return GetProblemSet(
      status: json['status'],
      result: resultList,
    );
  }
}

// Define the Result class
class Result {
  int contestID;
  String name;
  String index;
  List<String> tags;
  int? rating;

  Result({
    required this.contestID,
    required this.name,
    required this.index,
    required this.tags,
    this.rating,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      contestID: json['contestId'],
      name: json['name'],
      index: json['index'],
      rating: json['rating'],
      tags: List<String>.from(json['tags']),
    );
  }
}

// Extension for capitalizing the first letter of a string
extension StringCapitalize on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return '${this[0].toUpperCase()}${this.substring(1)}';
  }
}
