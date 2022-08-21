# tacostream

Streams /r/neoliberal's busyass discussion thread.

[Now available on the Google Play Store](https://play.google.com/store/apps/details?id=ca.inhumantsar.tacostream)

## Build instructions
This project requires a Flutter version below 3.0.0 and above 2.7.0, meaning one must downgrade their Flutter version to 2.10.5 in order to build the project.

Downgrade Flutter by navigating to your SDK path:

        cd /path/to/flutter/sdk
Switch bracnhes for your SDK to v2.10. with:

        git checkout v2.10.5.

Then, build like any other Flutter project.

        flutter build
### Hive type adaptors

These need to be generated before running a build:

        flutter pub get
        flutter packages pub run build_runner build --delete-conflicting-outputs
