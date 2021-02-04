import 'package:flutter/material.dart';

import 'package:tacostream/core/base/logger.dart';
import 'package:tacostream/models/thread.dart';
import 'package:tacostream/widgets/comment/comment.dart';

class ThreadWidget extends StatelessWidget {
  final Thread thread;
  final int level;
  final String highlightId;
  final log = BaseLogger('ThreadWidget');

  ThreadWidget(this.thread, this.level, {this.highlightId});

  @override
  Widget build(BuildContext context) {
    final deco = BoxDecoration(
        border: Border(
            left: BorderSide(
      color: Theme.of(context).dividerColor,
    )));

    if (thread == null) return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(8.0 * level, 0, 0, 0),
      child: Container(
        decoration: level == 0 ? null : deco,
        child: Padding(
          padding: EdgeInsets.fromLTRB(0, level == 1 ? 8 : 0, 0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommentWidget(
                  comment: thread.parent,
                  showParent: false,
                  highlight: thread.parent.id == highlightId),
              ListView.builder(
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: thread.replies.length,
                  itemBuilder: (ctx, idx) =>
                      ThreadWidget(thread.replies[idx], level + 1, highlightId: highlightId))
            ],
          ),
        ),
      ),
    );
  }
}
