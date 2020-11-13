import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Jeremiah - Objectives and individual goals

import 'package:flutter/material.dart';
import 'package:tacostream/core/base/service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tacostream/models/comment.dart';

/// DB: Objectives and Goals
class Jeremiah extends ChangeNotifier with BaseService {
  final _fs = FirebaseFirestore.instanceFor(app: Firebase.app());
  StreamController controller;
  StreamSubscription<QuerySnapshot> streamSubscription;

  CollectionReference _comments() => _fs.collection('comments');

  // /// streams a `Objective`
  // Stream<Objective> streamObjective(String id) {
  //   // init input and output streams as necessary
  //   if (!this._objectiveCtrls.containsKey(id) ||
  //       this._objectiveCtrls[id] == null)
  //     this._objectiveCtrls[id] = BehaviorSubject();
  //   if (!this._docSubs.containsKey(id) || this._docSubs[id] == null)
  //     this._docSubs[id] = _comments().doc(id).snapshots().listen((data) =>
  //         this._objectiveCtrls[id].add(Objective.fromMap(data.data())));

  //   return this._objectiveCtrls[id].stream;
  // }

  /// streams all of a user's `Objective`s
  Stream<List<Comment>> streamComments() {
    // init input and output streams as necessary
    this.controller = BehaviorSubject<List<Comment>>();
    this.streamSubscription = _comments()
        .orderBy('CreatedUTC', descending: true)
        .limit(100)
        .snapshots()
        .listen((data) => controller
            .add(data.docs.map((doc) => Comment.fromMap(doc.data())).toList()));

    return this.controller.stream;
  }
}
