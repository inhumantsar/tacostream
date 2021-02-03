import 'package:clippy_flutter/clippy_flutter.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tacostream/services/theme.dart';
import 'package:tacostream/widgets/comment/comment.dart';

class ThemePickerWidget extends StatelessWidget {
  static Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, widget) => ListView.builder(
          shrinkWrap: true,
          physics: ScrollPhysics(),
          itemCount: themeService.themes.length,
          itemBuilder: (context, index) {
            final theme = themeService.themes[index];
            return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                child: Stack(
                  alignment: AlignmentDirectional.topEnd,
                  children: [
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
                            child:
                                CommentWidget(theme: theme.light, mdTheme: theme.markdownLight))),
                    Diagonal(
                        clipHeight: 220.0,
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
                                    theme: theme.dark, mdTheme: theme.markdownDark)))),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RawMaterialButton(
                            // padding: EdgeInsets.all(3),
                            shape: CircleBorder(),
                            visualDensity: VisualDensity.compact,
                            child: themeService.baseTheme.name != theme.name
                                ? Container(width: 20, height: 20)
                                : Icon(FontAwesomeIcons.check, size: 16),
                            fillColor: Theme.of(context).colorScheme.surface,
                            onPressed: () => themeService.theme = theme.name)),
                  ],
                ));
          }),
    );
  }
}
