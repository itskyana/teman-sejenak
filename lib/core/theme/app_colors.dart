import 'package:flutter/material.dart';

/// Application color palette
/// 
/// Usage: AppColors.primary, AppColors.success, etc.
class AppColors {
  AppColors._();

  // ══════════════════════════════════════════════════════════════
  // PRIMARY COLORS
  // ══════════════════════════════════════════════════════════════
  static const Color primary = Color(0xFF7B61FF);
  static const Color primaryDark = Color(0xFF5F47D1);
  static const Color primaryLight = Color(0xFFE5DEFF);

  // ══════════════════════════════════════════════════════════════
  // SECONDARY COLORS
  // ══════════════════════════════════════════════════════════════
  static const Color secondary = Color(0xFF6C757D);
  static const Color secondaryDark = Color(0xFF495057);
  static const Color secondaryLight = Color(0xFFE2E6EA);

  // ══════════════════════════════════════════════════════════════
  // SEMANTIC COLORS
  // ══════════════════════════════════════════════════════════════
  
  // Success
  static const Color success = Color(0xFF28A745);
  static const Color successDark = Color(0xFF1E7E34);
  static const Color successLight = Color(0xFFD4EDDA);

  // Warning
  static const Color warning = Color(0xFFFFC107);
  static const Color warningDark = Color(0xFF856404);
  static const Color warningLight = Color(0xFFFFF3CD);

  // Danger
  static const Color danger = Color(0xFFDC3545);
  static const Color dangerDark = Color(0xFFBD2130);
  static const Color dangerLight = Color(0xFFF8D7DA);

  // Info
  static const Color info = Color(0xFF17A2B8);
  static const Color infoDark = Color(0xFF117A8B);
  static const Color infoLight = Color(0xFFD1ECF1);

  // ══════════════════════════════════════════════════════════════
  // NEUTRAL / GRAY SCALE
  // ══════════════════════════════════════════════════════════════
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF8F9FA);
  static const Color gray200 = Color(0xFFE9ECEF);
  static const Color gray300 = Color(0xFFDEE2E6);
  static const Color gray400 = Color(0xFFCED4DA);
  static const Color gray500 = Color(0xFFADB5BD);
  static const Color gray600 = Color(0xFF6C757D);
  static const Color gray700 = Color(0xFF495057);
  static const Color gray800 = Color(0xFF343A40);
  static const Color gray900 = Color(0xFF212529);

  // ══════════════════════════════════════════════════════════════
  // SPECIAL PURPOSE
  // ══════════════════════════════════════════════════════════════
  static const Color background = Color(0xFFF5F3FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF3D2C8D);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color border = Color(0xFFE0DAFF);
  static const Color divider = Color(0xFFE9ECEF);
  static const Color shadow = Color(0x1A000000);

  // ══════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ══════════════════════════════════════════════════════════════
  
  /// Get color with opacity for badges/chips background
  static Color withBadgeOpacity(Color color) => color.withOpacity(0.1);
}
