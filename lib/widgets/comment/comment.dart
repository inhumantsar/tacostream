import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:tacostream/models/comment.dart';
import 'package:tacostream/services/jeremiah.dart';
import 'package:tacostream/services/theme.dart';
import 'package:tacostream/widgets/author/author.dart';
import 'package:tacostream/widgets/parent/parent.dart';
import 'package:url_launcher/url_launcher.dart';

class CommentWidget extends StatelessWidget {
  final Comment comment;
  final bool showFlair;
  final int level;
  final ThemeData theme;
  final MarkdownStyleSheet mdTheme;

  const CommentWidget(
      {this.comment, this.showFlair = true, this.level = 1, this.theme, this.mdTheme});

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

    return level > 4
        ? SizedBox.shrink()
        : Consumer2<Jeremiah, ThemeService>(builder: (context, jeremiah, themeService, widget) {
            return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _launchUrl("https://reddit.com" + c.permalink),
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    child:
                        Flex(direction: Axis.vertical, mainAxisSize: MainAxisSize.min, children: [
                      // if parent_id starts with t1, then this is a reply and we
                      // should fetch the parent
                      !c.parentId.startsWith('t1_') ||
                              !jeremiah.commentIds.contains(c.parentId.substring(3))
                          ? SizedBox.shrink()
                          : Container(
                              margin: EdgeInsets.fromLTRB(12, 4, 12, 12),
                              child: ParentWidget(
                                  child: c,
                                  customMarkdownSS: this.mdTheme ?? themeService.mdTheme,
                                  customTheme: this.theme ?? themeService.theme),
                            ),
                      Row(children: [
                        Expanded(
                            child: MarkdownBody(
                          styleSheet: mdTheme ?? themeService.mdTheme,
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
                                  customTheme: theme),
                            ),
                          ))
                    ]),
                  ),
                  Divider(),
                ]));
          });
  }
}
