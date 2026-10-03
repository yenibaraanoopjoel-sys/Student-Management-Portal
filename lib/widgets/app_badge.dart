import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AppBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? textColor;
  final IconData? icon;

  const AppBadge({
    super.key,
    required this.text,
    this.color,
    this.textColor,
    this.icon,
  });

  factory AppBadge.status(String status) {
    Color bg;
    Color fg;
    switch (status.toLowerCase()) {
      case 'active':
      case 'present':
        bg = AppColors.successBg;
        fg = AppColors.success;
        break;
      case 'inactive':
      case 'absent':
        bg = AppColors.errorBg;
        fg = AppColors.error;
        break;
      case 'graduated':
        bg = AppColors.infoBg;
        fg = AppColors.info;
        break;
      default:
        bg = AppColors.surfaceMuted;
        fg = AppColors.textSecondary;
    }
    return AppBadge(text: status, color: bg, textColor: fg);
  }

  factory AppBadge.priority(String priority) {
    Color bg;
    Color fg;
    switch (priority.toLowerCase()) {
      case 'urgent':
      case 'high':
        bg = AppColors.errorBg;
        fg = AppColors.error;
        break;
      case 'medium':
        bg = AppColors.warningBg;
        fg = AppColors.warning;
        break;
      default:
        bg = AppColors.infoBg;
        fg = AppColors.info;
    }
    return AppBadge(text: priority, color: bg, textColor: fg);
  }

  factory AppBadge.grade(String grade) {
    Color bg;
    Color fg;
    switch (grade) {
      case 'O':
      case 'A+':
        bg = AppColors.successBg;
        fg = AppColors.success;
        break;
      case 'A':
      case 'B+':
        bg = AppColors.infoBg;
        fg = AppColors.info;
        break;
      case 'B':
      case 'C':
        bg = AppColors.warningBg;
        fg = AppColors.warning;
        break;
      default:
        bg = AppColors.errorBg;
        fg = AppColors.error;
    }
    return AppBadge(text: 'Grade $grade', color: bg, textColor: fg);
  }

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.surfaceMuted;
    final fg = textColor ?? AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
