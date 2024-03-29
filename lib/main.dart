import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tacostream/models/comment.dart';
import 'package:tacostream/models/redditor.dart';
import 'package:tacostream/services/jeeves.dart';
import 'package:tacostream/services/snoop.dart';
import 'package:tacostream/services/theme.dart';
import 'package:tacostream/services/watercooler.dart';
import 'package:tacostream/views/stream/stream.dart';

GetIt locator = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(CommentAdapter());
  Hive.registerAdapter(RedditorAdapter());
  var commentsBox = await Hive.openBox<Comment>('comments');
  var prefsBox = await Hive.openBox('prefs');

  locator.registerLazySingleton(() => Jeeves(prefsBox));
  locator.registerLazySingleton(() => Snoop());
  locator.registerLazySingleton(() => ThemeService());
  locator.registerLazySingleton(() => Watercooler(commentsBox));

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider.value(value: locator<Snoop>()),
    Provider.value(value: locator<Jeeves>()),
    ChangeNotifierProvider.value(value: locator<Watercooler>()),
    ChangeNotifierProvider.value(
      value: locator<ThemeService>(),
    )
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, widget) => MaterialApp(
        title: '🌮 tacostream',
        debugShowCheckedModeBanner: false,
        theme: themeService.theme,
        home: StreamView(),
      ),
    );
  }
}
