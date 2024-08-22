import 'package:flutter/material.dart';

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

// Example usage in a widget
class RatingColorWidget extends StatelessWidget {
  final int rating;

  RatingColorWidget({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: getColorForRating(rating),
      child: Text(
        'Rating: $rating',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
