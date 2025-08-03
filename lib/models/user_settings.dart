import 'package:flutter/material.dart';

class UserSettings {
  final ThemeMode themeMode;
  final double fontSize;
  final String fontFamily;
  final Color primaryColor;
  final String defaultVersion;
  final bool showVerseNumbers;
  final bool enableNightMode;
  final double lineSpacing;
  final bool keepScreenOn;

  UserSettings({
    this.themeMode = ThemeMode.system,
    this.fontSize = 16.0,
    this.fontFamily = 'Default',
    this.primaryColor = Colors.blue,
    this.defaultVersion = 'ARC',
    this.showVerseNumbers = true,
    this.enableNightMode = false,
    this.lineSpacing = 1.5,
    this.keepScreenOn = false,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      themeMode: ThemeMode.values[json['themeMode'] ?? 0],
      fontSize: json['fontSize']?.toDouble() ?? 16.0,
      fontFamily: json['fontFamily'] ?? 'Default',
      primaryColor: Color(json['primaryColor'] ?? Colors.blue.value),
      defaultVersion: json['defaultVersion'] ?? 'ARC',
      showVerseNumbers: json['showVerseNumbers'] ?? true,
      enableNightMode: json['enableNightMode'] ?? false,
      lineSpacing: json['lineSpacing']?.toDouble() ?? 1.5,
      keepScreenOn: json['keepScreenOn'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'fontSize': fontSize,
      'fontFamily': fontFamily,
      'primaryColor': primaryColor.value,
      'defaultVersion': defaultVersion,
      'showVerseNumbers': showVerseNumbers,
      'enableNightMode': enableNightMode,
      'lineSpacing': lineSpacing,
      'keepScreenOn': keepScreenOn,
    };
  }

  UserSettings copyWith({
    ThemeMode? themeMode,
    double? fontSize,
    String? fontFamily,
    Color? primaryColor,
    String? defaultVersion,
    bool? showVerseNumbers,
    bool? enableNightMode,
    double? lineSpacing,
    bool? keepScreenOn,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      primaryColor: primaryColor ?? this.primaryColor,
      defaultVersion: defaultVersion ?? this.defaultVersion,
      showVerseNumbers: showVerseNumbers ?? this.showVerseNumbers,
      enableNightMode: enableNightMode ?? this.enableNightMode,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
    );
  }
}