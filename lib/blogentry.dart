import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse; // For parsing HTML

// Define the BlogEntryPage widget
class BlogEntryPage extends StatefulWidget {
  const BlogEntryPage({Key? key}) : super(key: key);

  @override
  State<BlogEntryPage> createState() => _BlogEntryPageState();
}

Future<BlogEntry> fetchBlogEntry(int blogEntryId) async {
  final response = await http.get(Uri.https(
    'codeforces.com',
    '/api/blogEntry.view',
    {'blogEntryId': blogEntryId.toString()},
  ));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return BlogEntry.fromJson(data);
  } else {
    throw Exception('Failed to load blog entry');
  }
}

// Define the state for BlogEntryPage
class _BlogEntryPageState extends State<BlogEntryPage> {
  BlogEntry? _blogEntry;
  bool _isLoading = false;
  bool _hasError = false;
  TextEditingController _controller = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadBlogEntry() async {
    final blogEntryId = int.tryParse(_controller.text);
    if (blogEntryId == null) {
      setState(() {
        _errorMessage = 'Invalid Blog Entry ID';
        _hasError = true;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasError = false;
    });

    try {
      final blogEntry = await fetchBlogEntry(blogEntryId);
      setState(() {
        _blogEntry = blogEntry;
      });
    } catch (e) {
      print('Error loading blog entry: $e');
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load blog entry';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
        title: Text("Blog Entry"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                  onPressed: _loadBlogEntry,
                  child: Text('Fetch'),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_isLoading)
              Center(child: CircularProgressIndicator()),
            if (_hasError)
              Center(child: Text(_errorMessage ?? 'An error occurred', style: TextStyle(color: Colors.red))),
            if (_blogEntry != null) ...[
              Text("Title:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 4),
              Text(parse(_blogEntry!.title).body?.text ?? '', style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text("Author:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 4),
              Text(_blogEntry!.authorHandle, style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text("Creation Time:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 4),
              Text(formatDate(_blogEntry!.creationTimeSeconds), style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text("Modification Time:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 4),
              Text(formatDate(_blogEntry!.modificationTimeSeconds), style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text("Tags:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 4),
              Wrap(
                spacing: 8.0,
                children: _blogEntry!.tags.map((tag) => Chip(label: Text(tag))).toList(),
              ),
            ],
          ],
        ),
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
      title: json['title'],
      locale: json['locale'],
      tags: tagList,
    );
  }
}
