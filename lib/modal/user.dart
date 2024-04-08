class User {
  String? collegeId;
  String? campusId;
  String? username;
  String? email;
  String? universityId;
  String? branch;
  String? phoneNumber;
  String? role;
  String? gender;
  int? year;
  int? mediaCount;
  int? semester;
  String? userImage;
  String? gcmRegId;
  String? type;
  String? outingType;
  String? course;
  String? section;
  int? profileUpdated;
  
  int? detailsId;
  String? fatherName;
  String? fatherPhoneNumber;
  String? motherName;
  String? motherPhoneNumber;
  String? guardianName;
  String? guardianPhoneNumber;
  String? guardian2Name;
  String? guardian2PhoneNumber;
  String? address;
  String? hostelId;
  String? roomNumber;
  String? hostelName;


  User({this.collegeId, this.campusId, this.username, this.email, this.universityId, this.branch, this.phoneNumber,
  this.role, this.gender, this.year, this.mediaCount, this.semester, this.userImage, this.gcmRegId, this.type, this.outingType, this.course, this.section, this.detailsId, this.fatherName, this.fatherPhoneNumber, this.motherName, this.motherPhoneNumber, this.guardianName, this.guardianPhoneNumber, this.guardian2Name, this.guardian2PhoneNumber, this.address, this.hostelId, this.roomNumber, this.profileUpdated, this.hostelName});

  User.fromJson(Map<String, dynamic> json): 
  collegeId = json['collegeId'], 
  campusId = json['campusId'], 
  username = json['username'], 
  email = json['email'], 
  universityId = json['universityId'], 
  branch = json['branch'], 
  phoneNumber = json['phoneNumber'],
  role = json['role'],
  gender = json['gender'],
  year = json['year'],
  mediaCount = json['mediaCount'],
  semester = json['semester'],
  userImage = json['userImage'],
  gcmRegId = json['gcm_regId'],
  type = json['type'],
  outingType = json['outingType'],
  course = json['course'],
  section = json['section'],
  
  detailsId = json['detailsId'],
  fatherName = json['fatherName'],
  fatherPhoneNumber = json['fatherPhoneNumber'],
  motherName = json['motherName'],
  motherPhoneNumber = json['motherPhoneNumber'],
  guardianName = json['guardianName'],
  guardianPhoneNumber = json['guardianPhoneNumber'],
  guardian2Name = json['guardian2Name'],
  guardian2PhoneNumber = json['guardian2PhoneNumber'],
  address = json['address'],
  hostelId = json['hostelId'],
  roomNumber = json['roomNumber'],
  profileUpdated = json['profileUpdated'],
  hostelName = json['hostelName'];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = new Map<String, dynamic>();
    data['collegeId']= collegeId;
    data['campusId']= campusId;
    data['username']= username;
    data['email']= email;
    data['universityId']= universityId;
    data['branch']= branch;
    data['phoneNumber']= phoneNumber;
    data['role']= role;
    data['gender']= gender;
    data['year']= year;
    data['mediaCount']= mediaCount;
    data['semester']= semester;
    data['userImage']= userImage;
    data['gcm_regId']= gcmRegId;
    data['type']= type;
    data['outingType']= outingType;
    data['course']= course;
    data['section']= section;
    data['profileUpdated']= profileUpdated;
    
    data['detailsId']= detailsId;
    data['fatherName']= fatherName;
    data['fatherPhoneNumber']= fatherPhoneNumber;
    data['motherName']= motherName;
    data['motherPhoneNumber']= motherPhoneNumber;
    data['guardianName']= guardianName;
    data['guardianPhoneNumber']= guardianPhoneNumber;
    data['guardian2Name']= guardian2Name;
    data['guardian2PhoneNumber']= guardian2PhoneNumber;
    data['address']= address;
    data['hostelId']= hostelId;
    data['roomNumber']= roomNumber;
    data['hostelName']= hostelName;
    return data;
  }
}
// class User {
//   String? userObjectId;
//   String? campusId;
//   String? username;
//   String? email;
//   String? collegeId;
//   String? branch;
//   String? phoneNumber;
//   String? role;
//   int? year;
//   int? mediaCount;
//   int? semester;
//   String? userImage;
//   String? gcmRegId;
//   String? type;
//   String? outingType;
//   String? department;
//   String? section;
//   int? profileUpdated;
  
