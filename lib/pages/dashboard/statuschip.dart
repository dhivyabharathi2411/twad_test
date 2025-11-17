import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twad/constants/app_constants.dart';
import 'package:twad/extensions/translation_extensions.dart';
import 'package:twad/presentation/providers/grievance_provider.dart';
import 'package:twad/main.dart';

import '../../data/models/grievance_status.dart';

class StatusChip extends StatelessWidget {
  final GrievanceStatus status;
  final int? grievanceId; 
  final VoidCallback? onTap; 
  final bool showReopenOption; 

  const StatusChip({
    super.key,
    required this.status,
    this.grievanceId,
    this.onTap,
    this.showReopenOption = false, 
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GrievanceProvider>(
      builder: (context, grievanceProvider, child) {
        final isReopening = grievanceProvider.isReopening;
        final recentCount = grievanceProvider.recentGrievances?.length ?? 0;
        GrievanceStatus currentStatus = status;
        if (grievanceId != null) {
          try {
            final recentGrievance = grievanceProvider.recentGrievances
                ?.firstWhere((g) => g.id == grievanceId);
            if (recentGrievance != null) {
              currentStatus = recentGrievance.status;
            }
          } catch (e) {}
        }
        return Container(
          key: ValueKey(
            'status_chip_${grievanceId}_${currentStatus}_${isReopening}_${recentCount}_${grievanceProvider.lastUpdateTimestamp}',
          ),
          child: _buildStatusChip(context, currentStatus),
        );
      },
    );
  }

  Widget _buildStatusChip(BuildContext context, GrievanceStatus status) {
    Color backgroundColor;
    Color textColor = Colors.white;
    String text;
    bool isClickable = false;

    switch (status) {
      case GrievanceStatus.submitted:
        backgroundColor = AppConstants.primaryColor;
        text = context.tr.submittedStatus;

        break;
      case GrievanceStatus.acknowledged:
        backgroundColor = Colors.blue;
        text = 'Acknowledged';

        break;
      case GrievanceStatus.inProgress:
        backgroundColor = AppConstants.accentColor;
        text = context.tr.inProgress;

        break;
      case GrievanceStatus.resolved:
        backgroundColor = Colors.green;
        text = context.tr.resolved;

        break;
      case GrievanceStatus.closed:
        backgroundColor = showReopenOption
            ? Colors.green
            : Colors.red;
        text = showReopenOption
            ? context.tr.open
            : context.tr.closed; 
        isClickable =
            showReopenOption; 

        break;
      case GrievanceStatus.rejected:
        backgroundColor = Colors.red;
        text = context.tr.rejected;

        break;
      case GrievanceStatus.draft:
        backgroundColor = Colors.grey;
        text = context.tr.draft;

        break;
      case GrievanceStatus.processing:
        backgroundColor = Colors.yellow.shade700;
        text = context.tr.processing;

        break;
    }

    return GestureDetector(
      onTap: isClickable ? () => _showOpenPopup(context) : null,
      child: MouseRegion(
        cursor: isClickable
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isClickable
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
            border: isClickable
                ? Border.all(color: Colors.white.withOpacity(0.3), width: 1)
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: AppConstants.bodyTextStyle.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              if (isClickable) ...[
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 8, color: textColor),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showOpenPopup(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.lock_open, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              Text(
                context.tr.openGrievance,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr.openGrievanceReason,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: context.tr.openGrievanceHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                context.tr.cancel,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final reason = reasonController.text.trim();
                if (reason.isNotEmpty) {
                  if (grievanceId != null) {
                    try {
                      final grievanceProvider = Provider.of<GrievanceProvider>(
                        context,
                        listen: false,
                      );
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Row(
                              children: [
                                CircularProgressIndicator(),
                                const SizedBox(width: 16),
                                Flexible(
                                  fit: FlexFit.loose,
                                  child: Text(
                                    context.tr.reopeningGrievance,
                                    maxLines: 2,
                                    overflow: TextOverflow.visible,
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );

                      await grievanceProvider.reopenGrievance(
                        grievanceId!,
                        reason,
                      );
                      try {
                        if (navigatorKey.currentState != null &&
                            navigatorKey.currentState!.canPop()) {
                          navigatorKey.currentState!.pop();
                        } else {
                        }
                      } catch (navError) {
                      }

                      if (grievanceProvider.reopenSuccessMessage != null) {
                        grievanceProvider.updateGrievanceStatus(
                          grievanceId!,
                          GrievanceStatus.processing,
                        );
                        try {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      grievanceProvider.reopenSuccessMessage!,
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        } catch (snackError) {
                        }
                        try {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        } catch (popError) {
                        }
                      
                        grievanceProvider.resetReopenState();
                      } else if (grievanceProvider.reopenError != null) {
                        final globalContext = navigatorKey.currentContext;
                        if (globalContext != null) {
                          ScaffoldMessenger.of(globalContext).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.error, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(grievanceProvider.reopenError!),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                        grievanceProvider.resetReopenState();
                      } else {
                        grievanceProvider.resetReopenState();
                      }
                    } catch (e) {
                      try {
                        if (navigatorKey.currentState != null &&
                            navigatorKey.currentState!.canPop()) {
                          navigatorKey.currentState!.pop();
                        }
                      } catch (navError) {
                      }
                      try {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.error, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text('Error: $e'),
                                ],
                              ),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      } catch (snackError) {}

                      try {
                        final grievanceProvider =
                            Provider.of<GrievanceProvider>(
                              context,
                              listen: false,
                            );
                        grievanceProvider.resetReopenState();
                      } catch (providerError) {}
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.error, color: Colors.white),
                            const SizedBox(width: 8),
                            Text('Grievance ID not found'),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.error, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(context.tr.openGrievanceError),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(context.tr.submitButton),
            ),
          ],
        );
      },
    );
  }
}
