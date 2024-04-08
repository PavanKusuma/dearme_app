class Campus{

  String? campusId;
  String? campusName;
  String? courses;
  String? departments;

  // constructor and assign the values locally
  // Campus({this.campusId, this.campusName});
  Campus({this.campusId, this.campusName, this.courses, this.departments});

  factory Campus.fromJson(Map<String, dynamic> json){
    return Campus(
      campusId: json["campusId"] as String, 
      campusName: json["campusName"] as String,
      courses: json["courses"] as String,
      departments: json["departments"] as String
    );
  }
}