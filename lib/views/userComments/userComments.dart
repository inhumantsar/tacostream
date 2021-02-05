import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:provider/provider.dart';

import 'package:tacostream/core/base/logger.dart';
import 'package:tacostream/models/comment.dart';
import 'package:tacostream/services/snoop.dart';
import 'package:tacostream/services/theme.dart';
import 'package:tacostream/widgets/comment/comment.dart';

class UserCommentsView extends StatelessWidget {
  final String username;
  final log = BaseLogger('UserCommentsView');

  UserCommentsView([this.username]);

  @override
  Widget build(BuildContext context) {
    return Consumer2<Snoop, ThemeService>(builder: (context, snoop, ts, widget) {
      return Scaffold(
          appBar: AppBar(
            title: Text(this.username ?? snoop.loggedInUsername),
            backgroundColor: Theme.of(context).appBarTheme.color, // really?
            actions: [],
          ),
          body: SingleChildScrollView(
            child: FutureBuilder<List<Comment>>(
                future: snoop.getUserComments(this.username).where((c) => c != null).toList(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final cList = snapshot.data;
                    log.debug('got ${cList.length} comments');

                    return ListView.separated(
                        separatorBuilder: (ctx, _) => Divider(),
                        physics: ScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: cList.length,
                        itemBuilder: (ctx, idx) => CommentWidget(
                              comment: cList[idx],
                              showReplyButton: false,
                            ));
                  }

                  if (snapshot.hasError) return Text('error: ${snapshot.error}');

                  return Center(
                    child: SpinKitDoubleBounce(
                        color: Theme.of(context).accentColor,
                        size: 300.0,
                        duration: Duration(seconds: 6)),
                  );
                }),
          ));
    });
  }
}
