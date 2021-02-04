import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tacostream/services/snoop.dart';

class ReconnectWidget extends StatelessWidget {
  /// A generic "oops" panel for connection issues

  @override
  Widget build(BuildContext context) {
    return Consumer<Snoop>(
      builder: (context, snoop, widget) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(
          Icons.wifi_off,
          size: 200,
          color: Theme.of(context).disabledColor,
        ),
        Text(
          "Sorry about that!",
          style: Theme.of(context).textTheme.headline5,
        ),
        SizedBox.fromSize(
          size: Size(10, 10),
        ),
        Text("Looks like we're having some trouble.", style: Theme.of(context).textTheme.bodyText2),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: RawMaterialButton(
            elevation: 2,
            fillColor: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
              child: Flex(mainAxisSize: MainAxisSize.min, direction: Axis.horizontal, children: [
                Icon(FontAwesomeIcons.redoAlt,
                    color: (snoop.status == IngestStatus.reconnecting)
                        ? Theme.of(context).disabledColor
                        : Theme.of(context).textTheme.button.color),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      (snoop.status == IngestStatus.reconnecting ||
                              snoop.loginStatus == LoginStatus.loggingIn)
                          ? 'Reconnecting...'
                          : 'Reconnect',
                      style: Theme.of(context).textTheme.button.copyWith(
                          color: (snoop.status == IngestStatus.reconnecting)
                              ? Theme.of(context).disabledColor
                              : Theme.of(context).textTheme.button.color)),
                )
              ]),
            ),
            onPressed: (snoop.status == IngestStatus.reconnecting) ? null : snoop.reconnect,
          ),
        )
      ])),
    );
  }
}
