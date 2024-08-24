import 'package:flutter/material.dart';
import 'Service/api_service.dart';
import 'components/rating color.dart';

class StatusPage extends StatelessWidget {
  final Future<Status>? futureStatus;
  final String handle;
  final bool Mainuser;

  const StatusPage({
    super.key,
    required this.futureStatus,
    required this.handle,
    required this.Mainuser,
  });


  String formatDate(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Mainuser
          ? null
          : AppBar(
        title: Text(
          "Status",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Status>(
        future: futureStatus,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.result.isEmpty) {
            return Center(child: Text('No status data available'));
          } else {
            final status = snapshot.data!;
            return ListView.builder(
              itemCount: status.result.length,
              itemBuilder: (context, index) {
                final result = status.result[index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
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
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
