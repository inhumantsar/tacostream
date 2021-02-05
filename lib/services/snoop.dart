// Snoop - DT comment ingest pipeline

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info/package_info.dart';
import 'package:tacostream/core/base/service.dart';
import 'package:tacostream/core/util.dart';
import 'package:tacostream/models/comment.dart';
import 'package:draw/draw.dart' as draw;
import 'package:tacostream/models/redditor.dart';
import 'package:tacostream/models/thread.dart';
import 'package:tacostream/services/jeeves.dart';
import 'package:tacostream/services/watercooler.dart';

enum LoginStatus {
  loggingIn,
  loggedIn,
  loggedOut,
  loggingOut,
}

enum IngestStatus {
  noConnectionError,
  redditAuthError,
  unknownError,
  reconnecting,
  connected,
  disconnected
}

class Snoop extends ChangeNotifier with BaseService {
  final _wc = GetIt.instance<Watercooler>();
  final _jeeves = GetIt.instance<Jeeves>();

  draw.Reddit _reddit;
  final String subreddit = 'neoliberal';
  final String postTitle = 'Discussion Thread';
  final String postAuthor = 'jobautomator';

  IngestStatus _status;
  LoginStatus _loginStatus = LoginStatus.loggedOut;
  LoginStatus get loginStatus => _loginStatus;

  StreamSubscription _incoming;

  draw.Submission dtSubmission;
  var dtShortlink;
  DateTime dtExpiration;

  double _ingestRate = 0;
  double get ingestRate => _ingestRate.roundToDouble();
  int _ingestRateCounter = 0;

  int _reconnectCounter = 0;
  int _reconnectMax = 3;

