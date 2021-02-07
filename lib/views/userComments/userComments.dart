import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:tacostream/core/base/logger.dart';
import 'package:tacostream/services/snoop.dart';
import 'package:tacostream/services/theme.dart';
import 'package:tacostream/widgets/comment/comment.dart';

class RedditorCommentsView extends StatelessWidget {
  final String username;
  final log = BaseLogger('RedditorCommentsView');

  RedditorCommentsView([this.username]);

  @override
  Widget build(BuildContext context) {
    return Consumer2<Snoop, ThemeService>(builder: (context, snoop, ts, widget) {
      final cList = snoop.getRedditorComments(this.username).values;

      return Scaffold(
          appBar: AppBar(
            title: Text(this.username ?? snoop.loggedInRedditorname),
            backgroundColor: Theme.of(context).appBarTheme.color, // really?
            actions: [],
          ),
          body: SingleChildScrollView(
            child: ListView.separated(
                separatorBuilder: (ctx, _) => Divider(),
                physics: ScrollPhysics(),
                shrinkWrap: true,
                itemCount: cList.length,
                itemBuilder: (ctx, idx) => CommentWidget(
                      comment: cList[idx],
                      showReplyButton: false,
                      showParent: true,
                    )),
          ));
    });
  }
}
