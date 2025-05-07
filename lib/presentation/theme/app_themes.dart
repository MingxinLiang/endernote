import 'package:flutter/material.dart';
import 'catppuccin_mocha.dart';
import 'nord.dart';

class xnoteColors extends ThemeExtension<xnoteColors> {
  final Color clrBase;
  final Color clrText;
  final Color clrbackground;
  final Color clrbackText;

  const xnoteColors({
    required this.clrBase,
    required this.clrText,
    required this.clrbackground,
    required this.clrbackText,
  });

  @override
  ThemeExtension<xnoteColors> copyWith({
    Color? clrBase,
    Color? clrText,
    Color? clrbackText,
    Color? clrbackground,
  }) {
    return xnoteColors(
      clrBase: clrBase ?? this.clrBase,
      clrText: clrText ?? this.clrText,
      clrbackground: clrbackground ?? this.clrbackground,
      clrbackText: clrbackText ?? this.clrbackText,
    );
  }

  @override
  ThemeExtension<xnoteColors> lerp(
    ThemeExtension<xnoteColors>? other,
    double t,
  ) {
    if (other is! xnoteColors) {
      return this;
    }
    return xnoteColors(
      clrBase: Color.lerp(clrBase, other.clrBase, t)!,
      clrText: Color.lerp(clrText, other.clrText, t)!,
      clrbackground: Color.lerp(clrbackground, other.clrbackground, t)!,
      clrbackText: Color.lerp(clrbackText, other.clrbackText, t)!,
    );
  }
}

enum AppTheme {
  catppuccinMocha,
  nordDark,
  nordLight,
  // Add new themes here...
}

final Map<AppTheme, ThemeData> appThemeData = {
  AppTheme.catppuccinMocha: catppuccinMochaTheme,
  AppTheme.nordDark: nordDarkTheme,
  AppTheme.nordLight: nordLightTheme,
  // Add other themes here...
};
