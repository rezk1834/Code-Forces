import 'package:flutter/material.dart';
TextStyle labelStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 15,color: Colors.black);
TextStyle valueStyle = TextStyle(fontSize: 15,color: Colors.black);
// Function to get color based on rating
Color getColorForRating(int rating) {
  if (rating >= 2600) {
    return Colors.red; // International Grandmaster
  } else if (rating >= 2400) {
    return Colors.red; // Grandmaster
  } else if (rating >= 2300) {
    return Colors.orange; // International Master
  } else if (rating >= 2200) {
    return Colors.orange; // Master
  } else if (rating >= 1900) {
    return Colors.purple; // Candidate Master
  } else if (rating >= 1600) {
    return Colors.blue; // Expert
  } else if (rating >= 1400) {
    return Colors.cyan; // Specialist
  } else if (rating >= 1200) {
    return Colors.green; // Pupil
  } else {
    return Colors.grey; // Newbie
  }
}
Color getVerdictColor(String? verdict) {
  switch (verdict) {
    case 'OK':
      return Colors.green;
    case 'WRONG_ANSWER':
      return Colors.red;
    default:
      return Colors.grey[700]!;
  }
}

Color getColorForTag(String tag) {
  switch (tag) {
    case 'implementation':
      return Colors.red;
    case 'math':
      return Colors.blue;
    case 'greedy':
      return Colors.green;
    case 'dp':
      return Colors.orange;
    case 'data structures':
      return Colors.purple;
    case 'brute force':
      return Colors.cyan;
    case 'constructive algorithms':
      return Colors.amber;
    case 'graphs':
      return Colors.teal;
    case 'sortings':
      return Colors.indigo;
    case 'binary search':
      return Colors.lime;
    case 'dfs and similar':
      return Colors.pink;
    case 'trees':
      return Colors.brown;
    case 'strings':
      return Colors.blueGrey;
    case 'number theory':
      return Colors.deepOrange;
    case 'combinatorics':
      return Colors.deepPurple;
    case '[*special]':
      return Colors.yellow;
    case 'geometry':
      return Colors.lightGreen;
    case 'bitmasks':
      return Colors.lightBlue;
    case 'two pointers':
      return Colors.limeAccent;
    case 'dsu':
      return Colors.grey;
    case 'shortest paths':
      return Colors.redAccent;
    case 'probabilities':
      return Colors.blueAccent;
    case 'divide and conquer':
      return Colors.greenAccent;
    case 'hashing':
      return Colors.orangeAccent;
    case 'games':
      return Colors.purpleAccent;
    case 'flows':
      return Colors.tealAccent;
    case 'interactive':
      return Colors.cyanAccent;
    case 'matrices':
      return Colors.amberAccent;
    case 'string suffix structures':
      return Colors.lightGreenAccent;
    case 'fft':
      return Colors.lightBlueAccent;
    case 'graph matchings':
      return Colors.lightGreen;
    case 'ternary search':
      return Colors.deepOrangeAccent;
    case 'expression parsing':
      return Colors.red;
    case 'meet-in-the-middle':
      return Colors.blue;
    case '2-sat':
      return Colors.green;
    case 'chinese remainder theorem':
      return Colors.orange;
    case 'schedules':
      return Colors.purple;
    default:
      return Colors.grey; // Default color for unknown tags
  }
}
