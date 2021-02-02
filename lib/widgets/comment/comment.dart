import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:tacostream/core/base/logger.dart';
import 'package:tacostream/models/comment.dart';
import 'package:tacostream/services/snoop.dart';
import 'package:tacostream/services/theme.dart';
import 'package:tacostream/views/thread/thread.dart';
import 'package:tacostream/widgets/author/author.dart';
import 'package:tacostream/widgets/parent/parent.dart';
import 'package:url_launcher/url_launcher.dart';

class CommentWidget extends StatelessWidget {
  final Comment comment;
  final bool showFlair;
  final bool showParent;
  final bool highlight;
  final int level;
  final ThemeData theme;
  final MarkdownStyleSheet mdTheme;
  final log = BaseLogger('CommentWidget');

  CommentWidget(
      {this.comment,
      this.showFlair = true,
      this.showParent = true,
      this.level = 1,
      this.highlight = false,
      this.theme,
      this.mdTheme});

  static Comment get dummyComment => new Comment(
      author: 'theRealDubya',
      authorFlairImageUrl: 'https://emoji.redditmedia.com/1uhosge0o2231_t5_2sfn3/nato',
      authorFlairText: 'NATO',
      body: """🦀🦀🦀 😤😤😤 🇨🇦🇨🇦🇨🇦

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse hendrerit nulla ac metus euismod luctus.

# Lorem ipsum
            """,
      parentId: "");

  _launchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = comment ?? dummyComment;

    return Consumer2<Snoop, ThemeService>(builder: (context, snoop, ts, widget) {
      final t = this.theme ?? Theme.of(context);
      return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            log.debug('Opening thread view with comment: ${c.runtimeType} ${c.id}');
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => ThreadView(c)));
          },
          child: Container(
            color: highlight ? t.colorScheme.primaryVariant : null,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // if parent_id starts with t1, then this is a reply and we
                  // should fetch the parent
                  showParent &&
                          c.parentId.startsWith('t1_') &&
                          snoop.commentIds.contains(c.parentId.substring(3))
                      ? Container(
                          margin: EdgeInsets.fromLTRB(12, 4, 12, 12),
                          child: ParentWidget(
                              child: c,
                              customMarkdownSS: this.mdTheme ?? ts.mdTheme,
                              customTheme: t),
                        )
                      : SizedBox.shrink(),
                  Row(children: [
                    Expanded(
                        child: MarkdownBody(
                      // fitContent: false,
                      styleSheet: mdTheme ?? ts.mdTheme,
                      data: c.body ?? "",
                      onTapLink: (text, href, title) => _launchUrl(href),
                    ))
                  ]),
                  GestureDetector(
                      onTap: () => _launchUrl("https://reddit.com/u/" + c.author),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 4, 4, 0),
                          child: Author(c.author, c.authorFlairText, c.authorFlairImageUrl,
                              customTheme: t),
                        ),
                      ))
                ])),
          ));
    });
  }
}
