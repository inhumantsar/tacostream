import 'package:tacostream/core/base/service.dart';
import 'package:tacostream/models/redditor.dart';
import 'package:uuid/uuid.dart';

class Jeeves with BaseService {
  final _prefsBox;

  Jeeves(this._prefsBox) {
    deviceId ?? _prefsBox.put('deviceId', Uuid().v4());
    _prefsBox.get('unlockedThemes') ?? _prefsBox.put('unlockedThemes', ['Washington', 'Okayama']);
  }

  /// unique id which lives and dies with the installation
  String get deviceId => _prefsBox.get('deviceId');

  // appearance prefs
  List<String> get unlockedThemes => _prefsBox.get('unlockedThemes');

  int get fontSize => _prefsBox.get('fontSize', defaultValue: 0);
  set fontSize(val) {
    _prefsBox.put('fontSize', val);
    this.log.info('updated fontSize: ${this.fontSize}');
  }

  String get currentTheme => _prefsBox.get('currentTheme', defaultValue: "Washington");
  set currentTheme(val) => _prefsBox.put('currentTheme', val);

  bool get darkMode => _prefsBox.get('darkMode', defaultValue: false);
  set darkMode(val) {
    _prefsBox.put('darkMode', val);
    this.log.info('dark mode on: ${this.darkMode}');
  }

  void toggleDarkMode() => darkMode = darkMode ? false : true;

  // system prefs
  int get maxCacheSize => _prefsBox.get('maxCacheSize', defaultValue: 1000);
  set maxCacheSize(int max) {
    _prefsBox.put('maxCacheSize', max);
    this.log.info('updated maxCacheSize: $maxCacheSize');
  }

  bool get clearCacheAtStartup => _prefsBox.get('clearCacheAtStartup', defaultValue: true);
  set clearCacheAtStartup(bool value) {
    _prefsBox.put('clearCacheAtStartup', value);
    this.log.info('updated clearCacheAtStartup: $clearCacheAtStartup');
  }

  int get pruneInterval => _prefsBox.get('pruneInterval', defaultValue: 300);
  set pruneInterval(int value) {
    _prefsBox.put('pruneInterval', value);
    this.log.info('updated pruneInterval: $pruneInterval');
  }

  // accounts
  List<Redditor> get accounts =>
      List<Redditor>.from(_prefsBox.get('accounts', defaultValue: <Redditor>[]));
  void clearAccounts() {
    _prefsBox.put('accounts', <Redditor>[]);
    this.log.warning('accounts cleared');
  }

  void removeAccount(Redditor acct) {
    var newAccts = List<Redditor>.from(accounts);
    newAccts.removeWhere((r) => r.id == acct.id);
    _prefsBox.put('accounts', List<Redditor>.from(newAccts));
    this.log.info('account removed: ${acct.id} ${acct.displayName}');
  }

  void addAccount(Redditor acct) {
    removeAccount(acct);
    var newAccts = List<Redditor>.from(accounts);
    _prefsBox.put('accounts', List<Redditor>.from(newAccts + [acct]));
    this.log.info('account added: ${acct.id} ${acct.displayName}');
  }
}
