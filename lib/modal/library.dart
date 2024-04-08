class Library{
  
  // int? id;
  String? title;
  String? description;
  String? media;
  
  // Library({this.id, this.title, this.description, this.media});
  Library({this.title, this.description, this.media});

  factory Library.fromJson(Map<String, dynamic> json){
    return Library(
      // id: json["id"] as int,
      title: json["title"] as String,
      description: json["description"] as String,
      media: json["media"] as String,
    );
  }
}