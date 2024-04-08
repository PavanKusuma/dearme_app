class Feeling{

  
  String? emotion;
  String? feeling;
  String? description;
  String? media;
  
  Feeling({this.emotion, this.feeling, this.description, this.media});

  factory Feeling.fromJson(Map<String, dynamic> json){
    return Feeling(
      emotion: json["emotion"] as String,
      feeling: json["feeling"] as String,
      description: json["description"] as String,
      media: json["media"] as String,
    );
  }
}