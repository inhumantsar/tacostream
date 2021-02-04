import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tacostream/core/base/service.dart';
import 'package:tacostream/models/comment.dart';
import 'package:tacostream/services/jeeves.dart';

enum WatercoolerStatus { clearing, pruning, ready, notReady }

/// persistent comment cache
/// TODO: probably ditch the box and stick to a simple in-memory list
class Watercooler extends ChangeNotifier with BaseService {
  final Box<Comment> _box;
  final _jeeves = GetIt.instance<Jeeves>();
  var _status = WatercoolerStatus.notReady;
  // ignore: unused_field
  Timer _pruneTimer;

  Watercooler(this._box) {
    if (_jeeves.clearCacheAtStartup)
      clear();
    else
      _status = WatercoolerStatus.ready;

    _pruneTimer = Timer.periodic(Duration(seconds: pruneInterval), prune);
  }

  get status => _status;
  _updateStatus(WatercoolerStatus s) {
    _status = s;
    SchedulerBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  put(String key, Comment value) => _box.put(key, value);
  get(String key) => _box.get(key);
  get keys => _box.keys;
  get values => _box.values;
  get length => _box.length;
  ValueListenable<Box<Comment>> get listenable => _box.listenable();
  get maxCacheSize => _jeeves.maxCacheSize;
  set maxCacheSize(val) {
    _jeeves.maxCacheSize = val;
    notifyListeners();
  }

  get clearCacheAtStartup => _jeeves.clearCacheAtStartup;
  set clearCacheAtStartup(val) {
    _jeeves.clearCacheAtStartup = val;
    notifyListeners();
  }

  get pruneInterval => _jeeves.pruneInterval;
  set pruneInterval(val) {
    _jeeves.pruneInterval = val;
    _pruneTimer.cancel();
    _pruneTimer = Timer.periodic(Duration(seconds: pruneInterval), prune);
    notifyListeners();
  }

  Future<void> clear() async {
    log.info('clearing cache');
    if (status == WatercoolerStatus.clearing || status == WatercoolerStatus.pruning) return;
    _updateStatus(WatercoolerStatus.clearing);
    await _box.deleteAll(_box.keys);
    _updateStatus(WatercoolerStatus.ready);
  }

  Future<void> prune(_) async {
    if (status == WatercoolerStatus.pruning) return;
    _updateStatus(WatercoolerStatus.pruning);

    /// prunes oldest comments when maxCacheSize is reached
    if (status != WatercoolerStatus.clearing && _box.length > maxCacheSize) {
      var delCount = _box.length - maxCacheSize;
      log.info("pruning $delCount oldest records.");
      await _box.deleteAll(_box.keys.toList().sublist(0, delCount));
    }

    _updateStatus(WatercoolerStatus.ready);
  }
}
