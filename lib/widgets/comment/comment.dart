import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:tacostream/core/base/theme.dart';
import 'package:tacostream/models/comment.dart';
import 'package:tacostream/services/jeremiah.dart';
import 'package:tacostream/services/theme.dart';
import 'package:tacostream/widgets/flair/flair.dart';
import 'package:tacostream/widgets/parent/parent.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CommentWidget extends StatelessWidget {
  final Comment comment;
  final bool showFlair;
  final int level;
  final ThemeData customTheme;
  final MarkdownStyleSheet customMarkdownSS;

  const CommentWidget(
      {this.comment,
      this.showFlair = true,
      this.level = 1,
      this.customTheme,
      this.customMarkdownSS});

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
    final themeData = this.customTheme ?? Theme.of(context);

    return level > 4
        ? SizedBox.shrink()
        : Consumer2<Jeremiah, ThemeService>(builder: (context, jeremiah, themeService, widget) {
            var markdownSS = customMarkdownSS ?? themeService.currentMarkdown;
            markdownSS = markdownSS.copyWith(textScaleFactor: 1.2);

            return GestureDetector(
              onTap: () => _launchUrl("https://reddit.com" + c.permalink),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Flex(direction: Axis.vertical, mainAxisSize: MainAxisSize.min, children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    // if parent_id starts with t1, then this is a reply and we
                    // should fetch the parent
                    child: !c.parentId.startsWith('t1_') ||
                            !jeremiah.commentIds.contains(c.parentId.substring(3))
                        ? SizedBox.shrink()
                        : ParentWidget(
                            child: c,
                            customMarkdownSS: customMarkdownSS ?? themeService.currentMarkdown,
                            customTheme: customTheme ?? themeService.currentTheme),
                  ),
                  Row(children: [
                    Expanded(
                        child: MarkdownBody(
                      styleSheet: markdownSS,
                      data: c.body ?? "",
                      onTapLink: (text, href, title) => _launchUrl(href),
                    ))
                  ]),
                  Flex(direction: Axis.horizontal, children: [
                    Text(
                      c.author,
                      textScaleFactor: 1, //* (1.5 / level),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: themeData.colorScheme.secondaryVariant,
                          fontWeight: FontWeight.bold),
                    ),
                    showFlair
                        ? Container(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            height: 35,
                            child: Flair(c.authorFlairText, c.authorFlairImageUrl))
                        : SizedBox.fromSize()
                  ]),
                ]),
              ),
            );
          });
  }
}
