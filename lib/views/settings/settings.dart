import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tacostream/services/theme.dart';
import 'package:get_it/get_it.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tacostream/widgets/comment/comment.dart';
import 'package:clippy_flutter/clippy_flutter.dart';

class SettingsView extends StatelessWidget {
  ThemeService themeService = GetIt.instance<ThemeService>();

  static Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [],
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.fromLTRB(8, 16, 8, 4),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text('Account', style: Theme.of(context).textTheme.bodyText1),
                  Spacer(),
                  Text('Sign in to your Reddit account to post and reply.',
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
                Row(children: [
                  Text('Themes', style: Theme.of(context).textTheme.bodyText1),
                  IconButton(
                      padding: EdgeInsets.all(3),
                      iconSize: 18,
                      icon: Icon(themeService.darkMode ? Icons.lightbulb : Icons.lightbulb_outline),
                      color: Theme.of(context).colorScheme.onSurface,
                      onPressed: themeService.toggleDarkMode),
                  Spacer(),
                  Text('Dress for the life you want.', style: Theme.of(context).textTheme.caption)
                ]),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                  child: Container(
                    height: 300,
                    child: ListView.builder(
                        shrinkWrap: true,
                        // scrollDirection: Axis.horizontal,
                        itemCount: themeService.themes.length,
                        itemBuilder: (context, index) {
                          final theme = themeService.themes[index];
                          return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                              child: Stack(
                                alignment: AlignmentDirectional.topEnd,
                                children: [
                                  // Padding(
                                  //   padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  //   child:
                                  ListTile(
                                      title: Container(
                                          padding: EdgeInsets.fromLTRB(6, 4, 0, 0),
                                          height: 28,
                                          color: theme.light.colorScheme.primary,
                                          child: Text(
                                            '🌮 tacostream',
                                            style: theme.light.textTheme.bodyText1,
                                          )),
                                      subtitle: Container(
                                          color: theme.light.scaffoldBackgroundColor,
                                          child: CommentWidget(
                                              customTheme: theme.light,
                                              customMarkdownSS: theme.markdownLight))),
                                  // ),
                                  // Padding(
                                  //     padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  //     child:
                                  Diagonal(
                                      clipHeight: 250.0,
                                      axis: Axis.horizontal,
                                      position: DiagonalPosition.BOTTOM_LEFT,
                                      child: ListTile(
                                          title: Container(
                                              padding: EdgeInsets.fromLTRB(6, 4, 0, 0),
                                              height: 28,
                                              color: lighten(theme.dark.colorScheme.surface, .08),
                                              child: Text(
                                                '🌮 tacostream',
                                                style: theme.dark.textTheme.bodyText1,
                                              )),
                                          subtitle: Container(
                                              color: theme.dark.scaffoldBackgroundColor,
                                              child: CommentWidget(
                                                  customTheme: theme.dark,
                                                  customMarkdownSS: theme.markdownDark)))), //),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RawMaterialButton(
                                        padding: EdgeInsets.all(3),
                                        shape: CircleBorder(),
                                        child: Icon(
                                            themeService.currentBaseTheme.name == theme.name
                                                ? FontAwesomeIcons.solidCheckCircle
                                                : FontAwesomeIcons.circle,
                                            size: 16),
                                        fillColor: Theme.of(context).colorScheme.surface,
                                        onPressed: () => themeService.setTheme(theme.name)),
                                  ),
                                ],
                              ));
                        }),
                  ),
                ),
                Divider(),
                Text('About & Privacy', style: Theme.of(context).textTheme.bodyText1),
                Text('Written in 🍁 with ❤️ by inhumantsar. ',
                    style: Theme.of(context).textTheme.caption),
                Text("No personal information is ever accessed or stored.",
                    style: Theme.of(context).textTheme.caption),
                Text("I'm not responsible for anything which gets posted.",
                    style: Theme.of(context).textTheme.caption),
                Text("Feel free to contact me anytime with bugs or suggestions.",
                    style: Theme.of(context).textTheme.caption),
              ])),
        ));
  }
}
