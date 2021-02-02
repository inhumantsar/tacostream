import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tacostream/core/base/theme.dart';

class NewMexicoTheme implements BaseTheme {
  String get name => "NewMexico";
  MaterialColor get primaryColor => _buildColorScheme().primary;
  MaterialColor get primaryColorDark => _buildColorScheme(isDark: true).primary;

  ThemeData get dark {
    return ThemeData.from(
            colorScheme: _buildColorScheme(isDark: true), textTheme: _buildTextTheme(isDark: true))
        .copyWith(buttonColor: sandyBrown[700]);
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
      .copyWith(blockquoteDecoration: BoxDecoration(color: darkRed[300]));

  MarkdownStyleSheet get markdownDark => MarkdownStyleSheet.fromTheme(dark).copyWith(
        blockquoteDecoration: BoxDecoration(color: softGrey[300]),
      );

  @override
  get props => [name];
  @override
  bool get stringify => true;

  ColorScheme _buildColorScheme({bool isDark = false}) => ColorScheme(
      primary: isDark ? darkRed : yellow,
      primaryVariant: isDark ? darkRed[300] : yellow[100],
      secondary: isDark ? yellow : red,
      secondaryVariant: isDark ? darkYellow : darkRed,
      // primary: red,
      // primaryVariant: isDark ? red[300] : red[100],
      // secondary: yellow,
      // secondaryVariant: yellow,
      surface: isDark ? darkRed : softGrey,
      background: isDark ? darkRed : softGrey,
      error: red,
      onPrimary: isDark ? Colors.white70 : Colors.black87,
      onSecondary: isDark ? Colors.white70 : Colors.black87,
      onSurface: isDark ? softGrey : darkRed,
      onBackground: isDark ? softGrey : darkRed,
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
  final darkYellow = MaterialColor(0xFFc7a600, {
    900: Color(0xFFc7a600),
    800: Color(0xE6c7a600),
    700: Color(0xCCc7a600),
    600: Color(0xB3c7a600),
    500: Color(0x99c7a600),
    400: Color(0x80c7a600),
    300: Color(0x66c7a600),
    200: Color(0x4Dc7a600),
    100: Color(0x33c7a600),
    50: Color(0x1Ac7a600)
  });
  final darkRed = MaterialColor(0xFF4c0005, {
    900: Color(0xFF4c0005),
    800: Color(0xE64c0005),
    700: Color(0xCC4c0005),
    600: Color(0xB34c0005),
    500: Color(0x994c0005),
    400: Color(0x804c0005),
    300: Color(0x664c0005),
    200: Color(0x4D4c0005),
    100: Color(0x334c0005),
    50: Color(0x1A4c0005)
  });
  final yellow = MaterialColor(0xFFffd700, {
    900: Color(0xFFffd700),
    800: Color(0xE6ffd700),
    700: Color(0xCCffd700),
    600: Color(0xB3ffd700),
    500: Color(0x99ffd700),
    400: Color(0x80ffd700),
    300: Color(0x66ffd700),
    200: Color(0x4Dffd700),
    100: Color(0x33ffd700),
    50: Color(0x1Affd700)
  });
  final red = MaterialColor(0xFFbf0a30, {
    900: Color(0xFFbf0a30),
    800: Color(0xE6bf0a30),
    700: Color(0xCCbf0a30),
    600: Color(0xB3bf0a30),
    500: Color(0x99bf0a30),
    400: Color(0x80bf0a30),
    300: Color(0x66bf0a30),
    200: Color(0x4Dbf0a30),
    100: Color(0x33bf0a30),
    50: Color(0x1Abf0a30)
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
