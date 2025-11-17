import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../data/models/grievance_status.dart';
import 'twad_logo.dart';

/// Custom app bar widget for TWAD application
/// Provides consistent header styling across the app
class TWADAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showLogo;
  final bool showBackButton;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const TWADAppBar({
    super.key,
    this.title,
    this.showLogo = true,
    this.showBackButton = false,
    this.actions,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppConstants.cardColor,
      foregroundColor: foregroundColor ?? AppConstants.textPrimaryColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: showBackButton
          ? IconButton(
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios),
            )
          : null,
      title: showLogo
          ? Row(
              children: [
                const TWADLogo(size: 40, showBorder: false),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title ?? 'TWAD',
                        style: AppConstants.titleStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (title == null)
                        Text(
                          'Tamil Nadu Water Supply and Drainage Board',
                          style: AppConstants.bodyTextStyle.copyWith(
                            fontSize: 8,
                            color: AppConstants.textSecondaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            )
          : Text(
              title ?? '',
              style: AppConstants.titleStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: Colors.grey[200], height: 1),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}

/// Loading widget for TWAD application
class TWADLoadingWidget extends StatelessWidget {
  final String? message;
  final double size;

  const TWADLoadingWidget({super.key, this.message, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppConstants.primaryColor,
              ),
              strokeWidth: 3,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppConstants.bodyTextStyle.copyWith(
                color: AppConstants.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Empty state widget for TWAD application
class TWADEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const TWADEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppConstants.titleStyle.copyWith(
                fontSize: 18,
                color: AppConstants.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppConstants.bodyTextStyle.copyWith(
                  color: AppConstants.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}

/// Custom card widget for TWAD application
class TWADCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? borderRadius;
  final VoidCallback? onTap;
  final bool showShadow;

  const TWADCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.onTap,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppConstants.cardPadding),
      decoration: BoxDecoration(
        color: color ?? AppConstants.cardColor,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppConstants.cardBorderRadius,
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha((0.05 * 255).toInt()),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }

    return card;
  }
}

/// Info row widget for displaying key-value pairs
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final bool isVertical;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isVertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: iconColor ?? AppConstants.textSecondaryColor,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: AppConstants.bodyTextStyle.copyWith(
                  fontSize: 12,
                  color: AppConstants.textSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppConstants.bodyTextStyle.copyWith(
              fontSize: 14,
              color: AppConstants.textPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 16,
            color: iconColor ?? AppConstants.textSecondaryColor,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          '$label: ',
          style: AppConstants.bodyTextStyle.copyWith(
            fontSize: 14,
            color: AppConstants.textSecondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppConstants.bodyTextStyle.copyWith(
              fontSize: 14,
              color: AppConstants.textPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

/// Status chip widget for grievances
class TWADStatusChip extends StatelessWidget {
  final GrievanceStatus status;
  final double? fontSize;

  const TWADStatusChip({super.key, required this.status, this.fontSize = 10});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor = Colors.white;
    String text;

    switch (status) {
      case GrievanceStatus.submitted:
        backgroundColor = AppConstants.primaryColor;
        text = 'Submitted';
        break;
      case GrievanceStatus.acknowledged:
        backgroundColor = Colors.blue;
        text = 'Acknowledged';
        break;
      case GrievanceStatus.inProgress:
        backgroundColor = AppConstants.accentColor;
        text = 'In Progress';
        break;
      case GrievanceStatus.resolved:
        backgroundColor = Colors.green;
        text = 'Resolved';
        break;
      case GrievanceStatus.closed:
        backgroundColor = AppConstants.errorColor;
        text = 'Closed';
        break;
      case GrievanceStatus.rejected:
        backgroundColor = Colors.red;
        text = 'Rejected';
        break;
      case GrievanceStatus.draft:
        backgroundColor = Colors.grey;
        text = 'Draft';
        break;
      case GrievanceStatus.processing:
        backgroundColor = Colors.yellow.shade700;
        text = 'Processing';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppConstants.bodyTextStyle.copyWith(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
