class Mood{

  
  int? id;
  String? createdOn;
  String? campusId;
  String? collegeId;
  String? emotion;
  String? feeling;
  String? description;
  
  Mood({this.id, this.createdOn, this.campusId, this.collegeId, this.emotion, this.feeling, this.description});

  factory Mood.fromJson(Map<String, dynamic> json){
    return Mood(
      id: json["id"] as int,
      createdOn: json["createdOn"] as String,
      campusId: json["campusId"] as String,
      emotion: json["emotion"] as String,
      feeling: json["feeling"] as String,
      description: json["description"] as String
    );
  }
}