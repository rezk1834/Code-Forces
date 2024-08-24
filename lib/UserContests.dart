import 'package:flutter/material.dart';
import 'Service/api_service.dart';

class ContestsPage extends StatelessWidget {
  final Future<Contests>? futureContests;
  final bool Mainuser;

  const ContestsPage({super.key, required this.futureContests, required this.Mainuser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Mainuser
          ? null
          : AppBar(
        title: Text(
          "Contests",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Contests>(
        future: futureContests,
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
              itemCount: contests.result.length,
              itemBuilder: (context, index) {
                final result = contests.result[index];
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
    );
  }
}
