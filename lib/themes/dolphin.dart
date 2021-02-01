import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tacostream/core/base/theme.dart';

class DolphinTheme implements BaseTheme {
  String get name => "Dolphin";
  MaterialColor get primaryColor => _buildColorScheme().primary;
  MaterialColor get primaryColorDark => _buildColorScheme(isDark: true).primary;

  ThemeData get dark {
    return ThemeData.from(
            colorScheme: _buildColorScheme(isDark: true), textTheme: _buildTextTheme(isDark: true))
        .copyWith(appBarTheme: AppBarTheme(color: darkBlue));
  }

  ThemeData get light {
    return ThemeData.from(
            colorScheme: _buildColorScheme(isDark: false),
            textTheme: _buildTextTheme(isDark: false))
        .copyWith();
  }

  TextTheme _buildTextTheme({bool isDark}) {
    var baseTheme = isDark ? ThemeData.dark() : ThemeData.light();
    return baseTheme.textTheme
        .copyWith(bodyText2: baseTheme.textTheme.bodyText2.copyWith(fontSize: 12));
  }

  MarkdownStyleSheet get markdownLight => MarkdownStyleSheet.fromTheme(light)
      .copyWith(blockquoteDecoration: BoxDecoration(color: darkBlue[300]));

  MarkdownStyleSheet get markdownDark => MarkdownStyleSheet.fromTheme(dark).copyWith(
        blockquoteDecoration: BoxDecoration(color: softGrey[300]),
      );

  @override
  get props => [name];
  @override
  bool get stringify => true;

  ColorScheme _buildColorScheme({bool isDark = false}) => ColorScheme(
      primary: darkBlue,
      primaryVariant: darkBlue[300],
      secondary: lightOrange,
      secondaryVariant: orange,
      surface: isDark ? darkGrey : softGrey,
      background: isDark ? darkGrey : softGrey,
      error: red,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: isDark ? softGrey : darkBlue,
      onBackground: isDark ? softGrey : darkBlue,
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
  final darkGrey = MaterialColor(0xFF3f3f3f, {
    900: Color(0xFF3f3f3f),
    800: Color(0xE63f3f3f),
    700: Color(0xCC3f3f3f),
    600: Color(0xB33f3f3f),
    500: Color(0x993f3f3f),
    400: Color(0x803f3f3f),
    300: Color(0x663f3f3f),
    200: Color(0x4D3f3f3f),
    100: Color(0x333f3f3f),
    50: Color(0x1A3f3f3f)
  });
  final orange = MaterialColor(0xFFff9900, {
    900: Color(0xFFff9900),
    800: Color(0xE6ff9900),
    700: Color(0xCCff9900),
    600: Color(0xB3ff9900),
    500: Color(0x99ff9900),
    400: Color(0x80ff9900),
    300: Color(0x66ff9900),
    200: Color(0x4Dff9900),
    100: Color(0x33ff9900),
    50: Color(0x1Aff9900)
  });
  final darkBlue = MaterialColor(0xFF009bcc, {
    900: Color(0xFF009bcc),
    800: Color(0xE6009bcc),
    700: Color(0xCC009bcc),
    600: Color(0xB3009bcc),
    500: Color(0x99009bcc),
    400: Color(0x80009bcc),
    300: Color(0x66009bcc),
    200: Color(0x4D009bcc),
    100: Color(0x33009bcc),
    50: Color(0x1A009bcc)
  });
  final blue = MaterialColor(0xFF00ccff, {
    900: Color(0xFF00ccff),
    800: Color(0xE600ccff),
    700: Color(0xCC00ccff),
    600: Color(0xB300ccff),
    500: Color(0x9900ccff),
    400: Color(0x8000ccff),
    300: Color(0x6600ccff),
    200: Color(0x4D00ccff),
    100: Color(0x3300ccff),
    50: Color(0x1A00ccff)
  });
  final lightOrange = MaterialColor(0xFFffca47, {
    900: Color(0xFFffca47),
    800: Color(0xE6ffca47),
    700: Color(0xCCffca47),
    600: Color(0xB3ffca47),
    500: Color(0x99ffca47),
    400: Color(0x80ffca47),
    300: Color(0x66ffca47),
    200: Color(0x4Dffca47),
    100: Color(0x33ffca47),
    50: Color(0x1Affca47)
  });
  final red = MaterialColor(0xFFeb0000, {
    900: Color(0xFFeb0000),
    800: Color(0xE6eb0000),
    700: Color(0xCCeb0000),
    600: Color(0xB3eb0000),
    500: Color(0x99eb0000),
    400: Color(0x80eb0000),
    300: Color(0x66eb0000),
    200: Color(0x4Deb0000),
    100: Color(0x33eb0000),
    50: Color(0x1Aeb0000)
  });
}
