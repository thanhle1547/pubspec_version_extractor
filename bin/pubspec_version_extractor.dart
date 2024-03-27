import 'dart:io';

import 'package:args/args.dart';
import 'package:pubspec_version_extractor/src/constants.dart';
import 'package:pubspec_version_extractor/src/extract_version.dart';
import 'package:pubspec_version_extractor/src/get_output_folder.dart';
import 'package:args/src/utils.dart';
import 'package:pubspec_version_extractor/src/io_exit_code.dart';
import 'package:pubspec_version_extractor/src/logger.dart';

Future<void> main(List<String> args) async {
  await _flushThenExit(await _SimpleCommandRunner().run(args));
}

/// Flushes the stdout and stderr streams, then exits the program with the given
/// status code.
///
/// This returns a Future that will never complete, since the program will have
/// exited already. This is useful to prevent Future chains from proceeding
/// after you've decided to exit.
Future<void> _flushThenExit(int status) {
  return Future.wait<void>([
    stdout.close(),
    stderr.close(),
  ]).then<void>((_) => exit(status));
}

class _OptionNames {
  static const String path = 'path';
  static const String output = 'output';
}

class _SimpleCommandRunner {
  _SimpleCommandRunner() {
    argParser
      ..addFlag(
        'help',
        abbr: 'h',
        negatable: false,
        help: 'Print this usage information.',
      )
      ..addOption(
        _OptionNames.path,
        abbr: 'p',
        help: 'Path to the folder contain `pubspec.yaml` file',
      )
      ..addOption(
        _OptionNames.output,
        abbr: 'o',
        valueHelp: defaultOutputFolder,
        help: 'Path to the output folder for generated file',
      );
  }

  final ArgParser argParser = ArgParser();

  /// A single-line template for how to invoke this executable.
  ///
  /// Defaults to "$executableName `arguments`".
  String get invocation => '$executableName [arguments]';

  Future<int> run(Iterable<String> args) async {
    final ArgResults topLevelResults = argParser.parse(args);

    String? workingPath = topLevelResults[_OptionNames.path] as String?;
    String? outputPath = topLevelResults[_OptionNames.output] as String?;

    // Get script working path
    workingPath ??= Directory.current.path;

    if (workingPath.endsWith('/')) {
      workingPath = workingPath.substring(0, workingPath.length - 1);
    }

    if (topLevelResults['help'] == true) {
      printUsage();
      return IOExitCode.success.code;
    }

    int? exitCode;

    final pubspecFile = File("$workingPath/pubspec.yaml");
    if (!pubspecFile.existsSync()) {
      Logger.error('pubspec.yaml not found!');
      return IOExitCode.noInput.code;
    }

    outputPath ??= getOutputPath(
      buildYamlPath: "$workingPath/build.yaml",
      pubspecFile: pubspecFile,
    );

    if (outputPath.startsWith('/') == true) {
      outputPath = outputPath.substring(1);
    }

    try {
      exitCode = await extractVersion(
        pubspecFile: pubspecFile,
        outputPath: "$workingPath/$outputPath",
      );
      exitCode = IOExitCode.success.code;
    } catch (e) {
      exitCode = IOExitCode.success.code;
    }

    return exitCode;
  }

  /// Prints the usage information for this runner.
  void printUsage() {
    final usage = _wrap('$description\n\n') + _buildUsageWithoutDescription();

    print(usage);
  }

  String _buildUsageWithoutDescription() {
    const usagePrefix = 'Usage:';
    final buffer = StringBuffer();
    buffer.writeln(
      '$usagePrefix ${_wrap(invocation, hangingIndent: usagePrefix.length)}\n',
    );
    buffer.writeln(
      _wrap('Global options:'),
    );
    buffer.writeln(argParser.usage);
    buffer.writeln();
    buffer.write(
      _wrap('Run "$executableName help" for more information.'),
    );

    return buffer.toString();
  }

  String _wrap(String text, {int? hangingIndent}) {
    return wrapText(
      text,
      length: argParser.usageLineLength,
      hangingIndent: hangingIndent,
    );
  }
}
