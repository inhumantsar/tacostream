import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:tacostream/models/comment.dart';
import 'package:tacostream/services/flairmoji.dart';
import 'package:tacostream/services/jeremiah.dart';
import 'package:tacostream/services/theme.dart';
import 'package:tacostream/widgets/flair/flair.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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

  _launchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    jeremiah.streamComments();
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
    jeremiah.close();
    this.scrollController.dispose();
    super.dispose();
  }

  bool atMaxExtent() {
    if (!scrollController.hasClients ||
        (scrollController.offset >= scrollController.position.maxScrollExtent &&
            !scrollController.position.outOfRange)) {
      return true;
    } else {
      return false;
    }
  }

  bool atMinExtent() {
    if (!scrollController.hasClients ||
        (scrollController.offset <= scrollController.position.minScrollExtent &&
            !scrollController.position.outOfRange)) {
      return true;
    } else {
      return false;
    }
  }

  // TODO: add scroll controller. measure window height, if diff from last window height, autoadjust to maintain position

  void animateToTop() => this.scrollController.animateTo(
      this.scrollController.position.maxScrollExtent,
      duration: Duration(
          milliseconds: (500 *
                  (1 +
                      this.scrollController.offset /
                          this.scrollController.position.maxScrollExtent))
              .round()),
      curve: Curves.fastOutSlowIn);

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
    var streamController = jeremiah.controller;
    var pinColor = pinToTop
        ? Theme.of(context).accentColor
        : Theme.of(context).disabledColor;

    return Scaffold(
      appBar: AppBar(
        title: Text("🌮 tacostream"),
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.palette),
            color: Theme.of(context).accentColor,
            onPressed: themeService.shuffleTheme,
          ),
          IconButton(
              icon: Icon(themeService.darkMode
                  ? Icons.lightbulb
                  : Icons.lightbulb_outline),
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
                return !snapshot.hasData
                    ? SizedBox.shrink()
                    : ListView.builder(
                        key: ObjectKey(streamController.values[0]),
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
                            if (!atMaxExtent() && pinToTop) {
                              animateToTop();
                            }
                          } catch(e) {print(e);}
                          return GestureDetector(
                            onTap: () => _launchUrl(comment.permalink),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                              child: Flex(
                                  direction: Axis.vertical,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(children: [
                                      Expanded(
                                          child: MarkdownBody(
                                        styleSheet:
                                            MarkdownStyleSheet.fromTheme(
                                                Theme.of(context)),
                                        data: comment.body,
                                        onTapLink: (text, href, title) =>
                                            _launchUrl(href),
                                      ))
                                    ]),
                                    Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 4, 0, 0),
                                        child: Container(
                                          height: 25,
                                          child: Row(children: [
                                            Text(
                                              comment.author,
                                              textScaleFactor: .8,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondaryVariant,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Flair(comment.authorFlairText)
                                          ]),
                                        ))
                                  ]),
                            ),
                          );

                          // ListTile(
                          //   isThreeLine: true,
                          //   onTap: () =>
                          //       _launchUrl("https://reddit.com" + comment.permalink),
                          //   contentPadding:
                          //       EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                          //   title: Text(comment.author),
                          //   subtitle: Text(comment.body),
                          // );
                        });
              })),
    );
  }
}
