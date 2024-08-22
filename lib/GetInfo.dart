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
    String rank;
    int rating;
    int friendOfCount;
    String titlePhoto;
    int maxRating;
    String avatar;
    String maxRank;

    Result({
        required this.rating,
        required this.friendOfCount,
        required this.titlePhoto,
        required this.rank,
        required this.handle,
        required this.maxRating,
        required this.avatar,
        required this.maxRank,
    });

    factory Result.fromJson(Map<String, dynamic> json) {
        return Result(
            handle: json['handle'],
            rank: json['rank'],
            rating: json['rating'],
            friendOfCount: json['friendOfCount'],
            titlePhoto: json['titlePhoto'],
            maxRating: json['maxRating'],
            avatar: json['avatar'],
            maxRank: json['maxRank'],
        );
    }
}

