import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        body: Consumer2<Watercooler, ThemeService>(
            builder: (context, watercooler, themeService, widget) => SingleChildScrollView(
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(8, 16, 8, 4),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Text('Account', style: Theme.of(context).textTheme.bodyText1),
                          Spacer(),
                          Text('Sign in to post and reply.',
                              style: Theme.of(context).textTheme.caption)
                        ]),
                        Center(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: RaisedButton(
                              color: Theme.of(context).buttonColor,
                              onPressed: null,
                              child: Flex(
                                  direction: Axis.horizontal,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(FontAwesomeIcons.reddit),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text('Coming Soon'),
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
                                          fillColor: themeService.fontSize == FontSize.large
                                              ? Theme.of(context).colorScheme.secondary
                                              : Theme.of(context).colorScheme.surface,
                                          onPressed: () => themeService.fontSize = FontSize.large,
                                          shape: CircleBorder())),
                                  Flexible(
                                      flex: 1,
                                      child: RawMaterialButton(
                                          child: Text('A',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2
                                                  .copyWith(fontSize: 18)),
                                          fillColor: themeService.fontSize == FontSize.medium
                                              ? Theme.of(context).colorScheme.secondary
                                              : Theme.of(context).colorScheme.surface,
                                          onPressed: () => themeService.fontSize = FontSize.medium,
                                          shape: CircleBorder())),
                                  Flexible(
                                      flex: 1,
                                      child: RawMaterialButton(
                                          child: Text('A',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2
                                                  .copyWith(fontSize: 14)),
                                          fillColor: themeService.fontSize == FontSize.small
                                              ? Theme.of(context).colorScheme.secondary
                                              : Theme.of(context).colorScheme.surface,
                                          onPressed: () => themeService.fontSize = FontSize.small,
                                          shape: CircleBorder())),
                                ])),
                            Divider(),
                            FlatButton(
                              onPressed: themeService.toggleDarkMode,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                                // padding: const EdgeInsets.all(8.0),
                                child: Row(children: [
                                  Text(
                                      themeService.darkMode
                                          ? 'Switch to Light mode'
                                          : 'Switch to Dark mode',
                                      style: Theme.of(context).textTheme.button),
                                  Spacer(),
                                  RawMaterialButton(
                                      child: Icon(
                                          themeService.darkMode
                                              ? Icons.lightbulb
                                              : Icons.lightbulb_outline,
                                          size: 18),
                                      fillColor: themeService.darkMode
                                          ? Theme.of(context).colorScheme.primaryVariant
                                          : Theme.of(context).colorScheme.surface,
                                      onPressed: themeService.toggleDarkMode,
                                      shape: CircleBorder()),
                                ]),
                              ),
                            )
                          ],
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Themes'),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Cache pruning interval:'),
                              Text('Maybe just leave this one alone.',
                                  style: themeService.theme.textTheme.caption)
                            ]),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: new DropdownButton<int>(
                                value: watercooler.pruneInterval,
                                items: <int>[20, 300, 86400].map((int value) {
                                  return new DropdownMenuItem<int>(
                                    value: value,
                                    child: new Text(value.toString()),
                                  );
                                }).toList(),
                                onChanged: (value) => watercooler.pruneInterval = value,
                              ),
                            ),
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Cache limit:'),
                              Text('Lower is Faster', style: themeService.theme.textTheme.caption)
                            ]),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: new DropdownButton<int>(
                                value: watercooler.maxCacheSize,
                                items: <int>[100, 1000, 10000, 100000].map((int value) {
                                  return new DropdownMenuItem<int>(
                                    value: value,
                                    child: new Text(value.toString()),
                                  );
                                }).toList(),
                                onChanged: (value) => watercooler.maxCacheSize = value,
                              ),
                            ),
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
                              onTap: () => watercooler.clearCacheAtStartup =
                                  !watercooler.clearCacheAtStartup,
                              child: Row(children: [
                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('Clear cache at startup'),
                                ]),
                                const Spacer(),
                                Checkbox(
                                    value: watercooler.clearCacheAtStartup,
                                    onChanged: (value) => watercooler.clearCacheAtStartup = value),
                                // Text('', style: themeService.theme.textTheme.caption)
                              ])),
                        ),

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
