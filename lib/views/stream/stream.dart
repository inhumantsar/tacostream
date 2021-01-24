import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import 'package:get_it/get_it.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tacostream/models/comment.dart';

import 'package:tacostream/services/jeremiah.dart';
import 'package:tacostream/services/theme.dart';
import 'package:tacostream/widgets/comment/comment.dart';
import 'package:tacostream/views/settings/settings.dart';

class StreamView extends StatefulWidget {
  @override
  _StreamViewState createState() => _StreamViewState();
}

class _StreamViewState extends State<StreamView> {
  Jeremiah jeremiah = GetIt.instance<Jeremiah>();
  ThemeService themeService = GetIt.instance<ThemeService>();
  bool pinToTop = true;
  IconData pinIcon = FontAwesomeIcons.arrowCircleUp;
  ScrollController scrollController;
  ReplaySubject<Comment> streamController;

  @override
  void initState() {
    super.initState();
    streamController = jeremiah.controller;
    scrollController = ScrollController(keepScrollOffset: false);
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
              ScrollDirection.forward &&
          pinToTop) {
        togglePin();
      }
      if (atMaxExtent() && !pinToTop) {
        togglePin();
      }
    });
  }

  @override
  void dispose() {
    this.streamController.close();
    this.scrollController.dispose();
    jeremiah.close();
    super.dispose();
  }

  bool atMaxExtent() {
    if (!scrollController.hasClients) return false;
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      return true;
    } else {
      return false;
    }
  }

  bool atMinExtent() {
    if (!scrollController.hasClients) return false;
    if (scrollController.offset <= scrollController.position.minScrollExtent &&
        !scrollController.position.outOfRange) {
      return true;
    } else {
      return false;
    }
  }

  // TODO: add scroll controller. measure window height, if diff from last window height, autoadjust to maintain position

  void animateToTop() {
    if (!atMaxExtent() && !scrollController.position.isScrollingNotifier.value)
      this.scrollController.animateTo(
          this.scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn);
  }

  void togglePin() {
    setState(() {
      pinToTop = pinToTop ? false : true;
      pinIcon = pinToTop
          ? FontAwesomeIcons.arrowCircleUp
          : FontAwesomeIcons.arrowAltCircleUp;
    });
    if (pinToTop) animateToTop();
  }

  @override
  Widget build(BuildContext context) {
    var pinColor = pinToTop
        ? Theme.of(context).accentColor
        : Theme.of(context).disabledColor;

    return Scaffold(
      appBar: AppBar(
        title: Text("🌮 tacostream"),
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.cog),
            color: Theme.of(context).accentColor,
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => SettingsView())),
          ),
          IconButton(
            icon: Icon(FontAwesomeIcons.palette),
            color: Theme.of(context).accentColor,
            onPressed: themeService.shuffleTheme,
          ),
          IconButton(
              icon: Icon(themeService.darkMode
                  ? Icons.lightbulb_outline
                  : Icons.lightbulb),
              color: themeService.darkMode
                  ? Theme.of(context).disabledColor
                  : Theme.of(context).accentColor,
              onPressed: themeService.toggleDarkMode),
          IconButton(
            icon: Icon(pinIcon),
            color: pinColor,
            onPressed: togglePin,
          )
        ],
      ),
      body: Center(
          child: StreamBuilder<Object>(
              stream: streamController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      Icons.wifi_off,
                      size: 200,
                      color: Theme.of(context).disabledColor,
                    ),
                    Text(
                      "Sorry about that!",
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    SizedBox.fromSize(
                      size: Size(10, 10),
                    ),
                    Text(
                        "Looks like our servers are down or this device is offline.",
                        style: Theme.of(context).textTheme.bodyText2)
                  ]));
                }

                if (!snapshot.hasData) {
                  return Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                    SpinKitDoubleBounce(
                        color: Theme.of(context).accentColor,
                        size: 100.0,
                        duration: Duration(seconds: 10)),
                    SizedBox.fromSize(
                      size: Size(10, 30),
                    ),
                  ]));
                }

                return ListView.builder(
                    // key: ObjectKey(streamController.values[0]),
                    controller: this.scrollController,
                    padding: EdgeInsets.all(0),
                    shrinkWrap: true,
                    reverse: true,
                    itemCount: streamController.values.length,
                    itemBuilder: (context, index) {
                      if (streamController.values.length == 0 ||
                          streamController.values[index] == null) {
                        return SizedBox.shrink();
                      }

                      var comment = streamController.values[index];
                      try {
                        if (pinToTop)
                          SchedulerBinding.instance
                              .addPostFrameCallback((_) => animateToTop());
                      } catch (e) {
                        print(e);
                      }

                      return CommentWidget(comment);
                    });
              })),
    );
  }
}
