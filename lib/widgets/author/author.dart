import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';

class Author extends StatelessWidget {
  final String author;
  final String flairText;
  final String flairImageUrl;
  final ThemeData customTheme;

  Author(this.author, this.flairText, this.flairImageUrl, {this.customTheme});

  @override
  Widget build(BuildContext context) {
    final themeData = customTheme ?? Theme.of(context);

    return Wrap(
        direction: Axis.horizontal,
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
              child: Text(
                this.author,
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: themeData.colorScheme.secondaryVariant, fontWeight: FontWeight.bold),
              )),
          this.flairImageUrl == null || this.flairImageUrl.isEmpty
              ? SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                  child: Image(image: NetworkImage(this.flairImageUrl), width: 25)),
          this.flairText == null || this.flairText.isEmpty
              ? SizedBox.shrink()
              : Text(flairText, style: themeData.textTheme.caption),
        ]);
  }
}
