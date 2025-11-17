import 'package:flutter/material.dart';
import '../../services/feedback_service.dart';

class FeedbackProvider extends ChangeNotifier {
  
  List<Map<String, dynamic>> get existingFeedback => _submittedFeedback
      .where((f) => (f['flag'] ?? '').toString().toLowerCase() == 'exists')
      .toList();
  List<Map<String, dynamic>> get newFeedback => _submittedFeedback
      .where((f) => (f['flag'] ?? '').toString().toLowerCase() == 'new')
      .toList();

  final FeedbackService _feedbackService = FeedbackService();

  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> get questions => _questions;

  List<Map<String, dynamic>> _submittedFeedback = [];
  List<Map<String, dynamic>> get submittedFeedback => _submittedFeedback;
  final Map<int, Map<int, int>> _ratingAnswersByGrievance = {};
  final Map<int, Map<int, String>> _commentAnswersByGrievance = {};
  final Map<int, bool> _feedbackSubmittedByGrievance = {};

  int? _currentGrievanceId;
  Map<int, int> get ratingAnswers =>
      _ratingAnswersByGrievance[_currentGrievanceId] ?? {};
  Map<int, String> get commentAnswers =>
      _commentAnswersByGrievance[_currentGrievanceId] ?? {};
  bool get feedbackSubmitted =>
      _feedbackSubmittedByGrievance[_currentGrievanceId] ?? false;

  void setCurrentGrievanceId(int grievanceId) {
    _currentGrievanceId = grievanceId;
    _ratingAnswersByGrievance.putIfAbsent(grievanceId, () => {});
    _commentAnswersByGrievance.putIfAbsent(grievanceId, () => {});
    _feedbackSubmittedByGrievance.putIfAbsent(grievanceId, () => false);
  }

  bool isLoadingQuestions = false;
  bool isSubmitting = false;
  String? questionError;
  String? submitSuccessMessage;
  String? submitError;

  bool isUpdating = false;
  String? updateSuccessMessage;
  String? updateError;
  void setHardcodedQuestions(List<Map<String, dynamic>> data) {
    _questions = data;
    notifyListeners();
  }

  void setRatingAnswer(int questionId, int value) {
    if (_currentGrievanceId != null) {
      _ratingAnswersByGrievance[_currentGrievanceId!]![questionId] = value;
      notifyListeners();
    }
  }

  void setCommentAnswer(int questionId, String value) {
    if (_currentGrievanceId != null) {
      _commentAnswersByGrievance[_currentGrievanceId!]![questionId] = value;
      notifyListeners();
    }
  }

  void setSubmittedRatings(List<Map<String, dynamic>> feedback) {
    if (_currentGrievanceId == null) return;

    final currentRatings = _ratingAnswersByGrievance[_currentGrievanceId!]!;
    final currentComments = _commentAnswersByGrievance[_currentGrievanceId!]!;

    for (var f in feedback) {
      final qid = f['question_id'];
      if (qid != null) {
        if (currentRatings.containsKey(qid)) {
          f['value'] = currentRatings[qid];
        } else if (currentComments.containsKey(qid)) {
          f['comments'] = currentComments[qid];
        }
      }
    }
    notifyListeners();
  }

  void updateFeedbackWithCurrentRatings() {
    if (_currentGrievanceId == null) return;

    final currentRatings = _ratingAnswersByGrievance[_currentGrievanceId!]!;
    final currentComments = _commentAnswersByGrievance[_currentGrievanceId!]!;

    for (var feedback in _submittedFeedback) {
      final questionId = feedback['question_id'];
      if (questionId != null) {
        if (currentRatings.containsKey(questionId)) {
          feedback['value'] = currentRatings[questionId];
        } else if (currentComments.containsKey(questionId)) {
          feedback['comments'] = currentComments[questionId];
        }
      }
    }
    notifyListeners();
  }

  void markFeedbackAsSubmitted() {
    if (_currentGrievanceId != null) {
      _feedbackSubmittedByGrievance[_currentGrievanceId!] = true;
    }

    for (var feedback in _submittedFeedback) {
      if ((feedback['flag'] ?? '').toString().toLowerCase() == 'new') {
        feedback['flag'] = 'exists';
      }
    }
    notifyListeners();
  }

  void setSubmittedFeedback(List<Map<String, dynamic>> feedback) {
    _submittedFeedback = feedback;
    notifyListeners();
  }

  Future<void> getFeedback(int grievanceId) async {
    setCurrentGrievanceId(grievanceId);

    isLoadingQuestions = true;
    questionError = null;
    notifyListeners();

    try {
      final response = await _feedbackService.getFeedbackQuestions(grievanceId);

      if (response['success']) {
        final List<dynamic> feedbackList = response['data'] ?? [];
        _submittedFeedback = List<Map<String, dynamic>>.from(feedbackList);
        final currentRatings = _ratingAnswersByGrievance[grievanceId]!;
        final currentComments = _commentAnswersByGrievance[grievanceId]!;
        for (var feedback in _submittedFeedback) {
          final questionId =  (feedback['question_ID']);

          final flag = (feedback['flag'] ?? '').toString().toLowerCase();

          if (questionId != null && flag == 'new') {
            if (questionId == 0) {
              if (!currentComments.containsKey(questionId)) {
                currentComments[questionId] = feedback['comments'] ?? '';
              }
            } else {
              if (!currentRatings.containsKey(questionId)) {
                currentRatings[questionId] = feedback['value'] ?? 0;
              }
            }
          }
        }
      } else {
        questionError = response['message'];
        _submittedFeedback = [];
      }
    } catch (e) {
      questionError = e.toString();
      _submittedFeedback = [];
    }

    isLoadingQuestions = false;
    notifyListeners();
  }

