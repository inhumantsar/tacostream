import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tacostream/core/base/logger.dart';
import 'package:tacostream/services/snoop.dart';
import 'package:tacostream/services/theme.dart';

class SubmitWidget extends StatefulWidget {
  SubmitWidget();

  @override
  _SubmitWidgetState createState() => _SubmitWidgetState();
}

class _SubmitWidgetState extends State<SubmitWidget> {
  final log = BaseLogger('SubmitWidget');
  bool showSubmitArea = false;
  bool submitRO = false;
  double _inputHeight = 50;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textEditingController.addListener(_checkInputHeight);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _checkInputHeight() async {
    int count = _textEditingController.text.split('\n').length;

    if (count == 0 && _inputHeight == 50.0) {
      return;
    }
    if (count <= 5) {
      // use a maximum height of 6 rows
      // height values can be adapted based on the font size
      var newHeight = count == 0 ? 50.0 : 28.0 + (count * 18.0);
      setState(() {
        _inputHeight = newHeight;
      });
    }
  }

  void toggleSubmit() {
    _textEditingController.clear();
    setState(() {
      showSubmitArea = !showSubmitArea;
    });
  }

  set readOnly(val) => setState(() => submitRO = val);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return Consumer<Snoop>(builder: (context, snoop, widget) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            // transitionBuilder: AnimatedSwitcher.defaultTransitionBuilder,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position:
                    Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset(0, 0)).animate(animation),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
              // return ScaleTransition(child: child, scale: animation);
            },
            child: showSubmitArea
                ? Material(
                    elevation: 3,
                    color: primary,
                    borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(4.0), right: Radius.circular(4.0)),
                    clipBehavior: Clip.antiAlias,
                    child: Row(
                      children: [
                        IconButton(
                          // padding: const EdgeInsets.all(0),
                          visualDensity: VisualDensity.compact,
                          icon: Icon(Icons.cancel),
                          color: secondary,
                          onPressed: toggleSubmit,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 4.0, 0, 12),
                            child: TextField(
                              readOnly: submitRO,
                              style:
                                  Theme.of(context).textTheme.bodyText1.copyWith(color: onPrimary),
                              decoration: InputDecoration(
                                  isDense: true,
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: secondary))),
                              controller: _textEditingController,
                              textInputAction: TextInputAction.newline,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                            ),
                          ),
                        ),
                        IconButton(
                            padding: const EdgeInsets.all(0),
                            icon: Icon(Icons.send),
                            visualDensity: VisualDensity.compact,
                            color: secondary,
                            onPressed: () {
                              readOnly = true;
                              snoop.submitReply(_textEditingController.text).then((_) {
                                _textEditingController.clear();
                                readOnly = false;
                              });
                            })
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Material(
                            elevation: 3,
                            color: primary,
                            shape: CircleBorder(),
                            child: IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.all(0),
                              icon: Icon(FontAwesomeIcons.solidCommentAlt),
                              color: secondary,
                              onPressed: toggleSubmit,
                            ))
                      ],
                    ))),
      );
    });
  }
}
