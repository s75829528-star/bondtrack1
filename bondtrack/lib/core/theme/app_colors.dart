import 'package:flutter/material.dart';

/// BondTrack palette — deep navy, teal and emerald on clean white.
class AppColors {
  AppColors._();

  static const navy = Color(0xFF0B1F3A);
  static const navyDeep = Color(0xFF07162A);
  static const ink = Color(0xFF102A43);
  static const slate = Color(0xFF334E68);
  static const muted = Color(0xFF6B7C93);
  static const teal = Color(0xFF0F8B8D);
  static const tealDeep = Color(0xFF0A6B6D);
  static const tealSoft = Color(0xFFE2F4F3);
  static const emerald = Color(0xFF0FA37F);
  static const emeraldDeep = Color(0xFF0A7D61);
  static const emeraldSoft = Color(0xFFE4F6F0);
  static const mint = Color(0xFF6FD6C0);
  static const gold = Color(0xFFC6A15B);
  static const goldSoft = Color(0xFFF8F1E3);
  static const danger = Color(0xFFD64545);
  static const dangerSoft = Color(0xFFFDECEC);
  static const warning = Color(0xFFD98B2B);
  static const warningSoft = Color(0xFFFDF3E5);

  static const background = Color(0xFFF5F7FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF0F4F8);
  static const border = Color(0xFFE3E9F0);

  static const darkBackground = Color(0xFF06101D);
  static const darkSurface = Color(0xFF0C1A2B);
  static const darkSurfaceMuted = Color(0xFF13243A);
  static const darkBorder = Color(0xFF1E324A);
  static const darkText = Color(0xFFE9F0F7);
  static const darkMuted = Color(0xFF8FA5BC);

  static const chart = <Color>[
    Color(0xFF0F8B8D),
    Color(0xFF0FA37F),
    Color(0xFF2E5AAC),
    Color(0xFFC6A15B),
    Color(0xFF6C63C7),
    Color(0xFFE07A5F),
    Color(0xFF3D9970),
    Color(0xFF8FA5BC),
  ];

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B1F3A), Color(0xFF0C3B4A), Color(0xFF0F6F6B)],
    stops: [0.0, 0.55, 1.0],
  );

  static const tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F8B8D), Color(0xFF0FA37F)],
  );

  static const emeraldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0FA37F), Color(0xFF6FD6C0)],
  );

  static const navyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF102A43), Color(0xFF0B1F3A)],
  );
}
