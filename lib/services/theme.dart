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

  void setTheme(themeName) {
    box.put('currentTheme', themeName);
    print("new theme: $currentTheme");
    notifyListeners();
  }

  void shuffleTheme() {
    var idx = themes.indexOf(currentBaseTheme);
    var newIdx = idx == themes.length - 1 ? 0 : idx + 1;
    setTheme(themes[newIdx].name);
  }

  MarkdownStyleSheet get currentMarkdown =>
      darkMode ? currentBaseTheme.markdownDark : currentBaseTheme.markdownLight;

  ThemeData get currentTheme => _getTheme(box.get('currentTheme', defaultValue: ""));

  BaseTheme get currentBaseTheme =>
      _getBaseTheme(box.get('currentTheme', defaultValue: "Washington"));

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
