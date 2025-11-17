import 'package:flutter/material.dart';
import 'package:twad/constants/app_constants.dart';
import 'package:twad/extensions/translation_extensions.dart';
import 'package:twad/pages/dashboard/statuschip.dart';
import 'package:twad/utils/app_utils.dart';
import 'package:twad/widgets/common_widgets.dart';

import '../../data/models/grievance_model.dart';

class GrievanceCard extends StatelessWidget {
  final GrievanceModel grievance;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;
  final VoidCallback? onWhatsApp;
  final bool isDownloadProcessing;

  const GrievanceCard({
    super.key,
    required this.grievance,
    this.onTap,
    this.onDownload,
    this.onWhatsApp,
    this.isDownloadProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    return TWADCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with complaint number and status
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {},
                  child: ShaderMask(
                    shaderCallback: (bounds) =>
                        LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFF3B82F6)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ).createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        ),
                    child: Text(
                      grievance.complaintNo,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                StatusChip(
                  status: grievance.complaintStatus,
                  grievanceId: grievance.id,
                ),
              ],
            ),
          ),

          // Title and description
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr.translate(grievance.complaintSubType),
                  style: AppConstants.titleStyle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppConstants.textSecondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          context.tr.translate(grievance.districtName),
                          style: AppConstants.bodyTextStyle.copyWith(
                            fontSize: 12,
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppConstants.cardBorderRadius),
                bottomRight: Radius.circular(AppConstants.cardBorderRadius),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppUtils.formatDate(grievance.complaintDateTime),
                    style: AppConstants.bodyTextStyle.copyWith(
                      fontSize: 12,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                ),
                Row(
                  children: [
                    // View icon
                    IconButton(
                      onPressed: onWhatsApp,
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppConstants.detailIconBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.remove_red_eye,
                          color: AppConstants.detailIconGreen,
                          size: 20,
                        ),
                      ),
                      iconSize: 32,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),

                    // Download icon
                    IconButton(
                      onPressed: isDownloadProcessing ? null : onDownload,
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDownloadProcessing
                              ? Colors.grey
                              : AppConstants.acknowledgementIconBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: isDownloadProcessing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.download,
                                color: AppConstants.acknowledgementIconRed,
                                size: 20,
                              ),
                      ),
                      iconSize: 32,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
