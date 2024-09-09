import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class BlogEntryPage extends StatefulWidget {
  const BlogEntryPage({Key? key}) : super(key: key);

  @override
  State<BlogEntryPage> createState() => _BlogEntryPageState();
}

class _BlogEntryPageState extends State<BlogEntryPage> {
  List<Comment> _comments = [];
  BlogEntry? _blogEntry;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _hasError = false;
  int? _blogEntryId; // Nullable blog entry ID
  TextEditingController _controller = TextEditingController();
  TextStyle labelStyle =
  TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black);
  TextStyle valueStyle = TextStyle(fontSize: 15, color: Colors.black);

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadData() async {
    if (_isLoading || !_hasMore || _blogEntryId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final blogEntry = await fetchBlog(_blogEntryId!);
      final commentList = await fetchComments(_blogEntryId!);

      setState(() {
        _blogEntry = blogEntry;
        _comments = commentList.result;
        _hasMore = false;
      });
    } catch (e) {
      print('Error loading blog entry or comments: $e');
      setState(() {
        _hasError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<BlogEntry> fetchBlog(int blogEntryId) async {
    final response = await http.get(
      Uri.https(
        'codeforces.com',
        '/api/blogEntry.view',
        {'blogEntryId': blogEntryId.toString()},
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return BlogEntry.fromJson(data['result']);
    } else {
      throw Exception('Failed to load blog entry');
    }
  }

  Future<GetCommentList> fetchComments(int blogEntryId) async {
    final response = await http.get(
      Uri.https(
        'codeforces.com',
        '/api/blogEntry.comments',
        {'blogEntryId': blogEntryId.toString()},
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return GetCommentList.fromJson(data);
    } else {
      throw Exception('Failed to load comments');
    }
  }

  void _search() {
    setState(() {
      _blogEntryId = int.tryParse(_controller.text);
      _comments.clear();
      _blogEntry = null;
      _hasError = false;
      _hasMore = true;
      _loadData();
    });
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
          "Blog Entry",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Blog Entry ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _search,
                  child: Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _hasError
                ? Center(child: Text('Failed to load data'))
                : _blogEntry == null
                ? Center(child: Text('Enter a blog entry ID and press Search'))
                : RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _comments.clear();
                  _hasMore = true;
                  _hasError = false;
                });
                await _loadData();
              },
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Title:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(height: 4),
                        Text(
                          parse(_blogEntry!.title).body?.text ?? '',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Author:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _blogEntry!.authorHandle,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Creation Time:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(height: 4),
                        Text(
                          formatDate(_blogEntry!.creationTimeSeconds),
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Modification Time:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(height: 4),
                        Text(
                          formatDate(_blogEntry!.modificationTimeSeconds),
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Tags:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(height: 4),
                        Wrap(
                          spacing: 8.0,
                          children: _blogEntry!.tags.map((tag) => Chip(label: Text(tag))).toList(),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Comments:",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _comments.length,
                          itemBuilder: (context, index) {
                            final comment = _comments[index];
                            final document = parse(comment.text);
                            final formattedText = document.body?.text ?? '';

                            return Card(
                              elevation: 2,
                              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              child: ListTile(
                                title: Text(
                                  comment.commentatorHandle,
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      formattedText,
                                      style: valueStyle,
                                    ),
                                    SizedBox(height: 4),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Created: ',
                                            style: valueStyle.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                            text: formatDate(comment.creationTimeSeconds),
                                            style: valueStyle,
                                          ),
                                          TextSpan(
                                            text: '\nRating: ',
                                            style: valueStyle.copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          TextSpan(
                                            text: comment.rating.toString(),
                                            style: valueStyle,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BlogEntry {
  String originalLocale;
  bool allowViewHistory;
  int creationTimeSeconds;
  int rating;
  String authorHandle;
  int modificationTimeSeconds;
  int id;
  String title;
  String locale;
  List<String> tags;

  BlogEntry({
    required this.originalLocale,
    required this.allowViewHistory,
    required this.creationTimeSeconds,
    required this.rating,
    required this.authorHandle,
    required this.modificationTimeSeconds,
    required this.id,
    required this.title,
    required this.locale,
    required this.tags,
  });

  factory BlogEntry.fromJson(Map<String, dynamic> json) {
    var list = json['tags'] as List;
    List<String> tagList = list.map((i) => i.toString()).toList();

    return BlogEntry(
        originalLocale: json['originalLocale'],
        allowViewHistory: json['allowViewHistory'],
        creationTimeSeconds: json['creationTimeSeconds'],
        rating: json['rating'],
        authorHandle: json['authorHandle'],
        modificationTimeSeconds: json['modificationTimeSeconds'],
        id: json['id'],
        title: json
        ['title'], locale: json['locale'], tags: tagList, ); } }


class GetCommentList {
  String status;
  List<Comment> result;

  GetCommentList({
    required this.status,
    required this.result,
  });

  factory GetCommentList.fromJson(Map<String, dynamic> json) {
    var list = json['result'] as List;
    List<Comment> commentList = list.map((i) => Comment.fromJson(i)).toList();

    return GetCommentList(
      status: json['status'],
      result: commentList,
    );
  }
}

class Comment {
  int id;
  int creationTimeSeconds;
  String commentatorHandle;
  String locale;
  String text;
  int rating;

  Comment({
    required this.id,
    required this.creationTimeSeconds,
    required this.commentatorHandle,
    required this.locale,
    required this.text,
    required this.rating,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      creationTimeSeconds: json['creationTimeSeconds'],
      commentatorHandle: json['commentatorHandle'],
      locale: json['locale'],
      text: json['text'],
      rating: json['rating'],
    );
  }
}
