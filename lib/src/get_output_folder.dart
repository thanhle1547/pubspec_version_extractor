import 'dart:io';

import 'package:pubspec_version_extractor/src/constants.dart';
import 'package:tint/tint.dart';
import 'package:yaml/yaml.dart';

import 'logger.dart';

const defaultOutputFolder = 'lib/generated';

String getOutputPath({
  String? buildYamlPath,
  String? buildYamlOutputPath,
  required File pubspecFile,
}) {
  dynamic loadedYaml;

  final File? buildYamlFile = buildYamlPath == null ? null : File(buildYamlPath);
  if (buildYamlOutputPath == null && buildYamlFile != null && buildYamlFile.existsSync()) {
    loadedYaml = loadYaml(buildYamlFile.readAsStringSync());
    if (loadedYaml is YamlMap) {
      final target = loadedYaml.nodes['targets']?.value;
      final targetDefault = target[r'$default']?.value;
      final builders = targetDefault['builders']?.value;
      final executable = builders[executableName]?.value;
      final options = executable['options']?.value;
      buildYamlOutputPath = options['output'];
    }
  }

  final Map<String, dynamic> pubspec;
  loadedYaml = loadYaml(pubspecFile.readAsStringSync());
  if (loadedYaml is YamlList) {
    pubspec = const {};
  } else if (loadedYaml is YamlMap) {
    final executable = loadedYaml.nodes[executableName]?.value;
    final output = executable?['output'];
    pubspec = {
      executableName: {
        'output': output,
      }
    };
  } else {
    pubspec = loadedYaml;
  }

  final String? buildOutput = buildYamlOutputPath;
  final String? pubspecOutput = pubspec[executableName]?['output'];

  if (buildOutput != null && pubspecOutput != null) {
    Logger.info(
      'output path is specified inside '
      '${'build.yaml'.bold()}'
      ' and '
      '${'pubspec.yaml'.bold()}',
    );
  }

  return buildOutput ?? pubspecOutput ?? defaultOutputFolder;
}
