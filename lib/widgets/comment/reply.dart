import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tacostream/core/base/logger.dart';
import 'package:tacostream/models/comment.dart';
import 'package:tacostream/services/snoop.dart';
import 'package:tacostream/widgets/comment/comment.dart';

class ReplyWidget extends StatefulWidget {
  /// inline reply entry for comments

  final Comment comment;
  final Function callback;
  ReplyWidget(this.comment, this.callback);

  @override
  _ReplyWidgetState createState() => _ReplyWidgetState();
}

class _ReplyWidgetState extends State<ReplyWidget> {
  final log = BaseLogger('ReplyWidget');
  bool _readOnly = false;
  bool _replyComplete = false;
  double inputHeight = 50;
  final textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textEditingController.addListener(_checkInputHeight);
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  void _checkInputHeight() async {
    int count = textEditingController.text.split('\n').length;

    if (count == 0 && inputHeight == 50.0) {
      return;
    }
    if (count <= 5) {
      // use a maximum height of 6 rows
      // height values can be adapted based on the font size
      var newHeight = count == 0 ? 50.0 : 28.0 + (count * 18.0);
      setState(() {
        inputHeight = newHeight;
      });
    }
  }

  get readOnly => _readOnly;
  set readOnly(val) => setState(() => _readOnly = val);

  get replyComplete => _replyComplete;
  set replyComplete(val) => setState(() => _replyComplete = val);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return Consumer<Snoop>(builder: (context, snoop, widget) {
      if (replyComplete) {
        return CommentWidget(
            comment:
                new Comment(author: snoop.loggedInRedditorname, body: textEditingController.text),
            showParent: false,
            showReplyButton: false);
      } else {
        return Padding(
            padding: const EdgeInsets.all(0),
            child: Material(
              elevation: 3,
              color: readOnly ? Theme.of(context).colorScheme.surface : primary,
              borderRadius:
                  BorderRadius.horizontal(left: Radius.circular(4.0), right: Radius.circular(4.0)),
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  // text field
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4.0, 0, 12),
                      child: TextField(
                        autofocus: true,
                        readOnly: _readOnly,
                        style: Theme.of(context).textTheme.bodyText1.copyWith(color: onPrimary),
                        decoration: InputDecoration(
                            isDense: true,
                            focusedBorder:
                                UnderlineInputBorder(borderSide: BorderSide(color: secondary))),
                        controller: textEditingController,
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                      ),
                    ),
                  ),
                  // submit button
                  IconButton(
                      padding: const EdgeInsets.all(0),
                      icon: Icon(Icons.send),
                      visualDensity: VisualDensity.compact,
                      color: secondary,
                      onPressed: readOnly
                          ? null
                          : () {
                              readOnly = true;
                              snoop
                                  .submitReply(textEditingController.text,
                                      parent: this.widget.comment)
                                  .then((_) {
                                replyComplete = true;
                                this.widget.callback();
                              });
                            })
                ],
              ),
            ));
      }
    });
  }
}
