import 'dart:async';
import 'dart:io';

import 'package:build/build.dart';

import 'constants.dart';
import 'extract_version.dart';
import 'get_output_folder.dart';

class PubspecVersionExtractor extends Builder {
  PubspecVersionExtractor({this.outputFolder});

  final String? outputFolder;

  /// The package's top-level pubspec.yaml.
  File get pubspecFile => File('pubspec.yaml');

  @override
  Map<String, List<String>> get buildExtensions => {
        r"$lib$": [outputFileName]
      };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final outputPath = getOutputPath(
      buildYamlOutputPath: outputFolder,
      pubspecFile: pubspecFile,
    );

    await extractVersion(
      pubspecFile: pubspecFile,
      outputPath: outputPath,
    );
  }
}
