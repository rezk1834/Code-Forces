import 'dart:convert';
import 'package:http/http.dart' as http;


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

Future<Contests> getContests(String handle) async {
  final response = await http.get(Uri.https('codeforces.com', '/api/user.rating', {'handle': handle}));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return Contests.fromJson(data);
  } else {
    throw Exception('Failed to load contests');
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

Future<Status> getStatus(String handle) async {
  final response = await http.get(Uri.https('codeforces.com', '/api/user.status', {
    'handle': handle,
    'from': '1',
    'count': '1000',
  }));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return Status.fromJson(data);
  } else {
    throw Exception('Failed to load Status');
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
  String? verdict;

  ResultStatus({
    required this.id,
    required this.contestId,
    required this.creationTimeSeconds,
    required this.problem,
    required this.programmingLanguage,
    this.verdict,
  });

  factory ResultStatus.fromJson(Map<String, dynamic> json) {
    return ResultStatus(
      id: json['id'],
      contestId: json['contestId'],
      creationTimeSeconds: json['creationTimeSeconds'],
      problem: Problem.fromJson(json['problem']),
      programmingLanguage: json['programmingLanguage'],
      verdict: json['verdict'],  // Nullable field
    );
  }
}

class Problem {
  String index;
  String name;
  int? rating;
  List<String> tags;

  Problem({
    required this.index,
    required this.name,
    this.rating,
    required this.tags,
  });

  factory Problem.fromJson(Map<String, dynamic> json) {
    var tagsList = json['tags']?.cast<String>() ?? [];
    return Problem(
      index: json['index'],
      name: json['name'],
      rating: json['rating'],
      tags: List<String>.from(tagsList),
    );
  }
}



class GetContest {
  String status;
  List<ContestResult> result;

  GetContest({
    required this.status,
    required this.result,
  });

  factory GetContest.fromJson(Map<String, dynamic> json) {
    var list = json['result'] as List;
    List<ContestResult> resultList = list.map((i) => ContestResult.fromJson(i)).toList();

    return GetContest(
      status: json['status'],
      result: resultList,
    );
  }
}

class ContestResult {
  int id;
  String name;
  String phase;
  int durationSeconds;
  int startTimeSeconds;
  int relativeTimeSeconds;

  ContestResult({
    required this.id,
    required this.name,
    required this.phase,
    required this.durationSeconds,
    required this.startTimeSeconds,
    required this.relativeTimeSeconds,
  });

  factory ContestResult.fromJson(Map<String, dynamic> json) {
    return ContestResult(
      id: json['id'],
      name: json['name'],
      phase: json['phase'],
      durationSeconds: json['durationSeconds'],
      startTimeSeconds: json['startTimeSeconds'],
      relativeTimeSeconds: json['relativeTimeSeconds'],
    );
  }
}



class GetProblemSet {
  String status;
  List<ProblemSetResults> result;

  GetProblemSet({
    required this.status,
    required this.result,
  });

  factory GetProblemSet.fromJson(Map<String, dynamic> json) {
    var list = json['result']['problems'] as List;
    List<ProblemSetResults> resultList = list.map((i) => ProblemSetResults.fromJson(i)).toList();

    return GetProblemSet(
      status: json['status'],
      result: resultList,
    );
  }
}

class ProblemSetResults {
  int contestID;
  String name;
  String index;
  List<String> tags;
  int? rating;

  ProblemSetResults({
    required this.contestID,
    required this.name,
    required this.index,
    required this.tags,
    this.rating,
  });

  factory ProblemSetResults.fromJson(Map<String, dynamic> json) {
    return ProblemSetResults(
      contestID: json['contestId'],
      name: json['name'],
      index: json['index'],
      rating: json['rating'],
      tags: List<String>.from(json['tags']),
    );
  }
}

extension StringCapitalize on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return '${this[0].toUpperCase()}${this.substring(1)}';
  }
}


