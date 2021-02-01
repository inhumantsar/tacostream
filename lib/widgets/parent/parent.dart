import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:tacostream/models/comment.dart';
import 'package:tacostream/services/jeremiah.dart';
import 'package:tacostream/services/theme.dart';
import 'package:tacostream/views/thread/thread.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ParentWidget extends StatelessWidget {
  final Comment child;
  final ThemeData customTheme;
  final MarkdownStyleSheet customMarkdownSS;

  const ParentWidget({this.child, this.customTheme, this.customMarkdownSS});

  _launchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<Jeremiah, ThemeService>(builder: (context, jeremiah, themeService, widget) {
      final ThemeData themeData = this.customTheme ?? Theme.of(context);
      var markdownSS = customMarkdownSS ?? themeService.mdTheme;
      markdownSS = markdownSS.copyWith(p: themeData.textTheme.caption);

      final parent = jeremiah.getCommentById(child.parentId.substring(3));
      var parentBody =
          parent.body.length < 280 ? parent.body : parent.body.substring(0, 280) + '...';

      return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            log.debug('Opening thread view with quoted parent: ${parent.runtimeType} ${parent.id}');
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => ThreadView(parent)));
          },
          child: Stack(children: [
            Icon(FontAwesomeIcons.quoteLeft,
                size: 48, color: themeData.disabledColor.withOpacity(0.1)),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                    child: MarkdownBody(
                        onTapLink: (text, href, title) => _launchUrl(href),
                        styleSheet: markdownSS,
                        data: parentBody),
                  ))
                ]),
                Row(children: [
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                          child: Text(parent.author,
                              textScaleFactor: .9,
                              style: themeData.textTheme.caption
                                  .copyWith(fontWeight: FontWeight.bold))))
                ])
              ],
            )
          ]));
    });
  }
}
