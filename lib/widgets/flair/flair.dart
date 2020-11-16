import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tacostream/services/flairmoji.dart';

class Flair extends StatelessWidget {
  final String rawFlairText;
  final flairmojiRegex = new RegExp(r":([-a-zA-Z0-9]+):");

  Flair(this.rawFlairText);

  @override
  Widget build(BuildContext context) {
    var widgets = <Widget>[];

    for (var element in rawFlairText.split(':')) {
      var flairText = element.trim();
      // add image if there's a flairmoji match
      if (flairmoji.containsKey(flairText)) {
        widgets.add(
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
              child:
                  Image(image: NetworkImage(flairmoji[flairText]), width: 25)),
        );
        // add text otherwise
      } else {
        widgets.add(Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
            child: Text(flairText,
                textScaleFactor: .8,
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withAlpha(130)))));
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 2),
      child: Row(
        children: widgets,
      ),
    );
  }
}
