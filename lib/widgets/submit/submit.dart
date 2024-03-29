import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tacostream/core/base/logger.dart';
import 'package:tacostream/services/snoop.dart';

class SubmitWidget extends StatefulWidget {
  /// Offer text field for submitting top-level comments.
  final Function callback;

  SubmitWidget([this.callback]);

  @override
  _SubmitWidgetState createState() => _SubmitWidgetState();
}

class _SubmitWidgetState extends State<SubmitWidget> {
  final log = BaseLogger('SubmitWidget');
  bool showSubmitArea = false;
  bool _readOnly = false;
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

    if (count == 0 && _inputHeight == 50.0) return;
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

  set readOnly(val) => setState(() => _readOnly = val);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return Consumer<Snoop>(builder: (context, snoop, widget) {
      return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Material(
            elevation: 3,
            color: primary,
            borderRadius:
                BorderRadius.horizontal(left: Radius.circular(4.0), right: Radius.circular(4.0)),
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                // text area
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
                      controller: _textEditingController,
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
                    onPressed: () {
                      readOnly = true;
                      snoop.submitReply(_textEditingController.text).then((_) {
                        _textEditingController.clear();
                        readOnly = false;
                        toggleSubmit();
                        this.widget.callback();
                      });
                    })
              ],
            ),
          ));
    });
  }
}
