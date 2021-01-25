// Jeremiah - DT Streaming

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:tacostream/core/base/service.dart';
import 'package:tacostream/models/comment.dart' as taco;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:draw/draw.dart';

class Jeremiah extends ChangeNotifier with BaseService {
  final Box<taco.Comment> _box;
  final Reddit _reddit;
  final String subreddit = 'neoliberal';
  final String postTitle = 'Discussion Thread';
  final String postAuthor = 'jobautomator';
  StreamSubscription _incoming;
  var currentDtShortlink;
  var _hasError = false;

  Jeremiah(this._box, this._reddit);

  Listenable get listenable {
    this._incoming ?? _listenForNewComments();
    return _box.listenable();
  }

  Iterable<taco.Comment> get comments => _box.values;
  List get commentIds => _box.keys.toList();

  taco.Comment getCommentById(String id) => _box.get(id);

  bool get hasError => this._hasError;

  void close() {
    this._incoming?.cancel();
  }

  Future<void> _freshenComments(List<String> commentIds) {
    /// reload comment data from reddit and update the box
  }

  Future<void> _prune({Duration maxAge}) {
    /// start at the oldest entries in the box and prune any whose creation date > maxAge old
  }

  Future<void> _processNewComment(Comment c) async {
    /// stores comments if they are on the DT
    // check if this comment's parent submission is the DT
    if (this.currentDtShortlink == null) {
      log.debug('jeremiah: currentDtShortlink is null, checking if comment submission is DT.');
      Submission post = await c.submission.populate();
      if (post.stickied && post.title == this.postTitle && post.author == this.postAuthor) {
        log.debug('jeremiah: comment submission is DT, setting currentDtShortlink.');
        this.currentDtShortlink = post.shortlink;
      }
    }
    // store comment
    if (c.submission.shortlink == this.currentDtShortlink) {
      if (c.data == null) await c.populate();
      // log.debug('jeremiah: putting comment: $c');
      final comment = taco.Comment.fromDrawComment(c);

      this._box.put(c.id, comment);
    }
  }

  _listenForNewComments() {
    /// listens for new comments in the sub and grabs any posted to the DT
    this._incoming = this
        ._reddit
        .subreddit(this.subreddit)
        .stream
        .comments(pauseAfter: 10)
        .listen((Comment c) => this._processNewComment(c), onError: (e) {
      this._hasError = true;
      log.error('jeremiah: new comment stream encountered an error: $e');
    }, onDone: () {
      log.info('jeremiah: new comment listener closed (done).');
      this._listenForNewComments();
    });
  }

  Future<void> _crawlPastComments() {
    /// chug through comments from `before` the first one streamed in
    /// https://pub.dev/documentation/draw/latest/draw/CommentForest-class.html
  }
}
