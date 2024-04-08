class Chat{

  String? chatId;
  String? collegeId;
  String? adminId;
  String? message;
  String? sentAt;
  String? sentBy;
  String? chatDate;
  String? campusId;

  // constructor and assign the values locally
  // Campus({this.campusId, this.campusName});
  Chat({this.chatId, this.collegeId, this.adminId, this.message, this.sentAt, this.sentBy, this.chatDate, this.campusId});

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
      chatId: json["chatId"] as String, 
      collegeId: json["collegeId"] as String,
      adminId: json["adminId"] as String,
      message: json["message"] as String,
      sentAt: json["sentAt"] as String,
      sentBy: json["sentBy"] as String,
      chatDate: json["chatDate"] as String,
      campusId: json["campusId"] as String,
    );

  // factory Chat.fromJson(Map<String, dynamic> json){
  //   return Chat(
  //     chatId: json["chatId"] as String, 
  //     collegeId: json["collegeId"] as String,
  //     adminId: json["adminId"] as String,
  //     message: json["message"] as String,
  //     sentAt: json["sentAt"] as String,
  //     sentBy: json["sentBy"] as String,
  //     chatDate: json["chatDate"] as String,
  //     campusId: json["campusId"] as String,
  //   );
  // }

   Map<String, dynamic> toJson() => {
    'chatId': chatId,
    'collegeId': collegeId,
    'adminId': adminId,
    'message': message,
    'sentAt': sentAt,
    'sentBy': sentBy,
    'chatDate': chatDate,
    'campusId': campusId,
  };
}