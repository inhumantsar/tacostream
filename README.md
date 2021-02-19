# tacostream

Streams /r/neoliberal's busyass discussion thread.

[Now available on the Google Play Store](https://play.google.com/store/apps/details?id=ca.inhumantsar.tacostream)

## Build

Just like any other Flutter project.

        flutter build

### Hive type adaptors

These need to be generated before running a build:

        flutter pub get
        flutter packages pub run build_runner build --delete-conflicting-outputs
