import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:tacostream/services/flairmoji.dart';

class Flair extends StatelessWidget {
  final String flairText;
  final String flairImageUrl;

  Flair(this.flairText, this.flairImageUrl);

  @override
  Widget build(BuildContext context) {
    var widgets = <Widget>[];

    if (this.flairImageUrl != null && this.flairImageUrl != "") {
      widgets.add(
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
            child: Image(image: NetworkImage(this.flairImageUrl), width: 25)),
      );
    }
    if (this.flairText != null) {
      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
        child: AutoSizeText(flairText,
            maxLines: 1,
            textScaleFactor: .9,
            textAlign: TextAlign.start,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withAlpha(130))),
      ));
    }

    return Flex(
      direction: Axis.horizontal,
      children: widgets,
    );
  }
}
