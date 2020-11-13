import 'package:tacostream/core/base/logger.dart';

class BaseService {
  var _log;

  BaseLogger get log {
    this._log ??= BaseLogger(this.runtimeType.toString());
    return this._log;
  }
}
