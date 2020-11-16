import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

abstract class BaseTheme implements Equatable {
  String get name;
  MaterialColor get primaryColor;
  MaterialColor get primaryColorDark;
  ThemeData get dark;
  ThemeData get light;
}
