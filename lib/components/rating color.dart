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
Color getVerdictColor(String verdict) {
  switch (verdict) {
    case 'OK':
      return Colors.green;
    case 'WRONG_ANSWER':
      return Colors.red;
    default:
      return Colors.grey[700]!;
  }
}
