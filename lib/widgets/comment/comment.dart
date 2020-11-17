import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:tacostream/models/comment.dart';
import 'package:tacostream/services/jeremiah.dart';
import 'package:tacostream/services/theme.dart';
import 'package:tacostream/widgets/flair/flair.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CommentWidget extends StatelessWidget {
  final Comment comment;
  final bool showFlair;
  final int level;

  const CommentWidget(this.comment,
      {Key key, this.showFlair = true, this.level = 1})
      : super(key: key);

  _launchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return level > 4
        ? SizedBox.shrink()
        : Consumer2<Jeremiah, ThemeService>(
            builder: (context, jeremiah, themeService, widget) =>
                GestureDetector(
              onTap: () => _launchUrl("https://reddit.com" + comment.permalink),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Flex(
                    direction: Axis.vertical,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // if parent_id starts with t1, then this is a reply and we
                      // should fetch the parent
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: !comment.parentId.startsWith('t1_') ||
                                !jeremiah.indexedCache
                                    .containsKey(comment.parentId.substring(3))
                            ? SizedBox.shrink()
                            : Row(children: [
                                Flexible(
                                    flex: 1,
                                    child: Icon(FontAwesomeIcons.quoteLeft,
                                        color:
                                            Theme.of(context).disabledColor)),
                                Flexible(
                                    flex: 12,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          jeremiah
                                                  .indexedCache[comment.parentId
                                                      .substring(3)]
                                                  ?.body ??
                                              "null parent: ${comment.parentId.substring(3)}",
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          textScaleFactor: 0.8,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .disabledColor)),
                                    ))
                              ]),
                      ),
                      Row(children: [
                        Expanded(
                            child: MarkdownBody(
                          styleSheet: themeService.currentMarkdown,
                          data: comment.body,
                          onTapLink: (text, href, title) => _launchUrl(href),
                        ))
                      ]),
                      Flex(direction: Axis.horizontal, children: [
                        Text(
                          comment.author,
                          textScaleFactor: .8, //* (1.5 / level),
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryVariant,
                              fontWeight: FontWeight.bold),
                        ),
                        showFlair
                            ? Expanded(child: Flair(comment.authorFlairText))
                            : SizedBox.shrink()
                      ]),
                    ]),
              ),
            ),
          );
  }
}
