class Assessment{

  String? assessmentId;
  String? campusId;
  String? media;
  String? title;
  String? title2;
  String? description;
  String? adminId;
  String? createdOn;
  int? assessmentType;
  String? assessmentStatus;
  String? assessmentOn;
  
  Assessment({this.assessmentId, this.campusId, this.media, this.title, this.title2, this.description, this.adminId, this.createdOn, this.assessmentType, 
  this.assessmentStatus, this.assessmentOn});

  factory Assessment.fromJson(Map<String, dynamic> json){
    return Assessment(
      assessmentId: json["assessmentId"] as String, 
      campusId: json["campusId"] as String,
      media: json["media"] as String,
      title: json["title"] as String,
      title2: json["title2"] as String,
      description: json["description"] as String,
      adminId: json["adminId"] as String,
      createdOn: json["createdOn"] as String,
      assessmentType: json["assessmentType"] as int,
      assessmentStatus: json["assessmentStatus"] as String,
      assessmentOn: json["assessmentOn"] as String,
    );
  }
}