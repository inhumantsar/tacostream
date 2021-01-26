import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import 'package:get_it/get_it.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';

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

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController(keepScrollOffset: false);
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection == ScrollDirection.forward && pinToTop) {
        togglePin();
      }
      if (atMaxExtent() && !pinToTop) {
        togglePin();
      }
    });
  }

  @override
  void dispose() {
    this.jeremiah.close();
    this.scrollController.dispose();
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
      this.scrollController.animateTo(this.scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
  }

  void togglePin() {
    setState(() {
      pinToTop = pinToTop ? false : true;
      pinIcon = pinToTop ? FontAwesomeIcons.arrowCircleUp : FontAwesomeIcons.arrowAltCircleUp;
    });
    if (pinToTop) animateToTop();
  }

  @override
  Widget build(BuildContext context) {
    var pinColor = pinToTop ? Theme.of(context).accentColor : Theme.of(context).disabledColor;

    return Scaffold(
      appBar: AppBar(
        title: Text("🌮 tacostream"),
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.cog),
            color: Theme.of(context).accentColor,
            onPressed: () =>
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingsView())),
          ),
          IconButton(
              icon: Icon(themeService.darkMode ? Icons.lightbulb_outline : Icons.lightbulb),
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
          child: ValueListenableBuilder(
              valueListenable: this.jeremiah.listenable,
              builder: (context, Box box, _) {
                if (this.jeremiah.error == JeremiahError.NoConnection ||
                    this.jeremiah.error == JeremiahError.NoRedditAuth) {
                  final now = DateTime.now();
                  var reconnectText = now.isAfter(this.jeremiah.nextReconnectTime)
                      ? 'Reconnect'
                      : 'Reconnect in ${now.difference(this.jeremiah.nextReconnectTime).inSeconds} seconds...';
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
                    Text("Looks like Reddit is down or this device is offline.",
                        style: Theme.of(context).textTheme.bodyText2),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: RawMaterialButton(
                        elevation: 2,
                        fillColor: Theme.of(context).colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
                          child: Flex(
                              mainAxisSize: MainAxisSize.min,
                              direction: Axis.horizontal,
                              children: [
                                Icon(FontAwesomeIcons.redoAlt),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(reconnectText,
                                      style: Theme.of(context).textTheme.button),
                                )
                              ]),
                        ),
                        onPressed: this.jeremiah.reconnect,
                      ),
                    )
                  ]));
                }

                if (box.isEmpty) {
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

                return Container(
                  alignment: Alignment.topLeft,
                  child: ListView.builder(
                      // key: ObjectKey(streamController.values[0]),
                      controller: this.scrollController,
                      padding: EdgeInsets.all(0),
                      shrinkWrap: true,
                      reverse: true,
                      itemCount: box.values.length,
                      itemBuilder: (context, index) {
                        var comment = box.values.elementAt(index);
                        try {
                          if (pinToTop)
                            SchedulerBinding.instance.addPostFrameCallback((_) => animateToTop());
                        } catch (e) {
                          print(e);
                        }

                        return CommentWidget(comment: comment);
                      }),
                );
              })),
    );
  }
}
