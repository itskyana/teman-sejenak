import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Badge/Pill widget for tags, status, etc.
class AppBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final Color? textColor;
  final Color? backgroundColor;
  final EdgeInsets padding;
  final double borderRadius;
  final IconData? icon;
  final double? iconSize;

  const AppBadge({
    super.key,
    required this.text,
    this.color,
    this.textColor,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    this.borderRadius = 12,
    this.icon,
    this.iconSize,
  });

  // Named constructors for common badge types
  factory AppBadge.primary(String text, {IconData? icon}) => AppBadge(
        text: text,
        color: AppColors.primary,
        icon: icon,
      );

  factory AppBadge.success(String text, {IconData? icon}) => AppBadge(
        text: text,
        color: AppColors.success,
        icon: icon,
      );

  factory AppBadge.warning(String text, {IconData? icon}) => AppBadge(
        text: text,
        color: AppColors.warning,
        icon: icon,
      );

  factory AppBadge.danger(String text, {IconData? icon}) => AppBadge(
        text: text,
        color: AppColors.danger,
        icon: icon,
      );

  factory AppBadge.info(String text, {IconData? icon}) => AppBadge(
        text: text,
        color: AppColors.info,
        icon: icon,
      );

  factory AppBadge.verified({String text = 'Verified'}) => AppBadge(
        text: text,
        color: AppColors.info,
        icon: Icons.verified_rounded,
        iconSize: 12,
      );

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? AppColors.primary;
    final bgColor = backgroundColor ?? baseColor.withOpacity(0.1);
    final txtColor = textColor ?? baseColor;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize ?? 14, color: txtColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(
              color: txtColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status badge with predefined styles
class StatusBadge extends StatelessWidget {
  final String status;
  final Map<String, BadgeStyle>? customStyles;

  const StatusBadge({
    super.key,
    required this.status,
    this.customStyles,
  });

  @override
  Widget build(BuildContext context) {
    final style = _getStyle();
    return AppBadge(
      text: style.label,
      color: style.color,
      icon: style.icon,
    );
  }

  BadgeStyle _getStyle() {
    // Check custom styles first
    if (customStyles != null && customStyles!.containsKey(status)) {
      return customStyles![status]!;
    }

    // Default styles
    switch (status.toLowerCase()) {
      case 'pending':
      case 'menunggu':
        return BadgeStyle(
          label: 'Menunggu',
          color: AppColors.warning,
          icon: Icons.schedule_rounded,
        );
      case 'approved':
      case 'disetujui':
        return BadgeStyle(
          label: 'Disetujui',
          color: AppColors.info,
          icon: Icons.check_circle_outline_rounded,
        );
      case 'inprogress':
      case 'in_progress':
      case 'berlangsung':
        return BadgeStyle(
          label: 'Berlangsung',
          color: AppColors.primary,
          icon: Icons.directions_walk_rounded,
        );
      case 'completed':
      case 'selesai':
        return BadgeStyle(
          label: 'Selesai',
          color: AppColors.success,
          icon: Icons.check_circle_rounded,
        );
      case 'canceled':
      case 'cancelled':
      case 'dibatalkan':
        return BadgeStyle(
          label: 'Dibatalkan',
          color: AppColors.danger,
          icon: Icons.cancel_rounded,
        );
      default:
        return BadgeStyle(
          label: status,
          color: AppColors.gray600,
        );
    }
  }
}

/// Style configuration for badges
class BadgeStyle {
  final String label;
  final Color color;
  final IconData? icon;

  BadgeStyle({
    required this.label,
    required this.color,
    this.icon,
  });
}
