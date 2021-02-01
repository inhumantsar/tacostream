// Jeremiah - DT comment ingest pipeline

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info/package_info.dart';
import 'package:tacostream/core/base/service.dart';
import 'package:tacostream/core/util.dart';
import 'package:tacostream/models/comment.dart';
import 'package:draw/draw.dart' as draw;
import 'package:tacostream/models/thread.dart';
import 'package:tacostream/services/jeeves.dart';
import 'package:tacostream/services/watercooler.dart';

enum IngestStatus {
  noConnectionError,
  redditAuthError,
  unknownError,
  reconnecting,
  connected,
  disconnected
}

class Jeremiah extends ChangeNotifier with BaseService {
  final _wc = GetIt.instance<Watercooler>();
  final _jeeves = GetIt.instance<Jeeves>();

  draw.Reddit _reddit;
  final String subreddit = 'neoliberal';
  final String postTitle = 'Discussion Thread';
  final String postAuthor = 'jobautomator';

  IngestStatus _status;

  StreamSubscription _incoming;

  var dtShortlink;
  DateTime currentDtExpiration;

  double _ingestRate = 0;
  double get ingestRate => _ingestRate;
  int _ingestRateCounter = 0;

  int _reconnectCounter = 0;
  int _reconnectMax = 3;

  Timer statusLogTimer;
  static const Duration statusLoggerInterval = Duration(seconds: 30);
  Timer netMonTimer;
  static const Duration netMonInterval = const Duration(seconds: 10);

  Iterable<Comment> get comments => _wc.values;
  Iterable get commentIds => _wc.keys;
  Comment getCommentById(String id) => _wc.get(id);

  Future<Thread> getThread(String id) async {
    this.log.debug('getThread started');
    var cRef = _reddit.comment(id: id);
    draw.Comment parent = await cRef.populate();
    while (!(parent?.isRoot ?? false)) {
      var tmp = await parent?.parent();
      if (tmp.runtimeType == draw.CommentRef) {
        parent = await (tmp as draw.CommentRef).populate();
      }
      if (tmp.runtimeType == draw.Comment) {
        parent = tmp;
      }
      // this.log.debug('parent: $parent');
    }
    if (parent.replies != null) {
      await parent.replies.replaceMore();
      var replyTypes = parent.replies.comments.map((e) => e.runtimeType).toList();
      this.log.debug('Replies found: ${replyTypes}');
    }
    final thread = await Thread.fromDrawThread(parent);
    this
        .log
        .debug('Thread built. parent: ${thread.parent.id} with ${thread.replies?.length} replies');
    return thread;
  }

  IngestStatus get status => _status;
  WatercoolerStatus get cacheStatus => _wc.status;

  Jeremiah() {
    statusLogTimer = Timer.periodic(statusLoggerInterval, statusLogger);
    netMonTimer = Timer.periodic(netMonInterval, netMon);
  }

  @override
  void dispose() {
    netMonTimer.cancel();
    statusLogTimer.cancel();
    _incoming?.cancel();
    super.dispose();
  }

  Listenable get listenable {
    _incoming ?? _listenForNewComments();
    return _wc.listenable;
  }

  void netMon(_) async {
    /// keeps an eye on the device's internet connection, responds accordingly
    if (!(await hasInternet)) {
      this.log.warning('no internet connection');
      _status = IngestStatus.noConnectionError;
      _incoming?.cancel();
      notifyListeners();
      return;
    }

    if (_status == IngestStatus.reconnecting) {
      this.log.info('still reconnecting... attempt $_reconnectCounter/$_reconnectMax');
      if (_reconnectCounter >= _reconnectMax) {
        _status = IngestStatus.noConnectionError;
        _incoming?.cancel();
        notifyListeners();
        _reconnectCounter = 0;
        return;
      } else {
        _reconnectCounter++;
        return;
      }
    }

    if (_status != IngestStatus.connected) {
      this.log.info('connection: $_status, attempting reconnect...');
      reconnect();
    }
  }

