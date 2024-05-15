class Appointment{

  String? appointmentId;
  String? collegeId;
  String? adminId;
  String? adminName;
  String? topic;
  String? description;
  String? requestDate;
  String? startTime;
  String? endTime;
  int? isOpen;
  String? requestStatus;
  String? notes;
  int? mode;
  String? createdOn;
  String? updatedOn;
  String? campusId;

  // constructor and assign the values locally
  // Campus({this.campusId, this.campusName});
  Appointment({this.appointmentId, this.collegeId, this.adminId, this.adminName, this.topic, this.description, this.requestDate, this.startTime, this.endTime, this.isOpen, this.requestStatus, 
  this.notes, this.mode, this.createdOn, this.updatedOn, this.campusId});

  factory Appointment.fromJson(Map<String, dynamic> json){
    return Appointment(
      appointmentId: json["appointmentId"] as String, 
      collegeId: json["collegeId"] as String,
      adminId: json["adminId"] as String,
      adminName: json["adminName"] as String,
      description: json["description"] as String,
      requestDate: json["requestDate"] as String,
      startTime: json["startTime"] as String,
      endTime: json["endTime"] as String,
      isOpen: json["isOpen"] as int,
      requestStatus: json["requestStatus"] as String,
      notes: json["notes"] as String,
      mode: json["mode"] as int,
      createdOn: json["createdOn"] as String,
      updatedOn: json["updatedOn"] as String,
      campusId: json["campusId"] as String,
    );
  }
}