class CreateFeedbackRequest {
  final String grievanceId;
  final List<FeedbackItem> feedbackList;

  CreateFeedbackRequest({
    required this.grievanceId,
    required this.feedbackList,
  });

  Map<String, dynamic> toJson() {
    return {
      'grievance_id': grievanceId,
      'feedback_list': feedbackList.map((item) => item.toJson()).toList(),
    };
  }
}

class FeedbackItem {
  final int questionId;
  final int value;

  FeedbackItem({
    required this.questionId,
    required this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'value': value,
    };
  }
}
