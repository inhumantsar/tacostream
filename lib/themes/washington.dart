import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tacostream/core/base/theme.dart';

class WashingtonTheme implements BaseTheme {
  String get name => "Washington";
  MaterialColor get primaryColor => _buildColorScheme().primary;
  MaterialColor get primaryColorDark => _buildColorScheme(isDark: true).primary;

  ThemeData get dark => ThemeData.from(
      colorScheme: _buildColorScheme(isDark: true),
      textTheme: _buildTextTheme(isDark: true));
  ThemeData get light => ThemeData.from(
      colorScheme: _buildColorScheme(isDark: false),
      textTheme: _buildTextTheme(isDark: false));

  TextTheme _buildTextTheme({bool isDark}) {
      var baseTheme = isDark ? ThemeData.dark() : ThemeData.light();
      return baseTheme.textTheme.copyWith(bodyText2: baseTheme.textTheme.bodyText2.copyWith(fontSize: 12));
  }

  MarkdownStyleSheet get markdownLight => MarkdownStyleSheet.fromTheme(light)
        .copyWith(blockquoteDecoration: BoxDecoration(color: charcoal[300]));

  MarkdownStyleSheet get markdownDark => MarkdownStyleSheet.fromTheme(dark)
      .copyWith(blockquoteDecoration: BoxDecoration(color: softGrey[300]));

  @override
  get props => [name];
  @override
  bool get stringify => true;

  ColorScheme _buildColorScheme({bool isDark = false}) => ColorScheme(
      primary: persianGreen,
      primaryVariant: persianGreen,
      secondary: orangeYellowCrayola,
      secondaryVariant: sandyBrown,
      surface: isDark ? charcoal : softGrey,
      background: isDark ? charcoal : softGrey,
      error: burntSienna,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: isDark ? softGrey : charcoal,
      onBackground: isDark ? softGrey : charcoal,
      onError: Colors.black,
      brightness: isDark ? Brightness.dark : Brightness.light);

  final softGrey = MaterialColor(0xFFf0efeb, {
    900: Color(0xFFf0efeb),
    800: Color(0xE6f0efeb),
    700: Color(0xCCf0efeb),
    600: Color(0xB3f0efeb),
    500: Color(0x99f0efeb),
    400: Color(0x80f0efeb),
    300: Color(0x66f0efeb),
    200: Color(0x4Df0efeb),
    100: Color(0x33f0efeb),
    50: Color(0x1Af0efeb)
  });
  final charcoal = MaterialColor(0xFF264653, {
    900: Color(0xFF264653),
    800: Color(0xE6264653),
    700: Color(0xCC264653),
    600: Color(0xB3264653),
    500: Color(0x99264653),
    400: Color(0x80264653),
    300: Color(0x66264653),
    200: Color(0x4D264653),
    100: Color(0x33264653),
    50: Color(0x1A264653)
  });
  final persianGreen = MaterialColor(0xFF2a9d8f, {
    900: Color(0xFF2a9d8f),
    800: Color(0xE62a9d8f),
    700: Color(0xCC2a9d8f),
    600: Color(0xB32a9d8f),
    500: Color(0x992a9d8f),
    400: Color(0x802a9d8f),
    300: Color(0x662a9d8f),
    200: Color(0x4D2a9d8f),
    100: Color(0x332a9d8f),
    50: Color(0x1A2a9d8f)
  });
  final orangeYellowCrayola = MaterialColor(0xFFe9c46a, {
    900: Color(0xFFe9c46a),
    800: Color(0xE6e9c46a),
    700: Color(0xCCe9c46a),
    600: Color(0xB3e9c46a),
    500: Color(0x99e9c46a),
    400: Color(0x80e9c46a),
    300: Color(0x66e9c46a),
    200: Color(0x4De9c46a),
    100: Color(0x33e9c46a),
    50: Color(0x1Ae9c46a)
  });
  final sandyBrown = MaterialColor(0xFFf4a261, {
    900: Color(0xFFf4a261),
    800: Color(0xE6f4a261),
    700: Color(0xCCf4a261),
    600: Color(0xB3f4a261),
    500: Color(0x99f4a261),
    400: Color(0x80f4a261),
    300: Color(0x66f4a261),
    200: Color(0x4Df4a261),
    100: Color(0x33f4a261),
    50: Color(0x1Af4a261)
  });
  final burntSienna = MaterialColor(0xFFe76f51, {
    900: Color(0xFFe76f51),
    800: Color(0xE6e76f51),
    700: Color(0xCCe76f51),
    600: Color(0xB3e76f51),
    500: Color(0x99e76f51),
    400: Color(0x80e76f51),
    300: Color(0x66e76f51),
    200: Color(0x4De76f51),
    100: Color(0x33e76f51),
    50: Color(0x1Ae76f51)
  });
}
