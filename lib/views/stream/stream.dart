import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:tacostream/core/base/logger.dart';

import 'package:tacostream/services/snoop.dart';
import 'package:tacostream/services/theme.dart';
import 'package:tacostream/services/watercooler.dart';
import 'package:tacostream/widgets/comment/comment.dart';
import 'package:tacostream/views/settings/settings.dart';
import 'package:tacostream/widgets/reconnect/reconnect.dart';
import 'package:tacostream/widgets/submit/submit.dart';

class StreamView extends StatefulWidget {
  @override
  _StreamViewState createState() => _StreamViewState();
}

class _StreamViewState extends State<StreamView> {
  bool pinToTop = true;
  IconData pinIcon = FontAwesomeIcons.arrowCircleUp;
  ScrollController scrollController;
  bool showSubmitArea = false;
  final log = BaseLogger('StreamView');

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
      pinToTop = !pinToTop;
      pinIcon = pinToTop ? FontAwesomeIcons.arrowCircleUp : FontAwesomeIcons.arrowAltCircleUp;
    });
    if (pinToTop) animateToTop();
  }

  @override
  Widget build(BuildContext context) {
    final primaryVariant = Theme.of(context).colorScheme.primaryVariant;
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return Consumer3<Watercooler, ThemeService, Snoop>(builder: (context, wc, ts, snoop, widget) {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.color, // really?
            title: Text("🌮 tacostream"),
            actions: [
              IconButton(
                icon: Icon(FontAwesomeIcons.cog),
                color: secondary,
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => SettingsView())),
              ),
              IconButton(
                  icon: Icon(ts.darkMode ? Icons.lightbulb_outline : Icons.lightbulb),
                  color: ts.darkMode ? Theme.of(context).disabledColor : secondary,
                  onPressed: ts.toggleDarkMode),
              IconButton(
                icon: Icon(pinIcon),
                color: pinToTop ? secondary : Theme.of(context).disabledColor,
                onPressed: togglePin,
              )
            ],
          ),
          body: Center(
              child: ValueListenableBuilder(
                  valueListenable: snoop.listenable,
                  builder: (context, Box box, _) {
                    if (snoop.status == IngestStatus.noConnectionError ||
                        snoop.status == IngestStatus.redditAuthError) {
                      return ReconnectWidget();
                    }

                    if (wc.length < 5 ||
                        wc.status == WatercoolerStatus.clearing ||
                        snoop.status == IngestStatus.reconnecting ||
                        snoop.loginStatus == LoginStatus.loggingIn) {
                      return Center(
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                        SpinKitDoubleBounce(
                            color: secondary, size: 300.0, duration: Duration(seconds: 6)),
                        SizedBox.fromSize(
                          size: Size(10, 30),
                        ),
                      ]));
                    }

                    return Stack(alignment: AlignmentDirectional.bottomCenter, children: [
                      Container(
                          alignment: Alignment.topLeft,
                          child: ListView.separated(
                              separatorBuilder: (ctx, _) => Divider(),
                              controller: this.scrollController,
                              padding: EdgeInsets.all(0),
                              shrinkWrap: true,
                              reverse: true,
                              itemCount: wc.length,
                              itemBuilder: (context, index) {
                                try {
                                  if (pinToTop)
                                    SchedulerBinding.instance
                                        .addPostFrameCallback((_) => animateToTop());
                                } catch (e) {
                                  print(e);
                                }

                                return CommentWidget(comment: wc.values.elementAt(index));
                              })),
                      snoop.loginStatus == LoginStatus.loggedIn ? SubmitWidget() : SizedBox.shrink()
                    ]);
                  })));
    });
  }
}
