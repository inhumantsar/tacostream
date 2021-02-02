import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tacostream/core/base/theme.dart';

class WyomingTheme implements BaseTheme {
  String get name => "Wyoming";
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
      .copyWith(blockquoteDecoration: BoxDecoration(color: darkBlue[300]));

  MarkdownStyleSheet get markdownDark => MarkdownStyleSheet.fromTheme(dark).copyWith(
        blockquoteDecoration: BoxDecoration(color: softGrey[300]),
      );

  @override
  get props => [name];
  @override
  bool get stringify => true;

  ColorScheme _buildColorScheme({bool isDark = false}) => ColorScheme(
      primary: isDark ? darkBlue : blue,
      primaryVariant: isDark ? darkBlue[300] : blue[100],
      secondary: isDark ? darkRed : red,
      secondaryVariant: isDark ? red : darkRed,
      surface: isDark ? darkBlue : softGrey,
      background: isDark ? darkBlue : softGrey,
      error: red,
      onPrimary: isDark ? Colors.white70 : Colors.white,
      onSecondary: isDark ? Colors.white70 : Colors.black87,
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
  final darkRed = MaterialColor(0xFF920000, {
    900: Color(0xFF920000),
    800: Color(0xE6920000),
    700: Color(0xCC920000),
    600: Color(0xB3920000),
    500: Color(0x99920000),
    400: Color(0x80920000),
    300: Color(0x66920000),
    200: Color(0x4D920000),
    100: Color(0x33920000),
    50: Color(0x1A920000)
  });
  final darkBlue = MaterialColor(0xFF00003d, {
    900: Color(0xFF00003d),
    800: Color(0xE600003d),
    700: Color(0xCC00003d),
    600: Color(0xB300003d),
    500: Color(0x9900003d),
    400: Color(0x8000003d),
    300: Color(0x6600003d),
    200: Color(0x4D00003d),
    100: Color(0x3300003d),
    50: Color(0x1A00003d)
  });
  final blue = MaterialColor(0xFF002768, {
    900: Color(0xFF002768),
    800: Color(0xE6002768),
    700: Color(0xCC002768),
    600: Color(0xB3002768),
    500: Color(0x99002768),
    400: Color(0x80002768),
    300: Color(0x66002768),
    200: Color(0x4D002768),
    100: Color(0x33002768),
    50: Color(0x1A002768)
  });
  final red = MaterialColor(0xFFcb001e, {
    900: Color(0xFFcb001e),
    800: Color(0xE6cb001e),
    700: Color(0xCCcb001e),
    600: Color(0xB3cb001e),
    500: Color(0x99cb001e),
    400: Color(0x80cb001e),
    300: Color(0x66cb001e),
    200: Color(0x4Dcb001e),
    100: Color(0x33cb001e),
    50: Color(0x1Acb001e)
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
