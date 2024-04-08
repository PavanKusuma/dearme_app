class LibraryDetails{
  
  int? id;
  String? title;
  String? feeling;
  String? description;
  String? description2;
  String? description3;
  String? media;
  String? links;
  String? createdDate;
  
  LibraryDetails({this.id, this.title, this.feeling, this.description, this.description2, this.description3, this.media, this.links, this.createdDate});

  factory LibraryDetails.fromJson(Map<String, dynamic> json){
    return LibraryDetails(
      id: json["id"] as int,
      title: json["title"] as String,
      feeling: json["feeling"] as String,
      description: json["description"] as String,
      description2: json["description2"] as String,
      description3: json["description3"] as String,
      media: json["media"] as String,
      links: json["links"] as String,
      createdDate: json["createdDate"] as String,
    );
  }
}