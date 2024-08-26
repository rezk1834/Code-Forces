import 'dart:convert';
import 'package:codeforces/Service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';


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
      'tags': '',
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

class _ProblemSetState extends State<ProblemSet> {
  late Future<GetProblemSet> _futureProblemSet;
  List<ProblemSetResults> _problems = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _start = 0;
  final int _count = 20;
  final String _handle = 'your_handle_here';
  String _sortBy = 'rating';
  bool _ascending = false;
  int? _minRating;
  int? _maxRating;
  List<String> _selectedTags = [];

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
        _applyFiltersAndSorting();
      });
    } catch (e) {
      print('Error loading problems: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFiltersAndSorting() {
    setState(() {
      _problems = _problems.where((problem) {
        final rating = problem.rating ?? 0;
        final matchesRating = (_minRating == null || rating >= _minRating!) &&
            (_maxRating == null || rating <= _maxRating!);

        final matchesTags = _selectedTags.isEmpty ||
            _selectedTags.any((tag) => problem.tags.contains(tag));

        return matchesRating && matchesTags;
      }).toList();

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
    });
  }

  void _openFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        Map<String, bool> selectedTagsMap = {
          'implementation': false,
          'math': false,
          'greedy': false,
          'dp': false,
          'data structures': false,
          'brute force': false,
          'constructive algorithms': false,
          'graphs': false,
          'sortings': false,
          'binary search': false,
          'dfs and similar': false,
          'trees': false,
          'strings': false,
          'number theory': false,
          'combinatorics': false,
          'geometry': false,
          'bitmasks': false,
          'two pointers': false,
          'dsu': false,
          'shortest paths': false,
          'probabilities': false,
          'divide and conquer': false,
          'hashing': false,
          'games': false,
          'flows': false,
          'interactive': false,
          'matrices': false,
          'string suffix structures': false,
          'fft': false,
          'graph matchings': false,
          'ternary search': false,
          'expression parsing': false,
          'meet-in-the-middle': false,
          '2-sat': false,
          'chinese remainder theorem': false,
          'schedules': false,
        };

        _selectedTags.forEach((tag) {
          if (selectedTagsMap.containsKey(tag)) {
            selectedTagsMap[tag] = true;
          }
        });

        TextEditingController minRatingController = TextEditingController();
        TextEditingController maxRatingController = TextEditingController();

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Select Tags",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Wrap(
                      spacing: 10.0,
                      runSpacing: 10.0,
                      children: selectedTagsMap.keys.map((String tag) {
                        return FilterChip(
                          label: Text(tag.capitalize()),
                          selected: selectedTagsMap[tag]!,
                          onSelected: (bool value) {
                            setState(() {
                              selectedTagsMap[tag] = value;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: minRatingController,
                      decoration: InputDecoration(
                        labelText: 'Min Rating',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: maxRatingController,
                      decoration: InputDecoration(
                        labelText: 'Max Rating',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _minRating = int.tryParse(minRatingController.text);
                          _maxRating = int.tryParse(maxRatingController.text);
                          _selectedTags = selectedTagsMap.entries
                              .where((entry) => entry.value)
                              .map((entry) => entry.key)
                              .toList();
                        });
                        _applyFiltersAndSorting();
                        Navigator.pop(context);
                      },
                      child: Text('Apply Filters'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _openFilterBottomSheet,
          ),
          IconButton(
            icon: Icon(
              _ascending ? Icons.arrow_upward : Icons.arrow_downward,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _ascending = !_ascending;
                _applyFiltersAndSorting();
              });
            },
          ),
        ],
      ),

      body: Column(
        children: [

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
                      _applyFiltersAndSorting();
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
