class FeedbackQuestion {
  final int questionId;
  final String question;
  final int value;
  final String flag;
  final String comments;

  FeedbackQuestion({
    required this.questionId,
    required this.question,
    required this.value,
    required this.flag,
    required this.comments,
  });

  factory FeedbackQuestion.fromJson(Map<String, dynamic> json) {
    return FeedbackQuestion(
      questionId: json['question_id'] ?? 0,
      question: json['question'] ?? '',
      value: json['value'] ?? 0,
      flag: json['flag'] ?? '',
      comments: json['comments'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'question': question,
      'value': value,
      'flag': flag,
      'comments': comments,
    };
  }
}
