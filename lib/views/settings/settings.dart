import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tacostream/services/theme.dart';
import 'package:get_it/get_it.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsView extends StatelessWidget {
  ThemeService themeService = GetIt.instance<ThemeService>();
  var features = [
    """
#### Basic

Comment in-app

Stats and leaderboards

#### \$16 annually
""",
    """
#### Pro

Basic unlocks plus...

Quick access to copypasta, shoutouts, GIFs and more.

All current and future theme packs

#### \$24 annually
""",
    """
#### Big Tipper

Pro unlocks plus...

An actual thank you card from yours truly. 

Maybe some kick ass stickers and shit.

#### \$38 annually
""",
    """
#### MOSQUITOBANE

The Big Tipper plus...

\$20 to charity

Special MOSQUITOBANE theme pack

#### \$64 annually
""",
    """
#### Daddy Soros

MOSQUITOBANE plus...

2x CHARITY MULTIPLIER!

Special in-app shoutout

Custom theme pack with your name on it

#### \$150 annually
""",
  ];
  var themePacks = [
    """
#### Eurozone Theme Pack

Icons and colours for ALL Eurozone countries
  
#### \$12 one-time
""",
    """
#### MURICA Theme Pack

ROCK FLAG AND EAGLE

#### \$3 one-time
""",
    """
#### Canada Theme Pack

We got lots of trees and lots of snow.

#### \$3 one-time
""",
    """
#### Mexico Theme Pack

Just like in Hollywood

#### \$3 one-time
""",
    """
#### Globalist Theme Pack

Blue helmets and white doves.

#### \$3 one-time
""",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [],
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.fromLTRB(8, 16, 8, 4),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text('Account',
                          style: Theme.of(context).textTheme.bodyText1),
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
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text('Let me in!'),
                                )
                              ])),
                    )),
                    Divider(),
                    Row(children: [
                      Text('Unlock Features',
                          style: Theme.of(context).textTheme.bodyText1),
                      Spacer(),
                      Text('Nothing in this world is free.',
                          style: Theme.of(context).textTheme.caption)
                    ]),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 12),
                      child: Container(
                        height: 200,
                        child: ListView(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            children: <Widget>[
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 0),
                                  child: Container(
                                      width: 150,
                                      child: Card(
                                          // color: Colors.white,
                                          child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(children: [
                                          MarkdownBody(data: features[0]),
                                        ]),
                                      )))),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 0),
                                  child: Container(
                                      width: 150,
                                      child: Card(
                                          // color: Colors.white,
                                          child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(children: [
                                          MarkdownBody(data: features[1]),
                                        ]),
                                      )))),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 0),
                                  child: Container(
                                      width: 150,
                                      child: Card(
                                          // color: Colors.white,
                                          child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(children: [
                                          MarkdownBody(data: features[2]),
                                        ]),
                                      )))),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 0),
                                  child: Container(
                                      width: 150,
                                      child: Card(
                                          // color: Colors.white,
                                          child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(children: [
                                          MarkdownBody(data: features[3]),
                                        ]),
                                      )))),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 0),
                                  child: Container(
                                      width: 150,
                                      child: Card(
                                          // color: Colors.white,
                                          child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(children: [
                                          MarkdownBody(data: features[4]),
                                        ]),
                                      )))),
                            ]),
                      ),
                    ),
                    Divider(),
                    Row(children: [
                      Text('Theme Packs',
                          style: Theme.of(context).textTheme.bodyText1),
                      Spacer(),
                      Text('Dress for the life you want.',
                          style: Theme.of(context).textTheme.caption)
                    ]),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 12),
                      child: Container(
                        height: 200,
                        child: ListView(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            children: <Widget>[
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 0),
                                  child: Container(
                                      width: 150,
                                      child: Card(
                                          // color: Colors.white,
                                          child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(children: [
                                          MarkdownBody(data: themePacks[0]),
                                        ]),
                                      )))),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 0),
                                  child: Container(
                                      width: 150,
                                      child: Card(
                                          // color: Colors.white,
                                          child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(children: [
                                          MarkdownBody(data: themePacks[1]),
                                        ]),
                                      )))),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 0),
                                  child: Container(
                                      width: 150,
                                      child: Card(
                                          // color: Colors.white,
                                          child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(children: [
                                          MarkdownBody(data: themePacks[2]),
                                        ]),
                                      )))),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 0),
                                  child: Container(
                                      width: 150,
                                      child: Card(
                                          // color: Colors.white,
                                          child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(children: [
                                          MarkdownBody(data: themePacks[3]),
                                        ]),
                                      )))),
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 0),
                                  child: Container(
                                      width: 150,
                                      child: Card(
                                          // color: Colors.white,
                                          child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(children: [
                                          MarkdownBody(data: themePacks[4]),
                                        ]),
                                      )))),
                            ]),
                      ),
                    ),
                    Divider(),
                    Text('About & Privacy',
                        style: Theme.of(context).textTheme.bodyText1),
                    Text('Written in 🍁 with ❤️ by inhumantsar. ',
                        style: Theme.of(context).textTheme.caption),
                    Text("No personal information is ever accessed or stored.",
                        style: Theme.of(context).textTheme.caption),
                    Text("I'm not responsible for anything which gets posted.",
                        style: Theme.of(context).textTheme.caption),
                    Text(
                        "Feel free to contact me anytime with bugs or suggestions.",
                        style: Theme.of(context).textTheme.caption),
                  ])),
        ));
  }
}
