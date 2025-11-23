import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Modern Purple/Blue Gradient Theme
  static const Color primary = Color(0xFF6C63FF); // Vibrant Purple
  static const Color primaryLight = Color(0xFF8B84FF);
  static const Color primaryDark = Color(0xFF5B52E8);
  
  // Accent Colors - Complementary Gradient
  static const Color accent = Color(0xFFFF6B9D); // Pink accent
  static const Color accentLight = Color(0xFFFF8AB3);
  static const Color accentDark = Color(0xFFE85B8A);
  
  // Secondary Accent
  static const Color secondary = Color(0xFF4ECDC4); // Teal
  static const Color secondaryLight = Color(0xFF70DDD5);
  static const Color secondaryDark = Color(0xFF3ABBB3);
  
  // Background Colors - Clean & Modern
  static const Color background = Color(0xFFF8F9FE); // Very light purple tint
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F6FA);
  static const Color card = Color(0xFFFFFFFF);
  
  // Text Colors - High Contrast
  static const Color textPrimary = Color(0xFF1A1D2E); // Dark blue-gray
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFAEB5C1);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Dividers and Borders - Subtle
  static const Color divider = Color(0xFFE5E7EB);
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  
  // Semantic Colors - Modern & Vibrant
  static const Color success = Color(0xFF10B981); // Green
  static const Color successLight = Color(0xFF34D399);
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444); // Red
  static const Color errorLight = Color(0xFFF87171);
  static const Color info = Color(0xFF3B82F6); // Blue
  static const Color infoLight = Color(0xFF60A5FA);
  
  // Special States
  static const Color gift = Color(0xFFEC4899); // Pink
  static const Color bought = Color(0xFF8B5CF6); // Purple
  
  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF6C63FF),
    Color(0xFF8B84FF),
  ];
  
  static const List<Color> accentGradient = [
    Color(0xFFFF6B9D),
    Color(0xFFFFA06B),
  ];
  
  static const List<Color> successGradient = [
    Color(0xFF10B981),
    Color(0xFF34D399),
  ];
  
  static const List<Color> cardGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFF8F9FE),
  ];
  
  // Shimmer Colors (for loading states)
  static const Color shimmerBase = Color(0xFFE5E7EB);
  static const Color shimmerHighlight = Color(0xFFF9FAFB);
  
  // Overlay Colors
  static const Color overlay = Color(0x80000000); // 50% black
  static const Color overlayLight = Color(0x40000000); // 25% black
  static const Color overlayPurple = Color(0x806C63FF); // 50% purple
  
  // Chart Colors - For Statistics
  static const List<Color> chartColors = [
    Color(0xFF6C63FF),
    Color(0xFFFF6B9D),
    Color(0xFF4ECDC4),
    Color(0xFFFFA06B),
    Color(0xFF8B5CF6),
    Color(0xFF10B981),
  ];
}
