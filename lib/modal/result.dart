class Result{

  String? resultId;
  String? assessmentId;
  String? result;
  String? title;
  String? message1;
  String? message2;
  String? media;

  // constructor and assign the values locally
  // Result({this.campusId, this.campusName});
  Result({this.resultId, this.assessmentId, this.result, this.title, this.message1, this.message2, this.media});

  factory Result.fromJson(Map<String, dynamic> json){
    return Result(
      resultId: json["resultId"] as String, 
      assessmentId: json["assessmentId"] as String,
      result: json["result"] as String,
      title: json["title"] as String,
      message1: json["message1"] as String,
      message2: json["message2"] as String,
      media: json["media"] as String
    );
  }
}