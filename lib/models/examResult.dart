class Result {
  String questionId;
  List<String> answers;
  int timeIn100ms;
  bool correct;
  Result(this.questionId, this.answers, this.timeIn100ms, this.correct);

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['questionId'] = questionId;
    map['answers'] = [];
    answers.forEach((element) {map['answers'].add(element);});
    map['timeIn100ms'] = timeIn100ms;
    map['correct'] = correct;
    return map;
  }

  Result.fromMap(Map<String, dynamic> map) {
    this.questionId = map['questionId'];
    this.timeIn100ms = map['timeIn100ms'];
    this.correct = map['correct'];
    this.answers = [];
    if(map['answers'] != null) {
      map['answers'].forEach((element) {
        this.answers.add(element);
      });
    }
  }
  
}

class ExamResult {
  String userId;
  DateTime createdAt;
  List<Result> results;

  ExamResult(this.userId) {
    results = [];
    createdAt = DateTime.now();
  }

  int totalTimeIn100ms() {
    int rv = 0;
    results.forEach((element) { rv += element.timeIn100ms;});
    return rv;
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map['userId'] = this.userId;
    map['createdAt'] = this.createdAt;
    map['results'] = [];
    this.results.forEach((element) { map['results'].add(element.toMap());});
    return map;
  }


  ExamResult.fromMap(Map<String, dynamic> map) {
    this.userId= map['userId'];
    if(map['createdAt'] != null) {
      this.createdAt = map['createdAt'];
    } else {
      this.createdAt = DateTime.now();
    }
    this.results=[];
    if(map['results'] != null) {
      map['results'].forEach((element) {
        this.results.add(Result.fromMap(element));
      });
    }
  }
}

