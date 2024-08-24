import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Service/api_service.dart';
import 'components/rating color.dart'; // Ensure import matches your file

class UserPage extends StatefulWidget {
  final String handle;
  final Future<GetInfo> futureInfo;
  final Future<Contests>? futureContests;
  final Future<Status>? futureStatus;

  const UserPage({
    super.key,
    required this.handle,
    required this.futureInfo,
    this.futureContests, this.futureStatus,
  });

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  Future<GetInfo>? _futureInfo;

  @override
  void initState() {
    super.initState();
    _futureInfo = widget.futureInfo;
  }
  String formatDate(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<GetInfo>(
        future: _futureInfo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.result.isEmpty) {
            return Center(child: Text('No user info available'));
          } else {
            final info = snapshot.data!;
            final result = info.result[0];
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 95,
                        height: 120,
                        margin: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                          image: DecorationImage(
                            image: NetworkImage(result.avatar),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${result.rank}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: getColorForRating(result.rating),
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${result.handle[0]}',
                                    style: result.rating <= 2900
                                        ? labelStyle.copyWith(
                                      fontSize: 20,
                                      color: getColorForRating(result.rating),
                                      fontWeight: FontWeight.bold,
                                    )
                                        : TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '${result.handle.substring(1)}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: getColorForRating(result.rating),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Max Rank: ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextSpan(
                                    text: result.maxRank.toString(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: getColorForRating(result.maxRating),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Max Rating: ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextSpan(
                                    text: result.maxRating.toString(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: getColorForRating(result.maxRating),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Friends of: ${result.friendOfCount} users',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Last Contest",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  FutureBuilder<Contests>(
                    future: widget.futureContests,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.result.isEmpty) {
                        return Center(child: Text('No contest data available'));
                      } else {
                        final contests = snapshot.data!;
                        contests.result.sort((a, b) => b.contestId.compareTo(a.contestId));

                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: contests.result.length > 1 ? 1 : contests.result.length,
                          itemBuilder: (context, index) {
                            final result = contests.result[0];
                            return Card(
                              elevation: 2,
                              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(8),
                                title: Text(
                                  result.contestName,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Rank: ${result.rank}\n',
                                        style: TextStyle(fontSize: 14, color: Colors.black),
                                      ),
                                      TextSpan(
                                        text: 'Old Rating: ${result.oldRating}\n',
                                        style: TextStyle(fontSize: 14, color: Colors.black),
                                      ),
                                      TextSpan(
                                        text: 'New Rating: ${result.newRating}\n',
                                        style: TextStyle(fontSize: 14, color: Colors.black),
                                      ),
                                      TextSpan(
                                        text: 'Rating Change: ',
                                        style: TextStyle(fontSize: 14, color: Colors.black),
                                      ),
                                      TextSpan(
                                        text: '${result.newRating - result.oldRating}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: result.newRating - result.oldRating > 0 ? Colors.green : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Last Submmision",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  FutureBuilder<Status>(
                    future: widget.futureStatus,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.result.isEmpty) {
                        return Center(child: Text('No data available'));
                      } else {
                        final status = snapshot.data!;
                        status.result.sort((a, b) => b.contestId.compareTo(a.contestId));

                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: status.result.length > 1 ? 1 : status.result.length,
                          itemBuilder: (context, index) {
                            final result = status.result[0];
                            return Card(
                              elevation: 2,
                              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(8),
                                title: Text(
                                  "${result.problem.index} - ${result.problem.name}",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Submission ID: ${result.id}\n',
                                            style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,),
                                          ),TextSpan(
                                            text: 'Contest: ${result.contestId}\n',
                                            style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,),
                                          ),TextSpan(
                                            text: 'Submission Time: ${formatDate(result.creationTimeSeconds)}\n',
                                            style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,),
                                          ),TextSpan(
                                            text: 'Rating: ${result.problem.rating}\n',
                                            style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,),
                                          ),
                                          TextSpan(
                                            text: 'Verdict: ',
                                            style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,),
                                          ),
                                          TextSpan(
                                            text: result.verdict,
                                            style: TextStyle(
                                              color: getVerdictColor(result.verdict),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '\nLanguage: ${result.programmingLanguage}',
                                            style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Wrap(
                                      spacing: 4,
                                      children: result.problem.tags.map((tag) => Chip(label: Text(tag))).toList(),
                                    ),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
