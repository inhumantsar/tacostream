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
import 'package:tacostream/views/userComments/userComments.dart';
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
  bool _showSubmitArea = false;
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

  get showSubmitArea => _showSubmitArea;
  set showSubmitArea(val) {
    setState(() => _showSubmitArea = val);
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
    final secondary = Theme.of(context).colorScheme.secondary;

    return Consumer3<Watercooler, ThemeService, Snoop>(builder: (context, wc, ts, snoop, widget) {
      return Scaffold(
          appBar: AppBar(
              backgroundColor: Theme.of(context).appBarTheme.color, // really?
              title: Text("🌮 tacostream"),
              actions: [
                // settings
                IconButton(
                  icon: Icon(FontAwesomeIcons.cog),
                  color: secondary,
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => SettingsView())),
                ),
                // logged in user's comments
                IconButton(
                  padding: const EdgeInsets.all(0),
                  icon: Icon(FontAwesomeIcons.comment),
                  color: secondary,
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => UserCommentsView())),
                ), // top level comment entry
                IconButton(
                  padding: const EdgeInsets.all(0),
                  icon: Icon(showSubmitArea
                      ? FontAwesomeIcons.plusSquare
                      : FontAwesomeIcons.solidPlusSquare),
                  color: secondary,
                  onPressed: () => setState(() => showSubmitArea = !showSubmitArea),
                ),
                // scroll to top toggle
                IconButton(
                  icon: Icon(pinIcon),
                  color: pinToTop ? secondary : Theme.of(context).disabledColor,
                  onPressed: togglePin,
                ),
              ]),
          body: Center(
              child: ValueListenableBuilder(
                  // box listenable gives us a stream to work with
                  valueListenable: snoop.listenable,
                  builder: (context, Box box, _) {
                    // reconnect panel
                    if (snoop.status == IngestStatus.noConnectionError ||
                        snoop.status == IngestStatus.redditAuthError) {
                      return ReconnectWidget();
                    }

                    // throbber
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
                      // comment list
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

                      // top level comment entry
                      snoop.loginStatus == LoginStatus.loggedIn
                          ? AnimatedSwitcher(
                              duration: const Duration(milliseconds: 150),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return SlideTransition(
                                  position:
                                      Tween<Offset>(begin: Offset(0.0, 0.1), end: Offset(0, 0))
                                          .animate(animation),
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: showSubmitArea
                                  ? SubmitWidget(() => this.showSubmitArea = false)
                                  : SizedBox.shrink())
                          : SizedBox.shrink()
                    ]);
                  })));
    });
  }
}
