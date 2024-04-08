class UserDetail {
  int? detailsId;
  String? fatherName;
  String? fatherPhoneNumber;
  String? motherName;
  String? motherPhoneNumber;
  String? guardianName;
  String? guardianPhoneNumber;
  String? address;
  String? collegeId;
  String? hostelId;
  String? roomNumber;
  String? hostelName;

  UserDetail({ this.detailsId,  this.fatherName,  this.fatherPhoneNumber,  this.motherName,  this.motherPhoneNumber,  this.guardianName,  this.guardianPhoneNumber,  this.collegeId,  this.address,  this.hostelId,  this.roomNumber, this.hostelName});

  UserDetail.fromJson(Map<String, dynamic> json): 
  detailsId = json['detailsId'], 
  fatherName = json['fatherName'], 
  fatherPhoneNumber = json['fatherPhoneNumber'], 
  motherName = json['motherName'], 
  motherPhoneNumber = json['motherPhoneNumber'], 
  guardianName = json['guardianName'], 
  guardianPhoneNumber = json['guardianPhoneNumber'], 
  address = json['address'], 
  collegeId = json['collegeId'], 
  hostelId = json['hostelId'],
  roomNumber = json['roomNumber'],
  hostelName = json['hostelName'];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['detailsId']= detailsId;
    data['fatherName']= fatherName;
    data['fatherPhoneNumber']= fatherPhoneNumber;
    data['motherName']= motherName;
    data['motherPhoneNumber']= motherPhoneNumber;
    data['guardianName']= guardianName;
    data['guardianPhoneNumber']= guardianPhoneNumber;
    data['address']= address;
    data['collegeId']= collegeId;
    data['hostelId']= hostelId;
    data['roomNumber']= roomNumber;
    data['hostelName']= hostelName;
    return data;
  }
}