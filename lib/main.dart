import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:draw/draw.dart' as draw;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tacostream/models/comment.dart';
import 'package:tacostream/services/jeremiah.dart';
import 'package:tacostream/services/theme.dart';
import 'package:tacostream/views/stream/stream.dart';
import 'package:package_info/package_info.dart';
import 'package:uuid/uuid.dart';

GetIt locator = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  Hive.registerAdapter(CommentAdapter());
  var commentsBox = await Hive.openBox<Comment>('comments');

  // TODO: stop doing this
  await commentsBox.clear();

  var prefsBox = await Hive.openBox('prefs');
  prefsBox.get('deviceId') ?? prefsBox.put('deviceId', Uuid().v4());
  prefsBox.get('unlockedThemes') ?? prefsBox.put('unlockedThemes', ['Washington', 'Okayama']);

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String versionName = packageInfo.version;
  String versionCode = packageInfo.buildNumber;
  String packageName = packageInfo.packageName;
  final userAgent = 'android:$packageName:v$versionName.$versionCode (by /u/inhumantsar)';
  print("userAgent: $userAgent");
  print("deviceId: ${prefsBox.get('deviceId')}");
  var reddit = await draw.Reddit.createUntrustedReadOnlyInstance(
      clientId: 'GW3D4HqPspIgtA', deviceId: prefsBox.get('deviceId'), userAgent: userAgent);

  locator.registerLazySingleton(() => Jeremiah(commentsBox, reddit));
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
