import 'dart:io';

import 'package:pubspec_version_extractor/src/constants.dart';
import 'package:tint/tint.dart';

final String _logPrefix = '[$executableName]'.green();

abstract final class Logger {
  static final IOOverrides? _overrides = IOOverrides.current;

  static Stdout get _stdout => _overrides?.stdout ?? stdout;
  static Stdout get _stderr => _overrides?.stderr ?? stderr;

  static void newLine() {
    _stdout.writeln();
  }

  static void info(String message) {
    _stdout.write(_logPrefix);
    _stdout.write(' ');
    _stdout.writeln(message);
  }

  static void error(String message) {
    _stderr.write(_logPrefix);
    _stderr.write(' ');
    _stderr.writeln(message.red());
  }
}
