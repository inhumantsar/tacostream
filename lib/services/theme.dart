import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hive/hive.dart';
import 'package:tacostream/core/base/service.dart';
import 'package:tacostream/core/base/theme.dart';
import 'package:tacostream/themes/washington.dart';
import 'package:tacostream/themes/okayama.dart';

class ThemeService extends ChangeNotifier with BaseService {
  final Box prefsBox;
  final List<BaseTheme> themes = <BaseTheme>[WashingtonTheme(), OkayamaTheme()];
  FontSize _fontSize;
  final fontSizeIndex = {FontSize.small: 14.0, FontSize.medium: 16.0, FontSize.large: 18.0};
  var _themeCache;
  var _mdThemeCache;

  ThemeService(this.prefsBox);

  ThemeData get theme => _getTheme(prefsBox.get('currentTheme', defaultValue: ""));

  set theme(themeName) {
    prefsBox.put('currentTheme', themeName);
    log.debug("new theme: $theme");
    invalidateCache();
    notifyListeners();
  }

  void shuffleTheme() {
    var idx = themes.indexOf(currentBaseTheme);
    var newIdx = idx == themes.length - 1 ? 0 : idx + 1;
    theme = themes[newIdx].name;
  }

  void invalidateCache() {
    this._themeCache = null;
    this._mdThemeCache = null;
  }

  BaseTheme get currentBaseTheme =>
      _getBaseTheme(prefsBox.get('currentTheme', defaultValue: "Washington"));

  ThemeData _getTheme(themeName) {
    if (this._themeCache == null) {
      BaseTheme theme = _getBaseTheme(themeName) ?? themes[0];
      var themeData = darkMode ? theme.dark : theme.light;
      log.debug(
          'caching fresh themeData with font size: ${this.fontSize} (${this.fontSizeIndex[this.fontSize]})');
      this._themeCache = themeData.copyWith(
          textTheme: themeData.textTheme.merge(TextTheme(
        bodyText1: TextStyle(fontSize: this.fontSizeIndex[this.fontSize] + 2),
        bodyText2: TextStyle(fontSize: this.fontSizeIndex[this.fontSize]),
        button: TextStyle(fontSize: this.fontSizeIndex[this.fontSize]),
        caption: TextStyle(fontSize: this.fontSizeIndex[this.fontSize] - 2),
        headline1: TextStyle(fontSize: this.fontSizeIndex[this.fontSize] + 82),
        headline2: TextStyle(fontSize: this.fontSizeIndex[this.fontSize] + 44),
        headline3: TextStyle(fontSize: this.fontSizeIndex[this.fontSize] + 34),
        headline4: TextStyle(fontSize: this.fontSizeIndex[this.fontSize] + 20),
        headline5: TextStyle(fontSize: this.fontSizeIndex[this.fontSize] + 10),
        headline6: TextStyle(fontSize: this.fontSizeIndex[this.fontSize] + 4),
        subtitle1: TextStyle(fontSize: this.fontSizeIndex[this.fontSize] + 2),
        subtitle2: TextStyle(fontSize: this.fontSizeIndex[this.fontSize]),
      )));
    }
    return this._themeCache;
  }

  MarkdownStyleSheet get mdTheme {
    if (this._mdThemeCache == null) {
      var mdTheme = darkMode ? currentBaseTheme.markdownDark : currentBaseTheme.markdownLight;
      log.debug(
          'caching fresh MarkdownStyleSheet with font size: ${this.fontSize} (${this.fontSizeIndex[this.fontSize]})');
      this._mdThemeCache = mdTheme.copyWith(
        a: mdTheme.a.copyWith(fontSize: this.fontSizeIndex[this.fontSize]),
        p: mdTheme.p.copyWith(fontSize: this.fontSizeIndex[this.fontSize]),
        code: mdTheme.code.copyWith(fontSize: this.fontSizeIndex[this.fontSize]),
        h1: mdTheme.h1.copyWith(fontSize: this.fontSizeIndex[this.fontSize] + 82),
        h2: mdTheme.h2.copyWith(fontSize: this.fontSizeIndex[this.fontSize] + 44),
        h3: mdTheme.h3.copyWith(fontSize: this.fontSizeIndex[this.fontSize] + 34),
        h4: mdTheme.h4.copyWith(fontSize: this.fontSizeIndex[this.fontSize] + 20),
        h5: mdTheme.h5.copyWith(fontSize: this.fontSizeIndex[this.fontSize] + 10),
        h6: mdTheme.h6.copyWith(fontSize: this.fontSizeIndex[this.fontSize] + 4),
        blockquote: mdTheme.blockquote.copyWith(fontSize: this.fontSizeIndex[this.fontSize] - 2),
      );
    }
    return this._mdThemeCache;
  }

  BaseTheme _getBaseTheme(themeName) {
    for (var theme in themes) {
      if (theme.name == themeName) return theme;
    }
    // fallback
    return themes[0];
  }

  get fontSize => FontSize.values[this.prefsBox.get('fontSize', defaultValue: 0)];
  set fontSize(FontSize f) {
    this.prefsBox.put('fontSize', f.index);
    log.debug('new fontSize: ${this.fontSize}');
    invalidateCache();
    notifyListeners();
  }

  void toggleDarkMode() {
    prefsBox.put('darkMode', darkMode ? false : true);
    log.debug('dark mode on: ${this.darkMode}');
    invalidateCache();
    notifyListeners();
  }

  bool get darkMode => prefsBox.get('darkMode', defaultValue: false);
}

enum FontSize { small, medium, large }
