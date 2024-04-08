class FeelingDetail{

  
  String? emotion;
  String? feeling;
  String? description;
  String? description2;
  String? description3;
  String? media;
  String? links;
  
  FeelingDetail({this.emotion, this.feeling, this.description, this.description2, this.description3, this.media, this.links});

  factory FeelingDetail.fromJson(Map<String, dynamic> json){
    return FeelingDetail(
      emotion: json["emotion"] as String,
      feeling: json["feeling"] as String,
      description: json["description"] as String,
      description2: json["description2"] as String,
      description3: json["description3"] as String,
      media: json["media"] as String,
      links: json["links"] as String,
    );
  }
}