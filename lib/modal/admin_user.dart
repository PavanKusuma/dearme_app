class AdminUser {
  String? collegeId;
  String? campusId;
  String? username;
  String? userImage;


  AdminUser({this.collegeId, this.campusId, this.username, this.userImage});

  AdminUser.fromJson(Map<String, dynamic> json): 
  collegeId = json['collegeId'], 
  campusId = json['campusId'], 
  username = json['username'], 
  userImage = json['userImage'];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['collegeId']= collegeId;
    data['campusId']= campusId;
    data['username']= username;
    data['userImage']= userImage;
    return data;
  }
}