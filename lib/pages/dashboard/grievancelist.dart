import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twad/constants/app_constants.dart';
import 'package:twad/pages/dashboard/statuschip.dart';
import 'package:twad/utils/app_utils.dart';
import 'package:twad/extensions/translation_extensions.dart';
import '../../presentation/providers/grievance_provider.dart';

class GrievanceListItem extends StatefulWidget {
  final int grievanceId;
  final VoidCallback? onTap;
  final void Function(int grievanceId)? onShowDetails;

  const GrievanceListItem({
    super.key,
    required this.grievanceId,
    this.onTap,
    this.onShowDetails,
  });

  @override
  State<GrievanceListItem> createState() => _GrievanceListItemState();
}

class _GrievanceListItemState extends State<GrievanceListItem> {
  @override
  Widget build(BuildContext context) {
    final grievanceProvider = Provider.of<GrievanceProvider>(context);

    final grievance = grievanceProvider.recentGrievances?.firstWhere(
      (g) => g.id == widget.grievanceId,
      orElse: () => throw Exception('Grievance not found'),
    );

    if (grievance == null) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date + Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppUtils.formatDate(grievance.complaintTime),
                    style: AppConstants.bodyTextStyle.copyWith(
                      fontSize: 12,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  StatusChip(
                    status: grievance.status,
                    grievanceId: grievance.id,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                context.tr.translate(grievance.title.trim()),
                style: AppConstants.titleStyle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),

              // Complaint No (Clickable - same as eye icon)
              Row(
                children: [
                  Text(
                    context.tr.grievanceCardComplaintno,
                    style: AppConstants.bodyTextStyle.copyWith(
                      fontSize: 12,
                      color: AppConstants.textPrimaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (widget.onShowDetails != null) {
                        widget.onShowDetails!(grievance.id);
                      }
                    },
                    child: ShaderMask(
                      shaderCallback: (bounds) =>
                          const LinearGradient(
                            colors: [Color(0xFF4F46E5), Color(0xFF3B82F6)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          ),
                      child: Text(
                        grievance.complaintNo,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