//   int? detailsId;
//   String? fatherName;
//   String? fatherPhoneNumber;
//   String? motherName;
//   String? motherPhoneNumber;
//   String? guardianName;
//   String? guardianPhoneNumber;
//   String? guardian2Name;
//   String? guardian2PhoneNumber;
//   String? address;
//   String? hostelId;
//   String? roomNumber;
//   String? hostelName;


//   User({this.userObjectId, this.campusId, this.username, this.email, this.collegeId, this.branch, this.phoneNumber,
//   this.role, this.year, this.mediaCount, this.semester, this.userImage, this.gcmRegId, this.type, this.outingType, this.department, this.section, this.detailsId, this.fatherName, this.fatherPhoneNumber, this.motherName, this.motherPhoneNumber, this.guardianName, this.guardianPhoneNumber, this.guardian2Name, this.guardian2PhoneNumber, this.address, this.hostelId, this.roomNumber, this.profileUpdated, this.hostelName});

//   User.fromJson(Map<String, dynamic> json): 
//   userObjectId = json['userObjectId'], 
//   campusId = json['campusId'], 
//   username = json['username'], 
//   email = json['email'], 
//   collegeId = json['userObjectId'], 
//   branch = json['branch'], 
//   phoneNumber = json['phoneNumber'],
//   role = json['role'],
//   year = json['year'],
//   mediaCount = json['mediaCount'],
//   semester = json['semester'],
//   userImage = json['userImage'],
//   gcmRegId = json['gcm_regId'],
//   type = json['type'],
//   outingType = json['outingType'],
//   department = json['department'],
//   section = json['section'],
  
//   detailsId = json['detailsId'],
//   fatherName = json['fatherName'],
//   fatherPhoneNumber = json['fatherPhoneNumber'],
//   motherName = json['motherName'],
//   motherPhoneNumber = json['motherPhoneNumber'],
//   guardianName = json['guardianName'],
//   guardianPhoneNumber = json['guardianPhoneNumber'],
//   guardian2Name = json['guardian2Name'],
//   guardian2PhoneNumber = json['guardian2PhoneNumber'],
//   address = json['address'],
//   hostelId = json['hostelId'],
//   roomNumber = json['roomNumber'],
//   profileUpdated = json['profileUpdated'],
//   hostelName = json['hostelName'];

//   Map<String, dynamic> toJson() {
//     Map<String, dynamic> data = new Map<String, dynamic>();
//     data['userObjectId']= userObjectId;
//     data['campusId']= campusId;
//     data['username']= username;
//     data['email']= email;
//     data['collegeId']= collegeId;
//     data['branch']= branch;
//     data['phoneNumber']= phoneNumber;
//     data['role']= role;
//     data['year']= year;
//     data['mediaCount']= mediaCount;
//     data['semester']= semester;
//     data['userImage']= userImage;
//     data['gcm_regId']= gcmRegId;
//     data['type']= type;
//     data['outingType']= outingType;
//     data['department']= department;
//     data['section']= section;
//     data['profileUpdated']= profileUpdated;
    
//     data['detailsId']= detailsId;
//     data['fatherName']= fatherName;
//     data['fatherPhoneNumber']= fatherPhoneNumber;
//     data['motherName']= motherName;
//     data['motherPhoneNumber']= motherPhoneNumber;
//     data['guardianName']= guardianName;
//     data['guardianPhoneNumber']= guardianPhoneNumber;
//     data['guardian2Name']= guardian2Name;
//     data['guardian2PhoneNumber']= guardian2PhoneNumber;
//     data['address']= address;
//     data['hostelId']= hostelId;
//     data['roomNumber']= roomNumber;
//     data['hostelName']= hostelName;
//     return data;
//   }
// }