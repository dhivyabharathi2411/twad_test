import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

class GrievanceDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;

  const GrievanceDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: AppConstants.bodyTextStyle.copyWith(
              fontWeight: FontWeight.w500,
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: isHighlighted
              ? ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF3B82F6)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                  child: Text(
                    value,
                    style: AppConstants.bodyTextStyle.copyWith(
                      color: Colors.white, // this color is overridden by shader
                      fontWeight: FontWeight.w600,
                    ),
                   
                  ),
                )
              : Text(
                  value,
                  style: AppConstants.bodyTextStyle.copyWith(
                    color: AppConstants.textPrimaryColor,
                    fontWeight: FontWeight.normal,
                  ),
                 
                ),
        ),

      ],
    );
  }
}
