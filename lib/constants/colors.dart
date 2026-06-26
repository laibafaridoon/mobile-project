import 'package:flutter/material.dart';

class AppColors {
  // Primary Teal Shades
  static const Color primary = Color(0xFF00695C); // Dark Teal
  static const Color primaryLight = Color(
    0xFFE0F2F1,
  ); // Light Teal background accent
  static const Color primaryDark = Color(0xFF004D40); // Deep Teal
  static const Color accent = Color(0xFF00BFA5); // Bright Teal accent
  // Neutral Colors
  static const Color background = Color(
    0xFFF5F8F8,
  ); // Very soft teal-grey background
  static const Color surface = Color(0xFFFFFFFF); // Pure white cards/containers
  static const Color textPrimary = Color(
    0xFF1E292B,
  ); // Near black teal-grey for readability
  static const Color textSecondary = Color(
    0xFF6B7E80,
  ); // Muted grey-teal for subtexts
  static const Color textLight = Color(
    0xFF9EAEB0,
  ); // Very light grey for details
  static const Color border = Color(0xFFE0ECEB); // Soft borders/dividers
  // Status Colors
  static const Color waiting = Color(0xFFFFB300); // Amber
  static const Color inProgress = Color(0xFF1E88E5); // Blue
  static const Color yourTurn = Color(0xFF43A047); // Green
  static const Color completed = Color(0xFF757575); // Grey

  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFC62828);
  static const Color warning = Color(0xFFEF6C00);
  // Gradient Colors
  static const List<Color> primaryGradient = [primary, Color(0xFF00897B)];

  static const List<Color> accentGradient = [accent, Color(0xFF00E5FF)];
}
