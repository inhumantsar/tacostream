import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
  var controller = ReplaySubject<Comment>();
  final indexedCache = Map<String, Comment>();

  void close() {
    controller.close();
  }

  // TODO at start of stream, grab oldest comments's date time and start downloading
  //      comments older than that, adding them to the bottom of the stream as they're fetched
  //      and stopping when we hit the local cache or timedelta hits 24hrs.
  //      when/if the user scrolls to minextent, we can start loading from the cache

  /// streams all of a user's `Objective`s
  ReplaySubject streamComments({int attempt = 0}) {
    // init input and output streams as necessary
    http.Client client = http.Client();

    http.Request request =
        http.Request("GET", Uri.parse('http://tacostream-sse.samsite.ca:3000'));
    request.headers["Accept"] = "text/event-stream";
    request.headers["Cache-Control"] = "no-cache";

    Future<http.StreamedResponse> response = client.send(request);
    print("Subscribed!");
    response.catchError((_) {
      if (attempt >= 10)
        throw (http.ClientException('Unable to contact server.'));
      if (attempt > 0) sleep(Duration(seconds: attempt * attempt));
      streamComments(attempt: attempt + 1);
    }).then(
      (streamedResponse) => streamedResponse.stream.listen(
        (value) {
          var parsedData;
          try {
            parsedData = json.decode(
                    utf8.decode(value, allowMalformed: true).substring(5))
                as Map<String, dynamic>;
          } catch (e) {
            print("unable to decode response: $value");
          }

          if (parsedData != null) {
            final comment = Comment.fromMap(parsedData);
            indexedCache[comment.id] = comment;
            if (indexedCache.length % 100 == 0)
              print("status: ${indexedCache.length} items in cache");
            controller.add(indexedCache[comment.id]);
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
