import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse; // Correctly import the HTML parser

// Define the CommentPage widget
class CommentPage extends StatefulWidget {
  const CommentPage({Key? key}) : super(key: key);

  @override
  State<CommentPage> createState() => _CommentPageState();
}

Future<GetCommentList> fetchComments(int blogEntryId) async {
  final response = await http.get(Uri.https(
    'codeforces.com',
    '/api/blogEntry.comments',
    {'blogEntryId': blogEntryId.toString()},
  ));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return GetCommentList.fromJson(data);
  } else {
    throw Exception('Failed to load comments');
  }
}

// Define the state for CommentPage
class _CommentPageState extends State<CommentPage> {
  List<Comment> _comments = [];
  bool _isLoading = false;
  bool _hasMore = true;
  bool _hasError = false;
  int? _blogEntryId; // Nullable blog entry ID
  TextEditingController _controller = TextEditingController();
  TextStyle labelStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black);
  TextStyle valueStyle = TextStyle(fontSize: 15, color: Colors.black);

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadComments() async {
    if (_isLoading || !_hasMore || _blogEntryId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final commentList = await fetchComments(_blogEntryId!);
      setState(() {
        _comments = commentList.result;
        _hasMore = false; // Assuming no pagination for this endpoint
      });
    } catch (e) {
      print('Error loading comments: $e');
      setState(() {
        _hasError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchComments() {
    setState(() {
      _blogEntryId = int.tryParse(_controller.text);
      _comments.clear();
      _hasError = false;
      _hasMore = true;
      _loadComments();
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
          "Comments",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
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
                  onPressed: _searchComments,
                  child: Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _comments.clear();
                  _hasMore = true;
                  _hasError = false;
                });
                await _loadComments();
              },
              child: ListView.builder(
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  final comment = _comments[index];
                  final document = parse(comment.text); // Parse the HTML content
                  final formattedText = document.body?.text ?? ''; // Extract plain text

                  return Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: ListTile(
                      title: Text(comment.commentatorHandle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(formattedText, style: valueStyle),
                          SizedBox(height: 4,),
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
                          )

                        ],
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
