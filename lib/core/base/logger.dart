import 'package:logger/logger.dart';
import 'package:intl/intl.dart';

class BaseLogger {
  List<Logger> _loggers;

  BaseLogger(String className) {
    this._loggers = [Logger(printer: ConsolePrinter(className))];
  }

  List<Logger> get loggers => this._loggers;

  void log(Level level, message, [error, StackTrace stackTrace]) => this.loggers.forEach((e) {
        e.log(level, message, error, stackTrace);
      });
  void error(message, [error, StackTrace stackTrace]) =>
      this.log(Level.error, message, error, stackTrace);
  void warning(message, [error]) => this.log(Level.warning, message, error);
  void debug(message) => this.log(Level.debug, message);
  void info(message) => this.log(Level.info, message);
}

class ConsolePrinter extends LogPrinter {
  static int counter = 0;
  final String className;

  ConsolePrinter(this.className);

  @override
  List<String> log(LogEvent event) {
    var color = PrettyPrinter.levelColors[event.level];
    var emoji = PrettyPrinter.levelEmojis[event.level];
    var nowStr = DateFormat.yMd().add_Hms().format(DateTime.now().toUtc());
    List<String> lines = [color('$nowStr $emoji $className - ${event.message}')];
    if (event.error != null) {
      lines.add(color('-' * lines[0].length));
      lines.add(color(event.error.toString()));
      lines.add(color(event.stackTrace.toString()));
    }
    return lines;
  }
}
