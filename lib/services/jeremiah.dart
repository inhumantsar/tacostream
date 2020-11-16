import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Jeremiah - Objectives and individual goals

import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:tacostream/core/base/service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tacostream/models/comment.dart';

/// DB: Objectives and Goals
class Jeremiah extends ChangeNotifier with BaseService {
  final _fs = FirebaseFirestore.instanceFor(app: Firebase.app());
  final controller = ReplaySubject<Comment>();
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

  void close() {
    controller.close();
  }

  /// streams all of a user's `Objective`s
  ReplaySubject streamComments() {
    // init input and output streams as necessary
    http.Client client = http.Client();

    http.Request request =
        http.Request("GET", Uri.parse('http://tacostream-sse.samsite.ca:3000'));
    request.headers["Accept"] = "text/event-stream";
    request.headers["Cache-Control"] = "no-cache";

    Future<http.StreamedResponse> response = client.send(request);
    print("Subscribed!");
    response.then(
      (streamedResponse) => streamedResponse.stream.listen(
        (value) {
          final parsedData =
              json.decode(utf8.decode(value, allowMalformed: true).substring(5))
                  as Map<String, dynamic>;
          if (parsedData != null) {
            controller.add(Comment.fromMap(parsedData));
          }
        },
        onDone: () {
          controller.close();
          print("The streamresponse is ended");
        },
      ),
    );
    return controller;
  }
}
