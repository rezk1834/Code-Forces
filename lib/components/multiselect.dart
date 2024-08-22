import 'package:flutter/material.dart';

class MultiSelectChipDropdown extends StatefulWidget {
  final List<String> allTags;
  final Function(List<String>) onSelectionChanged;

  MultiSelectChipDropdown(this.allTags, {required this.onSelectionChanged});

  @override
  _MultiSelectChipDropdownState createState() =>
      _MultiSelectChipDropdownState();
}

class _MultiSelectChipDropdownState extends State<MultiSelectChipDropdown> {
  List<String> selectedTags = [];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showDialog(context);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Select Tags',
          border: OutlineInputBorder(),
        ),
        child: Text(selectedTags.isNotEmpty
            ? selectedTags.join(', ')
            : 'No tags selected'),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Tags'),
          content: SingleChildScrollView(
            child: MultiSelectChip(
              widget.allTags,
              onSelectionChanged: (selectedList) {
                setState(() {
                  selectedTags = selectedList;
                });
                widget.onSelectionChanged(selectedTags);
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class MultiSelectChip extends StatefulWidget {
  final List<String> allTags;
  final Function(List<String>) onSelectionChanged;

  MultiSelectChip(this.allTags, {required this.onSelectionChanged});

  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  List<String> selectedTags = [];

  _buildChoiceList() {
    List<Widget> choices = [];
    widget.allTags.forEach((item) {
      choices.add(
        ChoiceChip(
          label: Text(item),
          selected: selectedTags.contains(item),
          onSelected: (selected) {
            setState(() {
              selected ? selectedTags.add(item) : selectedTags.remove(item);
              widget.onSelectionChanged(selectedTags);
            });
          },
        ),
      );
    });
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('MultiSelect Chip Dropdown'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MultiSelectChipDropdown(
                [
                  "binary search",
                  "bitmasks",
                  "brute force",
                  "chinese remainder theorem",
                  "combinatorics",
                  "constructive algorithms",
                  "data structures",
                  "dfs and similar",
                  "divide and conquer",
                  "dp",
                  "dsu",
                  "expression parsing",
                  "fft",
                  "flows",
                  "games",
                  "geometry",
                  "graphs",
                  "graph matchings",
                  "greedy",
                  "hashing",
                  "implementation",
                  "interactive",
                  "math",
                  "matrices",
                  "meet in the middle",
                  "number theory",
                  "probabilities",
                  "schedules",
                  "shortest paths",
                  "sortings",
                  "special",
                  "strings",
                  "string suffix structures",
                  "ternary search",
                  "the 2 sat",
                  "trees",
                  "two pointers",
                ],
                onSelectionChanged: (selectedList) {
                  print('Selected Tags: $selectedList');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
