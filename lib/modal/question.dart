class Question{

  String? questionId;
  String? assessmentId;
  String? question;
  int? questionType;
  String? media;
  int? options;
  String? option1;
  String? option2;
  String? option3;
  String? option4;
  String? option5;
  String? option6;
  int? correct;
  int? sequence;
  List<String>? optionTexts;
  int? selectedOption;
  
  Question({this.questionId, this.assessmentId, this.question, this.questionType, this.media, this.options, this.option1, this.option2, this.option3, this.option4, this.option5, 
  this.option6, this.correct, this.sequence, this.optionTexts, this.selectedOption});

  factory Question.fromJson(Map<String, dynamic> json){
    return Question(
      questionId: json["questionId"] as String, 
      assessmentId: json["assessmentId"] as String, 
      question: json["question"] as String,
      questionType: json["questionType"] as int,
      media: json["media"] as String,
      options: json["options"] as int,
      option1: json["option1"] as String,
      option2: json["option2"] as String,
      option3: json["option3"] as String,
      option4: json["option4"] as String,
      option5: json["option5"] as String,
      option6: json["option6"] as String,
      correct: json["correct"] as int,
      sequence: json["sequence"] as int,
      // optionTexts: json["optionTexts"] as List<String>
      optionTexts: [json["option1"] as String , json["option2"] as String, json["option3"] as String, json["option4"] as String, json["option5"] as String, json["option6"] as String],
      selectedOption: -1
    );
  }
}