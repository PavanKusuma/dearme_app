class MoodAdmin{

  
  String? emotion;
  int? count;
  int? collegeId;
  
  MoodAdmin({this.emotion, this.count, this.collegeId});

  factory MoodAdmin.fromJson(Map<String, dynamic> json){
    return MoodAdmin(
      emotion: json["emotion"] as String,
      count: json["count"] as int,
      collegeId: json["collegeId"] as int
    );
  }
}