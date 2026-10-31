import 'package:flutter/material.dart';

import 'app_colors.dart';

ThemeData appTheme() => ThemeData(
  useMaterial3: true,
  fontFamily: 'PlusJakartaSans',
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.blue,
    primary: AppColors.blue,
    surface: Colors.white,
  ),
  scaffoldBackgroundColor: AppColors.background,
  textTheme: const TextTheme(
    bodyMedium: TextStyle(fontSize: 13, color: AppColors.ink),
    bodySmall: TextStyle(fontSize: 11, color: AppColors.muted),
  ),
  // Figma: header putih 66px, panah kembali hitam, judul tebal, garis bawah.
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    toolbarHeight: 66,
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    foregroundColor: Colors.black,
    elevation: 2,
    scrolledUnderElevation: 2,
    shadowColor: Color(0x33000000),
    shape: Border(bottom: BorderSide(color: Color(0xFFCCCCCC))),
    // AppBar tidak mewarisi font dari textTheme, jadi font ditulis ulang.
    titleTextStyle: TextStyle(
      fontFamily: 'PlusJakartaSans',
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    ),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
  ),
  // Figma: kolom putih, garis tipis abu-abu, sudut 6.
  inputDecorationTheme: InputDecorationTheme(
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9AA0A2)),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFFE4E9ED)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFFE4E9ED)),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.blue,
      foregroundColor: Colors.white,
      // Figma halaman pembayaran: tombol biru 48px, teks 15 tebal.
      minimumSize: const Size(0, 48),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  dividerTheme: const DividerThemeData(color: Color(0xFFE5EDF0), thickness: 1),
);
