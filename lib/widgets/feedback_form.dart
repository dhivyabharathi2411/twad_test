import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twad/extensions/translation_extensions.dart';
import '../../constants/app_constants.dart';
import '../presentation/providers/feedback_provider.dart';

class FeedbackForm extends StatefulWidget {
  final int grievanceId;
  final bool isReopened;

  const FeedbackForm({
    super.key,
    required this.grievanceId,
    this.isReopened = false,
  });

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final Map<int, TextEditingController> _commentControllers = {};

  @override
  void dispose() {
    for (final controller in _commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<FeedbackProvider>(context, listen: false);
      provider.setCurrentGrievanceId(widget.grievanceId);
      if (widget.isReopened) {
        await provider.clearFeedbackForReopenedGrievance(widget.grievanceId);
        return; 
      }
      await provider.getFeedback(widget.grievanceId);
      for (var feedback in provider.existingFeedback) {
        final questionId = feedback['question_id'];
        if (questionId != null) {
          if (questionId == 0) {
            final comment = feedback['comments']?.toString() ?? '';
            if (comment.trim().isNotEmpty) {
              provider.setCommentAnswer(questionId, comment);
            }
          } else {
            final value = feedback['value'] ?? 0;
            provider.setRatingAnswer(questionId, value);
          }
        }
      }

      if (provider.submittedFeedback.isNotEmpty) {
        final actuallySubmitted = provider.submittedFeedback
            .where((f) => (f['question_id'] ?? 0) != 0)
            .any((f) {
              final value = f['value'] ?? 0;
              return value != 0;
            });
        if (actuallySubmitted) {
          provider.markFeedbackAsSubmitted();
          provider.setSubmittedRatings(provider.submittedFeedback);
        }
      } else {
        final allZero = provider.questions.every(
          (q) => (provider.ratingAnswers[q['question_id']] ?? 0) == 0,
        );
        if (allZero && !provider.feedbackSubmitted) {
          Future.delayed(Duration(milliseconds: 100), () {
            if (mounted) {
              _submit(context);
            }
          });
        }
      }
    });
  }

  void _submit(BuildContext context) async {
    final provider = Provider.of<FeedbackProvider>(context, listen: false);

    provider.setCurrentGrievanceId(widget.grievanceId);
    final feedbackList = <Map<String, dynamic>>[];

    for (var feedback in provider.newFeedback) {
      final questionId = feedback['question_id'];
      if (questionId != null) {
        if (questionId == 0) {
          final comment = provider.commentAnswers[questionId] ?? '';
          final feedbackItem = <String, dynamic>{
            'question_id': questionId,
            'value': 0, 
          };

          if (comment.trim().isNotEmpty) {
            feedbackItem['comments'] = comment;
          }

          feedbackList.add(feedbackItem);
        } else {
          final rating = provider.ratingAnswers[questionId] ?? 0;
          feedbackList.add({'question_id': questionId, 'value': rating});
        }
      }
    }

    final payload = {
      'grievance_id': widget.grievanceId.toString(),
      'feedback_list': feedbackList,
    };

    for (int i = 0; i < feedbackList.length; i++) {
    }

    if (!provider.areAllRatingQuestionsAnswered()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please provide at least one star rating for all questions.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    if (!provider.isValidForSubmission()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please provide at least one rating or comment before submitting.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    await provider.submitFeedback(payload);

    if (provider.submitSuccessMessage != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.submitSuccessMessage!),
          backgroundColor: AppConstants.accentColor,
        ),
      );

      provider.resetFeedbackState();
    } else if (provider.submitError != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.submitError!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _update(BuildContext context) async {
    final provider = Provider.of<FeedbackProvider>(context, listen: false);
    provider.setCurrentGrievanceId(widget.grievanceId);
    final feedbackList = <Map<String, dynamic>>[];

    for (var feedback in provider.existingFeedback) {
      final questionId = feedback['question_id'];
      if (questionId != null) {
        if (questionId == 0) {
          final comment = provider.commentAnswers[questionId] ?? '';
          final feedbackItem = <String, dynamic>{
            'question_id': questionId,
            'value': 0, 
          };
          if (comment.trim().isNotEmpty) {
            feedbackItem['comments'] = comment;
          }

          feedbackList.add(feedbackItem);
        } else {
          final existingValue = feedback['value'] ?? 0;
          final newRating = provider.ratingAnswers[questionId] ?? 0;
          final finalRating = newRating > 0 ? newRating : existingValue;
          feedbackList.add({'question_id': questionId, 'value': finalRating});
        }
      }
    }

    final payload = {
      'grievance_id': widget.grievanceId.toString(),
      'feedback_list': feedbackList,
    };
    for (int i = 0; i < feedbackList.length; i++) {
    }

    if (!provider.areAllRatingQuestionsAnswered()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please provide at least one star rating for all questions.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (!provider.isValidForSubmission()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please provide at least one rating or comment before submitting.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    await provider.updateFeedback(payload);

    if (provider.updateSuccessMessage != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.updateSuccessMessage!),
          backgroundColor: AppConstants.accentColor,
        ),
      );
    } else if (provider.updateError != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.submitError!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedbackProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingQuestions) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.questionError != null) {
          return Center(child: Text(provider.questionError!));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${context.tr.submitButton} ${context.tr.feedback}",
                style: AppConstants.titleStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ...provider.existingFeedback.map((q) {
                final questionId = q['question_id'];
                final questionText = q['question'] ?? '';
                final value = q['value'] ?? 0;
                final comment = q['comments'] ?? '';
                final flag = (q['flag'] ?? '').toString().toLowerCase();
                final isEditable =
                    flag == 'exists' ||
                    (q['editable'] ?? false) ||
                    widget.isReopened;

                if (questionId == 0) {
                  final initialText = isEditable
                      ? (provider.commentAnswers[questionId] ?? comment)
                      : comment;

                  if (!_commentControllers.containsKey(questionId)) {
                    _commentControllers[questionId] = TextEditingController(
                      text: initialText,
                    );
                  } else {
                    if (_commentControllers[questionId]!.text != initialText) {
                      _commentControllers[questionId]!.text = initialText;
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr.comments,
                        style: TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _commentControllers[questionId],
                        enabled: isEditable,
                        onChanged: isEditable
                            ? (val) =>
                                  provider.setCommentAnswer(questionId, val)
                            : null,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: context.tr.entercomments,
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr.translate(questionText),
                      style: AppConstants.bodyTextStyle,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (i) {
                        final rating = i + 1;
                        if (isEditable) {
                          final existingRating =
                              provider.ratingAnswers[questionId] ??
                              q['value'] ??
                              0;
                          return IconButton(
                            onPressed: isEditable
                                ? () {
                                    provider.setRatingAnswer(
                                      questionId,
                                      rating,
                                    );
                                  }
                                : null,
                            icon: Icon(
                              rating <= existingRating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                            ),
                          );
                        } else {
                          return Icon(
                            rating <= value ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          );
                        }
                      }),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }),
              ...provider.newFeedback.map((q) {
                final questionId = q['question_id'];
                final questionText = q['question'] ?? '';

                if (questionId == 0) {
                  if (!_commentControllers.containsKey(questionId)) {
                    _commentControllers[questionId] = TextEditingController(
                      text: provider.commentAnswers[questionId] ?? '',
                    );
                  } else {
                    final current = provider.commentAnswers[questionId] ?? '';
                    if (_commentControllers[questionId]!.text != current) {
                      _commentControllers[questionId]!.text = current;
                    }
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr.translate(questionText),
                        style: AppConstants.bodyTextStyle,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _commentControllers[questionId],
                        enabled: !provider.feedbackSubmitted,
                        onChanged: (val) =>
                            provider.setCommentAnswer(questionId, val),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: context.tr.entercomments,
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr.translate(questionText),
                      style: AppConstants.bodyTextStyle,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (i) {
                        final rating = i + 1;
                        return IconButton(
                          onPressed: provider.feedbackSubmitted
                              ? null
                              : () {
                                  provider.setRatingAnswer(questionId, rating);
                                },
                          icon: Icon(
                            rating <= (provider.ratingAnswers[questionId] ?? 0)
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }),

              const SizedBox(height: 20),

              if ((() {
                final notSubmitted = !provider.feedbackSubmitted;
                final hasNewFeedback = provider.newFeedback.isNotEmpty;
                final hasExistingFeedback = provider.existingFeedback.any(
                  (f) {
                    final flag = (f['flag'] ?? '').toString().toLowerCase();
                    return flag == 'exists' || (f['editable'] ?? false);
                  },
                );
                
                final showButton = (notSubmitted && (hasNewFeedback || hasExistingFeedback)) || hasExistingFeedback;
                return showButton;
              })())
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        (provider.isSubmitting ||
                            !provider.isValidForSubmission())
                        ? () {
            
                          }
                        : (provider.existingFeedback.any((f) {
                                final flag = (f['flag'] ?? '')
                                    .toString()
                                    .toLowerCase();
                                return flag == 'exists' ||
                                    (f['editable'] ?? false);
                              })
                              ? () => _update(context)
                              : () => _submit(context)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: provider.areAllRatingQuestionsAnswered()
                          ? AppConstants.primaryColor
                          : Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                      ),
                    ),
                    child: provider.isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            provider.existingFeedback.any(
                                  (f) =>
                                      (f['flag'] ?? '')
                                          .toString()
                                          .toLowerCase() ==
                                      'exists',
                                )
                                ? "${context.tr.save} ${context.tr.feedback}"
                                : "${context.tr.submitButton} ${context.tr.feedback}",
                            style: AppConstants.buttonTextStyle.copyWith(
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