  Future<void> submitFeedback(Map<String, dynamic> payload) async {
    if (_currentGrievanceId == null) {
      submitError = 'No grievance context set';
      notifyListeners();
      return;
    }

    isSubmitting = true;
    submitSuccessMessage = null;
    submitError = null;
    notifyListeners();

    try {;
      final response = await _feedbackService.submitFeedback(payload);
      if (response['success']) {
        submitSuccessMessage = response['message'];
        _feedbackSubmittedByGrievance[_currentGrievanceId!] = true;
        for (var feedback in _submittedFeedback) {
          if ((feedback['flag'] ?? '').toString().toLowerCase() == 'new') {
            feedback['flag'] = 'exists';
            final questionId = feedback['question_id'];
            if (questionId != null) {
              final currentRatings =
                  _ratingAnswersByGrievance[_currentGrievanceId!]!;
              final currentComments =
                  _commentAnswersByGrievance[_currentGrievanceId!]!;

              if (questionId == 0) {
                feedback['comments'] = currentComments[questionId] ?? '';
              } else {
                feedback['value'] = currentRatings[questionId] ?? 0;
              }
            }
          }
        }
      } else {
        submitError = response['message'];
      }
    } catch (e) {
      submitError = e.toString();
    }

    isSubmitting = false;
    notifyListeners();
  }

  Future<void> updateFeedback(Map<String, dynamic> payload) async {
    if (_currentGrievanceId == null) {
      submitError = 'No grievance context set';
      notifyListeners();
      return;
    }

    isUpdating = true;
    updateSuccessMessage = null;
    updateError = null;
    notifyListeners();

    try {
      final response = await _feedbackService.updateFeedback(payload);
      if (response['success']) {
        updateSuccessMessage = response['message'];
        _feedbackSubmittedByGrievance[_currentGrievanceId!] = true;
        for (var feedback in _submittedFeedback) {
          if ((feedback['flag'] ?? '').toString().toLowerCase() == 'new') {
            feedback['flag'] = 'exists';
            final questionId = feedback['question_id'];
            if (questionId != null) {
              final currentRatings =
                  _ratingAnswersByGrievance[_currentGrievanceId!]!;
              final currentComments =
                  _commentAnswersByGrievance[_currentGrievanceId!]!;

              if (questionId == 0) {
                feedback['comments'] = currentComments[questionId] ?? '';
              } else {
                feedback['value'] = currentRatings[questionId] ?? 0;
              }
            }
          }
        }
      } else {
        submitError = response['message'];
      }
    } catch (e) {
      submitError = e.toString();
    }

    isSubmitting = false;
    notifyListeners();
  }

  void resetFeedbackState() {
    submitSuccessMessage = null;
    submitError = null;
    notifyListeners();
  }
  bool isValidForSubmission() {
    if (_currentGrievanceId == null) return false;
    if (!areAllRatingQuestionsAnswered()) return false;
    final currentComments =
        _commentAnswersByGrievance[_currentGrievanceId!] ?? {};
    final comment = currentComments[0];
  
    if (comment != null && comment.trim().isNotEmpty) {
      return true;
    }
  
    for (var feedback in _submittedFeedback) {
      final questionId = feedback['question_id'];
      if (questionId == 0) {
        final existingComment = feedback['comments']?.toString() ?? '';
        if (existingComment.trim().isNotEmpty) {
          return true;
        }
      }
    }
    
    return false;
  }
  bool areAllRatingQuestionsAnswered() {
    if (_currentGrievanceId == null) return false;

    final currentRatings =
        _ratingAnswersByGrievance[_currentGrievanceId!] ?? {};
    final ratingQuestions = newFeedback.where((q) => q['question_id'] != 0);
    for (var question in ratingQuestions) {
      final questionId = question['question_id'];
      final rating = currentRatings[questionId] ?? 0;
      if (rating < 1) {
        return false;
      }
    }

    return true; 
  }

  Map<String, dynamic> getCurrentFeedbackSummary() {
    if (_currentGrievanceId == null) return {};

    return {
      'grievanceId': _currentGrievanceId,
      'ratings': _ratingAnswersByGrievance[_currentGrievanceId!] ?? {},
      'comments': _commentAnswersByGrievance[_currentGrievanceId!] ?? {},
      'submitted': _feedbackSubmittedByGrievance[_currentGrievanceId!] ?? false,
      'newFeedbackCount': newFeedback.length,
      'existingFeedbackCount': existingFeedback.length,
    };
  }

  Future<void> clearFeedbackForReopenedGrievance(int grievanceId) async {
    setCurrentGrievanceId(grievanceId);
    _ratingAnswersByGrievance[grievanceId]?.clear();
    _commentAnswersByGrievance[grievanceId]?.clear();
    _feedbackSubmittedByGrievance[grievanceId] = false;

    _submittedFeedback.clear();
    submitSuccessMessage = null;
    submitError = null;

    await getFeedback(grievanceId);;
  }
}