  Timer statusLogTimer;
  static const Duration statusLoggerInterval = Duration(seconds: 90);
  Timer netMonTimer;
  static const Duration netMonInterval = const Duration(seconds: 10000);

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
      this.log.debug('Replies found: $replyTypes');
    }
    final thread = await Thread.fromDrawThread(parent);
    this
        .log
        .debug('Thread built. parent: ${thread.parent.id} with ${thread.replies?.length} replies');
    return thread;
  }

  Stream<Comment> getUserComments([String username]) async* {
    this.log.debug('getUserComments started for $username');
    final r =
        username == null ? await _reddit.user.me() : await _reddit.redditor(username).populate();

    yield* r.comments.newest(limit: 100).asyncMap<Comment>((uc) async {
      if (await _commentIsOnDt(uc as draw.Comment))
        return Comment.fromDrawComment(uc as draw.Comment);
      else
        return null;
    });
  }

  WatercoolerStatus get cacheStatus => _wc.status;
  IngestStatus get status => _status;
  _updateStatus({IngestStatus ingest, LoginStatus login}) {
    if (ingest != null) _status = ingest;
    if (login != null) _loginStatus = login;
    SchedulerBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  Snoop() {
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
    _incoming ?? reconnect();
    return _wc.listenable;
  }

  void netMon(_) async {
    /// keeps an eye on the device's internet connection, responds accordingly
    if (!(await hasInternet)) {
      this.log.warning('no internet connection');
      _incoming?.cancel();
      _updateStatus(ingest: IngestStatus.noConnectionError);
      return;
    }

    if (_status == IngestStatus.reconnecting) {
      this.log.info('still reconnecting... attempt $_reconnectCounter/$_reconnectMax');
      if (_reconnectCounter >= _reconnectMax) {
        _incoming?.cancel();
        _updateStatus(ingest: IngestStatus.noConnectionError);
        _reconnectCounter = 0;
        return;
      } else {
        _reconnectCounter++;
        return;
      }
    }

    if (_status != IngestStatus.connected) {
      this.log.info('connection: $status, attempting reconnect...');
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
    this.log.info('loginStatus: $loginStatus');
  }

  Future<void> reconnect({forceAuth = false}) async {
    this.log.info('attempting reconnect');
    _updateStatus(ingest: IngestStatus.reconnecting);
    await _incoming?.cancel();
    _incoming = null;
    _reddit = await _authReddit(forceAuth: forceAuth);
    notifyListeners();
    _listenForNewComments();
  }

  Future<void> validateDt(draw.Comment c) async {
    /// confirm dt metadata is current and valid
    final isDtExpired = dtExpiration?.isBefore(DateTime.now()) ?? false;
    if (dtShortlink == null || isDtExpired) {
      this.log.debug('currentDt is unknown/expired, checking if submission is DT.');
      draw.Submission post = await c.submission.populate();
      if (post.stickied && post.title == postTitle && post.author == postAuthor) {
        dtSubmission = post;
        dtShortlink = post.shortlink;
        dtExpiration = post.createdUtc.add(Duration(days: 1));
        this.log.debug('new dt: $dtShortlink');
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
    this.log.info('snoop: new comment listener closed (done).');
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
    this.log.error('snoop: new comment stream encountered an error: $e');
    if (e.toString().contains("SocketException"))
      _updateStatus(ingest: IngestStatus.noConnectionError);
    else
      _updateStatus(ingest: IngestStatus.unknownError);
  }

  _listenForNewComments() async {
    /// listens for new comments in the sub and grabs any posted to the DT
    if (_reddit == null) {
      _updateStatus(ingest: IngestStatus.redditAuthError);
    } else {
      _updateStatus(ingest: IngestStatus.connected);
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
  bool get hasAccounts => _jeeves.accounts.length > 0;
  String get loggedInUsername => hasAccounts ? _jeeves.accounts[0].displayName : null;

  Future<void> logout() async {
    _updateStatus(login: LoginStatus.loggingOut);
    _jeeves.clearAccounts();
    await reconnect();
    _updateStatus(login: LoginStatus.loggedOut);
  }

  Future<void> submitReply(String text, {Comment parent}) async {
    if (text.isEmpty) return;

    try {
      if (parent == null)
        dtSubmission.reply(text);
      else
        _reddit.comment(id: parent.id).populate().then((c) => c.reply(text));
      this.log.info('submitted reply: ${text.substring(0, min(text.length, 15))}');
    } catch (exc) {
      this.log.error("unable to submit reply: $exc");
    }
  }

  Future<draw.Reddit> _authReddit({forceAuth = false}) async {
    if (_loginStatus == LoginStatus.loggingIn) return null;
    _updateStatus(login: LoginStatus.loggingIn);
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String versionName = packageInfo.version;
    String versionCode = packageInfo.buildNumber;
    String packageName = packageInfo.packageName;
    final userAgent = 'android:$packageName:v$versionName.$versionCode (by /u/inhumantsar)';
    const clientId = 'GW3D4HqPspIgtA';

    if (forceAuth || _jeeves.accounts.length > 0)
      return await _authAsUser(userAgent, clientId);
    else
      return await _authAsAnon(userAgent, clientId);
  }

  Future<draw.Reddit> _authAsAnon(String userAgent, String clientId) async {
    final deviceId = _jeeves.deviceId;
    this.log.debug("deviceId: $deviceId");
    var reddit;

    try {
      reddit = await draw.Reddit.createUntrustedReadOnlyInstance(
          clientId: clientId, deviceId: deviceId, userAgent: userAgent);
      this.log.info("authed anonymously");
      _loginStatus = LoginStatus.loggedOut;
    } catch (e) {
      this.log.error("unable to auth anonymously: $e");
      _status = IngestStatus.redditAuthError;
    }

    return reddit;
  }

  Future<draw.Reddit> _authAsUser(String userAgent, String clientId) async {
    var reddit;

    if (_jeeves.accounts.length > 0 && (_jeeves.accounts[0].credentials?.isNotEmpty ?? false)) {
      reddit = await _authAsUserViaCache(userAgent, clientId);
    } else {
      reddit = await _authAsUserViaWeb(userAgent, clientId);
    }
    _loginStatus = LoginStatus.loggedIn;
    return reddit;
  }

  Future<draw.Reddit> _authAsUserViaCache(String userAgent, String clientId) async {
    this.log.info('starting reddit authentication process using existing credentials');
    this.log.debug('userAgent: $userAgent');
    this.log.debug('clientId: $clientId');
    var reddit;

    try {
      reddit = draw.Reddit.restoreInstalledAuthenticatedInstance(_jeeves.accounts[0].credentials,
          userAgent: userAgent, clientId: clientId);
    } catch (exc) {
      reddit = _authAsUserViaCacheFallback(userAgent, clientId, exc);
    }

    try {
      reddit.user.me().then((r) => this.log.debug('confirmed user is logged in: ${r.displayName}'));
    } catch (exc) {
      this.log.debug('reddit.user.me() exc encountered:');
      reddit = _authAsUserViaCacheFallback(userAgent, clientId, exc);
    }
    return reddit;
  }

  Future<draw.Reddit> _authAsUserViaCacheFallback(
      String userAgent, String clientId, Exception exc) {
    this.log.error('Unable to restore session from cached creds: $exc');
    _jeeves.addAccount(Redditor.fromMap({'id': _jeeves.accounts[0].id, 'credentials': ''}));
    this.log.info('Cached credentials cleared, retrying login.');
    return _authAsUser(userAgent, clientId);
  }

  Future<draw.Reddit> _authAsUserViaWeb(String userAgent, String clientId) async {
    this.log.info('starting reddit authentication process');
    this.log.debug('userAgent: $userAgent');
    this.log.debug('clientId: $clientId');
    final redirectUri = Uri(scheme: 'taco', host: 'moo', path: 'oauth2redirect');
    final reddit = draw.Reddit.createInstalledFlowInstance(
        userAgent: userAgent,
        // configUri: configUri,
        clientId: clientId,
        redirectUri: redirectUri);
    final authUrl = reddit.auth.url(_scopes, 'tacotrucks');
    this.log.debug('authUrl created: $authUrl');

    // open auth dialog
    var result;
    try {
      result =
          await FlutterWebAuth.authenticate(url: authUrl.toString(), callbackUrlScheme: 'taco');
    } catch (exc) {
      this.log.error('Unable to complete web authentication: $exc');
      return null;
    }
    this.log.debug('FlutterWebAuth complete.');
    final code = Uri.parse(result).queryParameters['code'];
    this.log.debug('Auth code parsed: $code');

    // auth lib and save me obj
    try {
      await reddit.auth.authorize(code);
    } catch (exc) {
      this.log.error('Unable to authorize code with reddit: $exc');
      return null;
    }
    this.log.debug('User authorized');
    reddit.user.me().then((value) {
      _jeeves.addAccount(Redditor.fromDraw(value, reddit.auth.credentials.toJson()));
      this.log.debug('User stored.');
      notifyListeners();
    });
    return reddit;
  }

  List<String> get _scopes => [
        // 'creddits',
        // 'modcontributors',
        // 'modmail',
        // 'modconfig',
        // 'subscribe',
        // 'structuredstyles',
        // 'vote',
        // 'wikiedit',
        // 'mysubreddits',
        'submit',
        // 'modlog',
        // 'modposts',
        // 'modflair',
        // 'save',
        // 'modothers',
        'read',
        // 'privatemessages',
        // 'report',
        'identity',
        // 'livemanage',
        // 'account',
        // 'modtraffic',
        // 'wikiread',
        'edit',
        // 'modwiki',
        // 'modself',
        'history',
        // 'flair',
      ];
}
