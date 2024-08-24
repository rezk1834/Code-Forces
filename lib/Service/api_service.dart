import 'dart:convert';
import 'package:http/http.dart' as http;

// Global Variables
Future<GetInfo>? futureInfo;
Future<Contests>? futureContests;
Future<Status>? futureStatus;


Future<GetInfo> getInfo(String handle) async {
  final response = await http.get(Uri.https('codeforces.com', '/api/user.info', {'handles': handle}));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return GetInfo.fromJson(data);
  } else {
    throw Exception('Failed to load user info');
  }
}

Future<Contests> getContests(String handle) async {
  final response = await http.get(Uri.https('codeforces.com', '/api/user.rating', {'handle': handle}));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return Contests.fromJson(data);
  } else {
    throw Exception('Failed to load contests');
  }
}

Future<Status> getStatus(String handle) async {
  final response = await http.get(Uri.https('codeforces.com', '/api/user.status', {
    'handle': handle,
    'from': '1',
    'count': '100',
  }));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return Status.fromJson(data);
  } else {
    throw Exception('Failed to load Status');
  }
}


class GetInfo {
  String status;
  List<Result> result;

  GetInfo({
    required this.status,
    required this.result,
  });

  factory GetInfo.fromJson(Map<String, dynamic> json) {
    var list = json['result'] as List;
    List<Result> resultList = list.map((i) => Result.fromJson(i)).toList();

    return GetInfo(
      status: json['status'],
      result: resultList,
    );
  }
}

class Result {
  String handle;
  String? firstName;
  String? lastName;
  String? country;
  String rank;
  String maxRank;
  int rating;
  int maxRating;
  int friendOfCount;
  String avatar;
  int lastOnlineTimeSeconds;
  int registrationTimeSeconds;
  int contribution;

  Result({
    required this.handle,
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.rank,
    required this.maxRank,
    required this.rating,
    required this.maxRating,
    required this.friendOfCount,
    required this.avatar,
    required this.lastOnlineTimeSeconds,
    required this.registrationTimeSeconds,
    required this.contribution,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      handle: json['handle'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      country: json['country'] ?? '',
      rank: json['rank'],
      maxRank: json['maxRank'],
      rating: json['rating'],
      maxRating: json['maxRating'],
      friendOfCount: json['friendOfCount'],
      avatar: json['avatar'],
      lastOnlineTimeSeconds: json['lastOnlineTimeSeconds'],
      registrationTimeSeconds: json['registrationTimeSeconds'],
      contribution: json['contribution'] ?? 0,
    );
  }
}

class Contests {
  String status;
  List<ResultContest> result;

  Contests({
    required this.status,
    required this.result,
  });

  factory Contests.fromJson(Map<String, dynamic> json) {
    var list = json['result'] as List;
    List<ResultContest> resultList = list.map((i) => ResultContest.fromJson(i)).toList();

    return Contests(
      status: json['status'],
      result: resultList,
    );
  }
}

class ResultContest {
  int contestId;
  String contestName;
  String handle;
  int rank;
  int oldRating;
  int newRating;

  ResultContest({
    required this.contestId,
    required this.contestName,
    required this.handle,
    required this.rank,
    required this.oldRating,
    required this.newRating,
  });

  factory ResultContest.fromJson(Map<String, dynamic> json) {
    return ResultContest(
      contestId: json['contestId'],
      contestName: json['contestName'],
      handle: json['handle'],
      rank: json['rank'],
      oldRating: json['oldRating'],
      newRating: json['newRating'],
    );
  }
}

class Status {
  String status;
  List<ResultStatus> result;

  Status({
    required this.status,
    required this.result,
  });

  factory Status.fromJson(Map<String, dynamic> json) {
    var list = json['result'] as List;
    List<ResultStatus> resultList = list.map((i) => ResultStatus.fromJson(i)).toList();

    return Status(
      status: json['status'],
      result: resultList,
    );
  }
}

class ResultStatus {
  int id;
  int contestId;
  int creationTimeSeconds;
  Problem problem;
  String programmingLanguage;
  String verdict;


  ResultStatus({
    required this.id,
    required this.contestId,
    required this.creationTimeSeconds,
    required this.problem,
    required this.programmingLanguage,
    required this.verdict,
  });

  factory ResultStatus.fromJson(Map<String, dynamic> json) {
    return ResultStatus(
      id: json['id'],
      contestId: json['contestId'],
      creationTimeSeconds: json['creationTimeSeconds'],
      problem: Problem.fromJson(json['problem']),
      programmingLanguage: json['programmingLanguage'],
      verdict: json['verdict'],
    );
  }
}

class Problem {

  String index;
  String name;
  int rating;
  List<String> tags;

  Problem({
    required this.index,
    required this.name,
    required this.rating,
    required this.tags,
  });

  factory Problem.fromJson(Map<String, dynamic> json) {
    var tagsList = json['tags'].cast<String>();
    return Problem(
      index: json['index'],
      name: json['name'],
      rating: json['rating'],
      tags: List<String>.from(tagsList),
    );
  }
}
