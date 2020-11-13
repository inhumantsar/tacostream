import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:tacostream/models/comment.dart';
import 'package:tacostream/services/jeremiah.dart';
import 'package:url_launcher/url_launcher.dart';

class StreamView extends StatelessWidget {
  static final flairRegex = new RegExp(r":([-a-zA-Z0-9]+):(.+)");

  _launchUrl(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Jeremiah>(
      builder: (context, jeremiah, widget) => StreamBuilder<List<Comment>>(
          initialData: List<Comment>(),
          stream: jeremiah.streamComments(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return SizedBox.shrink();

            return ListView.builder(
                padding: EdgeInsets.all(0),
                // physics: ScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  var comment = snapshot.data[index];
                  var matches = flairRegex.allMatches(comment.authorFlairText);
                  var flairName;
                  var flairText;
                  var flairImage;

                  if (matches.length > 0) {
                    flairName = matches.elementAt(0).group(1);
                    flairText = matches.elementAt(0).group(2);
                    flairImage = Image.asset(
                      "assets/flairs/_" + flairName + ".png",
                      width: 25,
                    );
                  } else {
                    flairName = "";
                    flairText = "";
                    flairImage = SizedBox.shrink();
                  }

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
                                data: comment.body,
                                onTapLink: (text, href, title) =>
                                    _launchUrl(href),
                              ))
                            ]),
                            Padding(
                                padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                                child: Container(
                                  height: 25,
                                  child: Row(children: [
                                    Text(
                                      comment.author,
                                      textScaleFactor: .8,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            4.0, 0, 0, 0),
                                        child: flairImage),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          2.0, 0, 0, 0),
                                      child: Text(
                                        flairText,
                                        textScaleFactor: .8,
                                        textAlign: TextAlign.start,
                                      ),
                                    )
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
          }),
    );
  }
}
