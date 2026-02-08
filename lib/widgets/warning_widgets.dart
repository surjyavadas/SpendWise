import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/warning_service.dart';

/// Widget to display budget warnings
class WarningCard extends StatelessWidget {
  final WarningLevel warning;
  final VoidCallback onDismiss;

  const WarningCard({
    super.key,
    required this.warning,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Calm, subtle color - advisory not alarming
    final backgroundColor = Color.lerp(
      warning.isCritical ? AppColors.error : AppColors.warning,
      Colors.transparent,
      0.92, // Very high transparency for calm appearance
    ) ?? AppColors.error;

    final textColor = warning.isCritical ? AppColors.error : AppColors.warning;
    final iconColor = warning.isCritical ? AppColors.error : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark 
            ? (warning.isCritical 
                ? AppColors.darkError.withOpacity(0.1)
                : AppColors.darkWarning.withOpacity(0.1))
            : backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? (warning.isCritical 
                  ? AppColors.darkError.withOpacity(0.3)
                  : AppColors.darkWarning.withOpacity(0.3))
              : textColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                warning.isCritical ? Icons.info_rounded : Icons.lightbulb_rounded,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      warning.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkText : AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      warning.message,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.darkGray,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Progress bar (calm, not alarming)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: warning.percentage / 100,
                        minHeight: 3,
                        backgroundColor: Colors.black.withOpacity(0.08),
                        valueColor: AlwaysStoppedAnimation(
                          textColor.withOpacity(0.6), // Muted color
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onDismiss,
                icon: Icon(Icons.close, size: 18, color: iconColor.withOpacity(0.6)),
                splashRadius: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget to display contextual spending tips
class TipCard extends StatelessWidget {
  final String tip;
  final VoidCallback onDismiss;

  const TipCard({
    super.key,
    required this.tip,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 12, left: 16, right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.primaryLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColors.darkSurfaceVariant
              : AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outlined,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkText : AppColors.darkGray,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.close, size: 16),
            splashRadius: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}
