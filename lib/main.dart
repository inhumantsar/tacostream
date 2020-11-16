import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tacostream/services/jeremiah.dart';
import 'package:tacostream/services/theme.dart';
import 'package:tacostream/views/stream/stream.dart';

GetIt locator = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  var prefsBox = await Hive.openBox('prefs');
  locator.registerLazySingleton(() => Jeremiah());
  locator.registerLazySingleton(() => ThemeService(prefsBox));

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider.value(value: locator<Jeremiah>()),
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
        theme: themeService.currentTheme,
        home: StreamView(),
      ),
    );
  }
}
