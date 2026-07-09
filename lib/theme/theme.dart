import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

ThemeData vitalaTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: VitalaColors.teal,
      primary: VitalaColors.teal,
      surface: VitalaColors.surface,
      onSurface: VitalaColors.ink,
      error: VitalaColors.danger,
    ),
    scaffoldBackgroundColor: VitalaColors.mist,
  );

  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      headlineMedium: GoogleFonts.sora(
          fontSize: 28, fontWeight: FontWeight.w600, color: VitalaColors.ink),
      titleMedium: GoogleFonts.sora(
          fontSize: 20, fontWeight: FontWeight.w600, color: VitalaColors.ink),
      bodyMedium: GoogleFonts.inter(
          fontSize: 15, height: 1.45, color: VitalaColors.ink),
      labelMedium: GoogleFonts.inter(
          fontSize: 13, fontWeight: FontWeight.w500, color: VitalaColors.inkSoft),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: VitalaColors.teal,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
