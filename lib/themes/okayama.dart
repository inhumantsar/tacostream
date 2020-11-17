import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tacostream/core/base/theme.dart';

class OkayamaTheme implements BaseTheme {
  String get name => "Okayama";
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
        .copyWith(blockquoteDecoration: BoxDecoration(color: crownRoyal[400]));

  MarkdownStyleSheet get markdownDark => MarkdownStyleSheet.fromTheme(dark)
      .copyWith(blockquoteDecoration: BoxDecoration(color: crownRoyal[400]));

  @override
  get props => [name];
  @override
  bool get stringify => true;

  ColorScheme _buildColorScheme({bool isDark = false}) => ColorScheme(
      primary: crownRoyal,
      primaryVariant: crownRoyal,
      secondary: mikadoYellow,
      secondaryVariant: isDark ? vividSkyBlue : violet,
      surface: isDark ? violet : lilac,
      background: isDark ? violet : lilac,
      error: congoPink,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: isDark ? lilac : violet,
      onBackground: isDark ? lilac : violet,
      onError: Colors.black,
      brightness: isDark ? Brightness.dark : Brightness.light);

  final lilac = MaterialColor(0xFFc7b9ff, {
    900: Color(0xFFc7b9ff),
    800: Color(0xE6c7b9ff),
    700: Color(0xCCc7b9ff),
    600: Color(0xB3c7b9ff),
    500: Color(0x99c7b9ff),
    400: Color(0x80c7b9ff),
    300: Color(0x66c7b9ff),
    200: Color(0x4Dc7b9ff),
    100: Color(0x33c7b9ff),
    50: Color(0x1Ac7b9ff)
  });
  final violet = MaterialColor(0xFF240046, {
    900: Color(0xFF240046),
    800: Color(0xE6240046),
    700: Color(0xCC240046),
    600: Color(0xB3240046),
    500: Color(0x99240046),
    400: Color(0x80240046),
    300: Color(0x66240046),
    200: Color(0x4D240046),
    100: Color(0x33240046),
    50:  Color(0x1A240046)
  });
  final crownRoyal = MaterialColor(0xFF6622cc, {
    900: Color(0xFF6622cc),
    800: Color(0xE66622cc),
    700: Color(0xCC6622cc),
    600: Color(0xB36622cc),
    500: Color(0x996622cc),
    400: Color(0x806622cc),
    300: Color(0x666622cc),
    200: Color(0x4D6622cc),
    100: Color(0x336622cc),
    50: Color(0x1A6622cc)
  });
  final mikadoYellow = MaterialColor(0xFFffc700, {
    900: Color(0xFFffc700),
    800: Color(0xE6ffc700),
    700: Color(0xCCffc700),
    600: Color(0xB3ffc700),
    500: Color(0x99ffc700),
    400: Color(0x80ffc700),
    300: Color(0x66ffc700),
    200: Color(0x4Dffc700),
    100: Color(0x33ffc700),
    50: Color(0x1Affc700)
  });
  final vividSkyBlue = MaterialColor(0xFF17d8ff, {
    900: Color(0xFF17d8ff),
    800: Color(0xE617d8ff),
    700: Color(0xCC17d8ff),
    600: Color(0xB317d8ff),
    500: Color(0x9917d8ff),
    400: Color(0x8017d8ff),
    300: Color(0x6617d8ff),
    200: Color(0x4D17d8ff),
    100: Color(0x3317d8ff),
    50: Color(0x1A17d8ff)
  });
  final congoPink = MaterialColor(0xFFF28076, {
    900: Color(0xFFF28076),
    800: Color(0xE6F28076),
    700: Color(0xCCF28076),
    600: Color(0xB3F28076),
    500: Color(0x99F28076),
    400: Color(0x80F28076),
    300: Color(0x66F28076),
    200: Color(0x4DF28076),
    100: Color(0x33F28076),
    50: Color(0x1AF28076)
  });
}
