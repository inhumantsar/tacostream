import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tacostream/core/base/logger.dart';
import 'package:tacostream/models/comment.dart';
import 'package:tacostream/services/snoop.dart';
import 'package:tacostream/services/theme.dart';
import 'package:tacostream/views/thread/thread.dart';
import 'package:tacostream/widgets/author/author.dart';
import 'package:tacostream/widgets/comment/reply.dart';
import 'package:tacostream/widgets/parent/parent.dart';
import 'package:url_launcher/url_launcher.dart';

class CommentWidget extends StatefulWidget {
  final Comment comment;
  final bool showFlair;
  final bool showParent;

  /// lightly highlight one comment in a thread
  final bool highlight;

  /// force a custom theme (for theme picker mainly)
  final ThemeData theme;

  /// force a custom markdown theme (for theme picker mainly)
  final MarkdownStyleSheet mdTheme;

  CommentWidget(
      {this.comment,
      this.showFlair = true,
      this.showParent = true,
      this.highlight = false,
      this.theme,
      this.mdTheme});

  /// dummy comment in case [comment] is null. (for theme picker mainly)
  static Comment get dummyComment => new Comment(
      author: 'theRealDubya',
      authorFlairImageUrl: 'https://emoji.redditmedia.com/1uhosge0o2231_t5_2sfn3/nato',
      authorFlairText: 'NATO',
      body:
          """🦀🦀🦀 😤😤😤 🇨🇦🇨🇦🇨🇦

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse hendrerit nulla ac metus euismod luctus.

# Lorem ipsum
            """,
      parentId: "");

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  final log = BaseLogger('CommentWidget');
  bool showReplyArea = false;

  _launchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void replyCallback() {
    // reload thread?
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<Snoop, ThemeService>(builder: (context, snoop, ts, widget) {
      final c = this.widget.comment ?? CommentWidget.dummyComment;
      final t = this.widget.theme ?? Theme.of(context);

      return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            log.debug('Opening thread view with comment: ${c.runtimeType} ${c.id}');
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => ThreadView(c)));
          },
          child: Container(
              color: this.widget.highlight ? t.colorScheme.primaryVariant : null,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    // fetch parent if parent != the dt itself
                    this.widget.showParent &&
                            c.parentId.startsWith('t1_') &&
                            snoop.commentIds.contains(c.parentId.substring(3))
                        ? Container(
                            margin: EdgeInsets.fromLTRB(12, 4, 12, 12),
                            child: ParentWidget(
                                child: c,
                                customMarkdownSS: this.widget.mdTheme ?? ts.mdTheme,
                                customTheme: t),
                          )
                        : SizedBox.shrink(),

                    // main comment body
                    Row(children: [
                      Expanded(
                          child: MarkdownBody(
                        styleSheet: this.widget.mdTheme ?? ts.mdTheme,
                        data: c.body ?? "",
                        onTapLink: (text, href, title) => _launchUrl(href),
                      ))
                    ]),
                    Flex(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        direction: Axis.horizontal,
                        children: [
                          // author
                          Expanded(
                              child: GestureDetector(
                                  onTap: () => _launchUrl("https://reddit.com/u/" + c.author),
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 4, 4, 0),
                                      child: Author(
                                          c.author, c.authorFlairText, c.authorFlairImageUrl,
                                          customTheme: t),
                                    ),
                                  ))),

                          // reply toggle button
                          Container(
                              height: 25,
                              width: 70,
                              child: RawMaterialButton(
                                onPressed: () =>
                                    setState(() => this.showReplyArea = !this.showReplyArea),
                                child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(this.showReplyArea ? 'Cancel' : 'Reply',
                                          textScaleFactor: 0.9, style: t.textTheme.caption),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                        child: Icon(
                                            this.showReplyArea
                                                ? Icons.cancel_outlined
                                                : FontAwesomeIcons.reply,
                                            size: 16,
                                            color: t.colorScheme.onSurface.withOpacity(.5)),
                                      ),
                                    ]),
                              ))
                        ]),

                    // reply area
                    AnimatedSwitcher(
                        duration: const Duration(milliseconds: 150),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return SlideTransition(
                            position: Tween<Offset>(begin: Offset(0.0, 0.1), end: Offset(0, 0))
                                .animate(animation),
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: this.showReplyArea
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ReplyWidget(c, replyCallback),
                              )
                            : SizedBox.shrink())
                  ]))));
    });
  }
}
