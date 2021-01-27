// Jeremiah - DT Streaming

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:package_info/package_info.dart';
import 'package:tacostream/core/base/service.dart';
import 'package:tacostream/models/comment.dart' as taco;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:draw/draw.dart';

class Jeremiah extends ChangeNotifier with BaseService {
  final Box<taco.Comment> _box;
  final Box _prefsBox;
  Reddit _reddit;
  final String subreddit = 'neoliberal';
  final String postTitle = 'Discussion Thread';
  final String postAuthor = 'jobautomator';
  StreamSubscription _incoming;
  var currentDtShortlink;
  DateTime currentDtExpiration;

  JeremiahError _error;
  int _reconnectAttempts = 0;
  DateTime _lastReconnect;

  Timer rateLogger;
  int _incomingRateCounter = 0;
  static const int rateLoggerInterval = 10;
  Timer statusLogger;
  static const int statusLoggerInterval = 30;
  Timer janitor;
  static const int janitorInterval = 60;

  Jeremiah(this._box, this._prefsBox) {
    this.rateLogger = Timer.periodic(const Duration(seconds: rateLoggerInterval), (timer) {
      log.info("incoming: ${(this._incomingRateCounter / rateLoggerInterval) * 60} cpm");
      this._incomingRateCounter = 0;
    });

    this.statusLogger = Timer.periodic(const Duration(seconds: statusLoggerInterval), (timer) {
      log.info('stored comments: ${this.commentIds.length}');
    });

    this.janitor = Timer.periodic(const Duration(seconds: janitorInterval), (timer) {
      if (this.commentIds.length > this.boxLimit) {
        var delCount = this.commentIds.length - this.boxLimit;
        log.info("pruning $delCount oldest records.");
        this._box.deleteAll(this.commentIds.sublist(0, delCount));
        this.notifyListeners();
      }
    });
  }

  int get boxLimit => this._prefsBox.get('boxLimit', defaultValue: 1000);
  set boxLimit(int limit) {
    this._prefsBox.put('boxLimit', limit);
    log.info('boxLimit updated: ${this.boxLimit}');
    this.notifyListeners();
  }

  Listenable get listenable {
    this._incoming ?? _listenForNewComments();
    return _box.listenable();
  }

  Iterable<taco.Comment> get comments => _box.values;
  List get commentIds => _box.keys.toList();

  taco.Comment getCommentById(String id) => _box.get(id);

  JeremiahError get error => this._error;

  DateTime get nextReconnectTime =>
      this._lastReconnect?.add(Duration(seconds: _reconnectAttempts * 3)) ??
      DateTime.now().subtract(Duration(days: 1));

  void reconnect() {
    this._lastReconnect = DateTime.now();
    log.debug('new lastReconnect: ${this._lastReconnect}');
    this._reconnectAttempts++;
    log.debug('new reconnectAttempts: ${this._reconnectAttempts}');
    this._incoming?.cancel();
    this._incoming = null;
    this._reddit = null;
    this._listenForNewComments();
  }

  void close() {
    this.statusLogger.cancel();
    this.janitor.cancel();
    this.rateLogger.cancel();
    this._incoming?.cancel();
  }

  Future<bool> _commentIsOnDt(Comment c) async {
    // check if this comment's parent submission is the DT
    final isDtExpired = this.currentDtExpiration?.isBefore(DateTime.now()) ?? false;
    if (this.currentDtShortlink == null || isDtExpired) {
      log.debug('jeremiah: currentDt is unknown/expired, checking if submission is DT.');
      Submission post = await c.submission.populate();
      if (post.stickied && post.title == this.postTitle && post.author == this.postAuthor) {
        log.debug('jeremiah: comment submission is DT, setting currentDtShortlink.');
        this.currentDtShortlink = post.shortlink;
        this.currentDtExpiration = post.createdUtc.add(Duration(days: 1));
      }
    }

    if (c == null) {
      log.warning('received a null commnet');
      return false;
    }

    if (c.submission.shortlink == this.currentDtShortlink)
      return true;
    else
      return false;
  }

  Future<Comment> _newCommentsFilter(Comment c) async => await this._commentIsOnDt(c) ? c : null;
  void _newCommentsDone() => log.info('jeremiah: new comment listener closed (done).');

  Future<void> _newCommentsStore(Comment c) async {
    /// stores comments if they are on the DT
    if (c.data == null) await c.populate();
    final comment = taco.Comment.fromDrawComment(c);
    _incomingRateCounter++;
    this._box.put(c.id, comment);
  }

  void _newCommentsError(Object e, [StackTrace stackTrace]) {
    log.error('jeremiah: new comment stream encountered an error: $e');
    if (e.toString().contains("SocketException"))
      this._error = JeremiahError.NoConnection;
    else
      this._error = JeremiahError.Unknown;
  }

  void _newCommentsListener(Comment c) {
    this._error = null;
    this._reconnectAttempts = 0;
    this._newCommentsStore(c);
  }

  _listenForNewComments() async {
    /// listens for new comments in the sub and grabs any posted to the DT

    this._reddit ??= await _authReddit();
    if (this._reddit == null) {
      this._error = JeremiahError.NoRedditAuth;
      return;
    }

    this._incoming = this
        ._reddit
        .subreddit(this.subreddit)
        .stream
        .comments(pauseAfter: 3)
        .asyncMap(this._newCommentsFilter)
        .where((Comment c) => c != null)
        .listen(this._newCommentsListener,
            onError: this._newCommentsError, onDone: this._newCommentsDone);
  }

  Future<Reddit> _authReddit() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String versionName = packageInfo.version;
    String versionCode = packageInfo.buildNumber;
    String packageName = packageInfo.packageName;
    final userAgent = 'android:$packageName:v$versionName.$versionCode (by /u/inhumantsar)';
    final deviceId = this._prefsBox.get('deviceId');
    print("userAgent: $userAgent");
    print("deviceId: $deviceId");

    try {
      return await Reddit.createUntrustedReadOnlyInstance(
          clientId: 'GW3D4HqPspIgtA', deviceId: deviceId, userAgent: userAgent);
    } catch (e) {
      log.error(e);
    }
    return null;
  }
}

enum JeremiahError { NoConnection, NoRedditAuth, Unknown }
