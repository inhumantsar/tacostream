import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tacostream/services/snoop.dart';
import 'package:tacostream/services/theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tacostream/services/watercooler.dart';
import 'package:tacostream/widgets/theme_picker/theme_picker.dart';

class SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [],
        ),
        body: Consumer3<Snoop, Watercooler, ThemeService>(
            builder: (context, snoop, wc, ts, widget) => SingleChildScrollView(
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(8, 16, 8, 4),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          //
                          // login / logout
                          //
                          Text('Account', style: Theme.of(context).textTheme.bodyText1),
                          Spacer(),
                          Text(
                              snoop.loginStatus == LoginStatus.loggedIn
                                  ? snoop.loggedInRedditorname != null
                                      ? 'Signed in as ${snoop.loggedInRedditorname}'
                                      : 'Signing in...'
                                  : 'Sign in to post and reply.',
                              style: Theme.of(context).textTheme.caption)
                        ]),
                        Center(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: RaisedButton(
                              color: Theme.of(context).buttonColor,
                              onPressed: snoop.loginStatus == LoginStatus.loggingIn ||
                                      snoop.loginStatus == LoginStatus.loggingOut
                                  ? null
                                  : () => snoop.loginStatus == LoginStatus.loggedIn
                                      ? snoop.logout()
                                      : snoop.reconnect(forceAuth: true),
                              child: Flex(
                                  direction: Axis.horizontal,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(FontAwesomeIcons.reddit),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: snoop.loginStatus == LoginStatus.loggingIn ||
                                              snoop.loginStatus == LoginStatus.loggingOut
                                          ? Text('Please wait...')
                                          : snoop.loginStatus == LoginStatus.loggedIn
                                              ? Text('Sign Out')
                                              : Text('Sign in with Reddit'),
                                    )
                                  ])),
                        )),
                        Divider(),
                        Row(children: [
                          Text('Appearance', style: Theme.of(context).textTheme.bodyText1),
                          Spacer(),
                          Text('Dress for the life you want.',
                              style: Theme.of(context).textTheme.caption)
                        ]),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            //
                            // font size
                            //
                            Padding(
                                padding: const EdgeInsets.fromLTRB(25, 8, 25, 8),
                                child: Flex(direction: Axis.horizontal, children: [
                                  Expanded(
                                      flex: 5,
                                      child: Text('Font size',
                                          style: Theme.of(context).textTheme.button)),
                                  Flexible(
                                      flex: 1,
                                      child: RawMaterialButton(
                                          child: Text('A',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2
                                                  .copyWith(fontSize: 24)),
                                          fillColor: ts.fontSize == FontSize.large
                                              ? Theme.of(context).colorScheme.secondary
                                              : Theme.of(context).colorScheme.surface,
                                          onPressed: () => ts.fontSize = FontSize.large,
                                          shape: CircleBorder())),
                                  Flexible(
                                      flex: 1,
                                      child: RawMaterialButton(
                                          child: Text('A',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2
                                                  .copyWith(fontSize: 18)),
                                          fillColor: ts.fontSize == FontSize.medium
                                              ? Theme.of(context).colorScheme.secondary
                                              : Theme.of(context).colorScheme.surface,
                                          onPressed: () => ts.fontSize = FontSize.medium,
                                          shape: CircleBorder())),
                                  Flexible(
                                      flex: 1,
                                      child: RawMaterialButton(
                                          child: Text('A',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2
                                                  .copyWith(fontSize: 14)),
                                          fillColor: ts.fontSize == FontSize.small
                                              ? Theme.of(context).colorScheme.secondary
                                              : Theme.of(context).colorScheme.surface,
                                          onPressed: () => ts.fontSize = FontSize.small,
                                          shape: CircleBorder())),
                                ])),
                            Divider(),
                            //
                            // dark mode
                            //
                            FlatButton(
                              onPressed: ts.toggleDarkMode,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                                // padding: const EdgeInsets.all(8.0),
                                child: Row(children: [
                                  Text(ts.darkMode ? 'Switch to Light mode' : 'Switch to Dark mode',
                                      style: Theme.of(context).textTheme.button),
                                  Spacer(),
                                  RawMaterialButton(
                                      child: Icon(
                                          ts.darkMode ? Icons.lightbulb : Icons.lightbulb_outline,
                                          size: 18),
                                      fillColor: ts.darkMode
                                          ? Theme.of(context).colorScheme.primaryVariant
                                          : Theme.of(context).colorScheme.surface,
                                      onPressed: ts.toggleDarkMode,
                                      shape: CircleBorder()),
                                ]),
                              ),
                            )
                          ],
                        ),
                        Divider(),
                        //
                        // theme
                        //
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Theme'),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                          child: ThemePickerWidget(),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('Advanced', style: Theme.of(context).textTheme.bodyText1),
                        ),
                        //
                        // cache settings
                        //
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Cache pruning interval:'),
                              Text('Maybe just leave this one alone.',
                                  style: ts.theme.textTheme.caption)
                            ]),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: new DropdownButton<int>(
                                value: wc.pruneInterval,
                                items: <int>[20, 300, 86400].map((int value) {
                                  return new DropdownMenuItem<int>(
                                    value: value,
                                    child: new Text(value.toString()),
                                  );
                                }).toList(),
                                onChanged: (value) => wc.pruneInterval = value,
                              ),
                            ),
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Cache limit:'),
                              Text('Lower is Faster', style: ts.theme.textTheme.caption)
                            ]),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: new DropdownButton<int>(
                                value: wc.maxCacheSize,
                                items: <int>[100, 1000, 10000, 100000].map((int value) {
                                  return new DropdownMenuItem<int>(
                                    value: value,
                                    child: new Text(value.toString()),
                                  );
                                }).toList(),
                                onChanged: (value) => wc.maxCacheSize = value,
                              ),
                            ),
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
                              onTap: () => wc.clearCacheAtStartup = !wc.clearCacheAtStartup,
                              child: Row(children: [
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('Clear cache at startup'),
                                ]),
                                const Spacer(),
                                Checkbox(
                                    value: wc.clearCacheAtStartup,
                                    onChanged: (value) => wc.clearCacheAtStartup = value),
                              ])),
                        ),

                        //
                        // horizontal card list
                        //
                        // Divider(),
                        // Row(children: [
                        //   Text('Cards', style: Theme.of(context).textTheme.bodyText1),
                        //   Spacer(),
                        //   Text('Cheeky cliche.', style: Theme.of(context).textTheme.caption)
                        // ]),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                        //   child: Container(
                        //       height: 200,
                        //       child: ListView.builder(
                        //           shrinkWrap: true,
                        //           scrollDirection: Axis.horizontal,
                        //           itemCount: cards.length,
                        //           itemBuilder: (context, index) => Padding(
                        //               padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                        //               child: Container(
                        //                   width: 150,
                        //                   child: Card(
                        //                       // color: Colors.white,
                        //                       child: Padding(
                        //                     padding: const EdgeInsets.all(8.0),
                        //                     child: Column(children: [
                        //                       MarkdownBody(data: cards[index]),
                        //                     ]),
                        //                   )))))),
                        // ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child:
                              Text('About & Privacy', style: Theme.of(context).textTheme.bodyText1),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text('Written in 🇨🇦 with ❤️ by /u/inhumantsar. ',
                              style: Theme.of(context).textTheme.caption),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text("No personal information is ever accessed or stored.",
                              style: Theme.of(context).textTheme.caption),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text("I'm not responsible for anything which gets posted.",
                              style: Theme.of(context).textTheme.caption),
                        ),
                      ])),
                )));
  }
}
