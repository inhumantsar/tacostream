import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Jeremiah - Comment stream

import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:tacostream/core/base/service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tacostream/models/comment.dart';

class Jeremiah extends ChangeNotifier with BaseService {
  final _fs = FirebaseFirestore.instanceFor(app: Firebase.app());
  var _controller;
  http.Client _httpClient;
  final indexedCache = Map<String, Comment>();

  ReplaySubject get controller {
    _streamComments();
    return _controller;
  }

  void close() {
    _httpClient.close();
    _controller.close();
  }

  // TODO at start of stream, grab oldest comments's date time and start downloading
  //      comments older than that, adding them to the bottom of the stream as they're fetched
  //      and stopping when we hit the local cache or timedelta hits 24hrs.
  //      when/if the user scrolls to minextent, we can start loading from the cache

  /// streams all of a user's `Objective`s
  Future<void> _streamComments({int attempt = 0}) async {
    _controller ??= ReplaySubject<Comment>();

    // init input and output streams as necessary
    _httpClient = http.Client();

    http.Request request = http.Request(
        "GET", Uri.parse('http://tacostream-sse.samsite.ca:3000/'));
    request.headers["Accept"] = "text/event-stream";
    request.headers["Cache-Control"] = "no-cache";
    request.headers["Connection"] = "keep-alive";

    Future<http.StreamedResponse> response = _httpClient.send(request);
    print("Subscribed!");
    response.catchError((err) {
      _httpClient.close();
      if (attempt >= 10) {
        _controller.addError(http.ClientException(
            'Unable to contact server after 10 attempts.'));
      }
      print('error caught: $err. retrying in ${attempt * attempt}s...');
      if (attempt > 0) sleep(Duration(seconds: attempt * attempt));
      _streamComments(attempt: attempt + 1);
    }).then(
      (streamedResponse) {
        if (streamedResponse == null) {
          print('response is null');
          return;
        }
        streamedResponse.stream.listen(
          (value) {
            var decodedData;
            var parsedData;
            try {
              decodedData =
                  utf8.decode(value, allowMalformed: true).substring(5);
            } catch (e) {
              print("unable to decode response: $value");
            }
            try {
              parsedData = json.decode(decodedData) as Map<String, dynamic>;
            } catch (e) {
              print("unable to parse json: $decodedData");
            }

            if (parsedData != null) {
              final comment = Comment.fromMap(parsedData);
              indexedCache[comment.id] = comment;
              if (indexedCache.length % 100 == 0)
                print("status: ${indexedCache.length} items in cache");
              _controller.add(indexedCache[comment.id]);
            }
          },
          onDone: () {
            _httpClient.close();
            _controller.close();
            print("The streamresponse is ended");
          },
        );
      },
    );
  }
}