  void statusLogger(_) {
    /// periodically prints useful information
    _ingestRate = (_ingestRateCounter / statusLoggerInterval.inSeconds) * 60;
    _ingestRateCounter = 0;
    this.log.info("incoming: $ingestRate cpm");
    this.log.info('stored comments: ${comments.length}');
    this.log.info('ingestStatus: $status');
  }

  void reconnect() async {
    this.log.info('attempting reconnect');
    _status = IngestStatus.reconnecting;
    await _incoming?.cancel();
    _incoming = null;
    _reddit = null;
    _listenForNewComments();
    notifyListeners();
  }

  Future<void> validateDt(draw.Comment c) async {
    /// confirm dt metadata is current and valid
    final isDtExpired = currentDtExpiration?.isBefore(DateTime.now()) ?? false;
    if (dtShortlink == null || isDtExpired) {
      this.log.debug('currentDt is unknown/expired, checking if submission is DT.');
      draw.Submission post = await c.submission.populate();
      if (post.stickied && post.title == postTitle && post.author == postAuthor) {
        dtShortlink = post.shortlink;
        currentDtExpiration = post.createdUtc.add(Duration(days: 1));
        this.log.debug('new dtShortlink: $dtShortlink');
      }
    }
  }

  Future<bool> _commentIsOnDt(draw.Comment c) async {
    /// check if comment is on the current DT, adapting to daily rollovers when necessary.
    // this happens with surprising frequency
    if (c == null) {
      this.log.warning('received a null commnet');
      return false;
    }

    await validateDt(c);
    return c.submission.shortlink == dtShortlink ? true : false;
  }

  // Comment pipeline
  Future<draw.Comment> _newCommentsFilter(draw.Comment c) async =>
      await _commentIsOnDt(c) ? c : null;

  void _newCommentsDone() {
    this.log.info('jeremiah: new comment listener closed (done).');
    reconnect();
  }

  Future<void> _newCommentsStore(draw.Comment c) async {
    /// stores comments if they are on the DT
    if (c.data == null) await c.populate();
    final comment = Comment.fromDrawComment(c);
    _ingestRateCounter++;
    _wc.put(c.id, comment);
  }

  void _newCommentsError(Object e, [StackTrace stackTrace]) {
    this.log.error('jeremiah: new comment stream encountered an error: $e');
    if (e.toString().contains("SocketException"))
      _status = IngestStatus.noConnectionError;
    else
      _status = IngestStatus.unknownError;
  }

  _listenForNewComments() async {
    /// listens for new comments in the sub and grabs any posted to the DT
    _reddit ??= await _authReddit();
    if (_reddit == null) {
      _status = IngestStatus.redditAuthError;
    } else {
      _status = IngestStatus.connected;
      _incoming = this
          ._reddit
          .subreddit(subreddit)
          .stream
          .comments(pauseAfter: 3)
          .asyncMap(_newCommentsFilter)
          .where((draw.Comment c) => c != null)
          .listen(_newCommentsStore, onError: _newCommentsError, onDone: _newCommentsDone);
    }
  }

  // reddit
  Future<draw.Reddit> _authReddit() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String versionName = packageInfo.version;
    String versionCode = packageInfo.buildNumber;
    String packageName = packageInfo.packageName;
    final userAgent = 'android:$packageName:v$versionName.$versionCode (by /u/inhumantsar)';
    final deviceId = _jeeves.deviceId;
    print("userAgent: $userAgent");
    print("deviceId: $deviceId");

    try {
      return await draw.Reddit.createUntrustedReadOnlyInstance(
          clientId: 'GW3D4HqPspIgtA', deviceId: deviceId, userAgent: userAgent);
    } catch (e) {
      this.log.error("authReddit failed: $e");
    }
    return null;
  }
}
