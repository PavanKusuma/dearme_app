class Chats{

  String? collegeId;
  String? sentAt;

  // constructor and assign the values locally
  // Campus({this.campusId, this.campusName});
  Chats({this.collegeId, this.sentAt});

  factory Chats.fromJson(Map<String, dynamic> json){
    return Chats(
      collegeId: json["collegeId"] as String,
      sentAt: json["sentAt"] as String,
    );
  }
}