import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hive/hive.dart';
import 'package:tacostream/core/base/service.dart';
import 'package:tacostream/core/base/theme.dart';
import 'package:tacostream/themes/washington.dart';
import 'package:tacostream/themes/okayama.dart';

class ThemeService extends ChangeNotifier with BaseService {
  final Box box;
  final List<BaseTheme> themes = <BaseTheme>[WashingtonTheme(), OkayamaTheme()];

  ThemeService(this.box);

  void shuffleTheme() {
    var idx = themes.indexOf(_currentBaseTheme);
    var newIdx = idx == themes.length - 1 ? 0 : idx + 1;
    box.put('currentTheme', themes[newIdx].name);
    print("new theme: $currentTheme");
    notifyListeners();
  }

  MarkdownStyleSheet get currentMarkdown => darkMode
      ? _currentBaseTheme.markdownDark
      : _currentBaseTheme.markdownLight;

  ThemeData get currentTheme =>
      _getTheme(box.get('currentTheme', defaultValue: ""));

  BaseTheme get _currentBaseTheme =>
      _getBaseTheme(box.get('currentTheme', defaultValue: ""));

  ThemeData _getTheme(themeName) {
    BaseTheme theme = _getBaseTheme(themeName) ?? themes[0];
    return darkMode ? theme.dark : theme.light;
  }

  BaseTheme _getBaseTheme(themeName) {
    for (var theme in themes) {
      if (theme.name == themeName) return theme;
    }
  }

  void toggleDarkMode() {
    box.put('darkMode', darkMode ? false : true);
    notifyListeners();
  }

  bool get darkMode => box.get('darkMode', defaultValue: false);
}
