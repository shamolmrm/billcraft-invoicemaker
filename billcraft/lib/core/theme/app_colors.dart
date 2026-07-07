import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF00897B);
  static const Color primaryLight = Color(0xFF26A69A);
  static const Color primaryDark = Color(0xFF00695C);
  static const Color primaryContainer = Color(0xFFE0F2F1);
  static const Color accent = Color(0xFF1DE9B6);

  static const Color paid = Color(0xFF2E7D32);
  static const Color paidBg = Color(0xFFE8F5E9);
  static const Color unpaid = Color(0xFF1565C0);
  static const Color unpaidBg = Color(0xFFE3F2FD);
  static const Color partiallyPaid = Color(0xFFE65100);
  static const Color partiallyPaidBg = Color(0xFFFFF3E0);
  static const Color overdue = Color(0xFFC62828);
  static const Color overdueBg = Color(0xFFFFEBEE);
  static const Color draft = Color(0xFF546E7A);
  static const Color draftBg = Color(0xFFECEFF1);

  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F4F8);
  static const Color border = Color(0xFFE2E8F0);

  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textTertiary = Color(0xFF718096);
  static const Color textHint = Color(0xFFA0AEC0);

  static const Color darkBackground = Color(0xFF0F1923);
  static const Color darkSurface = Color(0xFF1A2535);
  static const Color darkSurfaceVariant = Color(0xFF243040);
  static const Color darkBorder = Color(0xFF2D3748);
  static const Color darkText = Color(0xFFF7FAFC);
  static const Color darkTextSecondary = Color(0xFFA0AEC0);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00897B), Color(0xFF26A69A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF00695C), Color(0xFF00897B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF00897B), Color(0xFF1DE9B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFF57C00);
  static const Color success = Color(0xFF388E3C);
  static const Color info = Color(0xFF1976D2);
}
