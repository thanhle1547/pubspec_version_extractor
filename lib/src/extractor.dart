import 'dart:async';
import 'dart:io';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart';
import 'package:tint/tint.dart';
import 'package:yaml/yaml.dart';

/// Regex that matches a version number.
///
/// ```lang-text
/// ^((\d+)\.(\d+)\.(\d+))((-([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*))?(\+([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*))?)?$
/// ```
final _versionRegex = RegExp(
  r'^' // Start at beginning.
  r'((\d+)\.(\d+)\.(\d+))' // Version number.
  r'(' // Optional labels group.
  r'(-([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*))?' // Pre-release.
  r'(\+([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*))?' // Build.
  r')?'
  r'$', // Matches the entire string.
);

final String _logPrefix = '[pubspec_version_extractor]'.green();

class PubspecVersionExtractor extends Builder {
  PubspecVersionExtractor({this.outputFolder});

  final String? outputFolder;

  /// The package's top-level pubspec.yaml.
  File get pubspecFile => File('pubspec.yaml');

  @override
  Map<String, List<String>> get buildExtensions => {
        r"$lib$": ["pubspec_version.g.dart"]
      };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final pubspec = loadYaml(pubspecFile.readAsStringSync());
    final version = pubspec?['version'];

    stdout.writeln();
    stdout.writeln(
      '$_logPrefix'
      ' current version is '
      '${version.toString().bold()}',
    );

    final String? pubspecVersionOutput = pubspec['pubspec_version_extractor']?['output'];

    if (outputFolder != null && pubspecVersionOutput != null) {
      stdout.writeln(
        '$_logPrefix'
        ' output path is specified inside '
        '${'build.yaml'.bold()}'
        ' and '
        '${'pubspec.yaml'.bold()}',
      );
    }

    final outputPath = outputFolder ?? pubspecVersionOutput ?? 'lib/generated';

    stdout.writeln(
      '$_logPrefix'
      ' final output path is $outputPath'
      '\n',
    );

    final outputFilePath = join(outputPath, 'pubspec_version.g.dart');
    final outputFile = File(outputFilePath);

    if (!outputFile.existsSync()) {
      outputFile.createSync(recursive: true);
    }

    final RegExpMatch? match = version == null ? null : _versionRegex.firstMatch(version);
    final DartEmitter emitter = _CustomDartEmitter();

    final Library library = _generateLibrary(version, match);

    return outputFile
        .writeAsString(
          DartFormatter().format(library.accept(emitter).toString()),
        )
        .then((_) => {});
  }

  Library _generateLibrary(
    String? version,
    RegExpMatch? matchedVersion,
  ) {
    final String? versionNumber = matchedVersion?[1];

    final String? versionSuffix = matchedVersion?[5];

    final String? versionPreRelease = matchedVersion?[7];

    final String? buildIdentifiers = matchedVersion?[10];

    final int? buildNumber = buildIdentifiers == null ? null : int.tryParse(buildIdentifiers);

    return Library(
      (LibraryBuilder libraryBuilder) {
        libraryBuilder
          ..comments.add('coverage:ignore-file')
          ..generatedByComment = 'GENERATED CODE - DO NOT MODIFY BY HAND'
          ..ignoreForFile.addAll(['type=lint'])
          ..body.addAll([
            _generateField(
              name: 'pubspecVersion',
              value: version,
              typeOnNull: 'String?',
            ),
            _generateField(
              name: 'pubspecVersionNumber',
              value: versionNumber,
              typeOnNull: 'String?',
            ),
            _generateField(
              name: 'pubspecBuildNumber',
              value: buildNumber,
              typeOnNull: 'int?',
            ),
            _generateField(
              name: 'pubspecBuildIdentifiers',
              value: buildIdentifiers,
              typeOnNull: 'String?',
            ),
            _generateField(
              name: 'pubspecVersionPreRelease',
              value: versionPreRelease,
              typeOnNull: 'String?',
            ),
            _generateField(
              name: 'pubspecVersionSuffix',
              value: versionSuffix,
              typeOnNull: 'String?',
            ),
          ]);
      },
    );
  }

  Field _generateField({
    required String name,
    dynamic value,
    required String typeOnNull,
  }) {
    final bool isNullVal = value == null;

    late final Expression result;

    if (isNullVal) {
      result = literalNull;
    } else {
      if (value is int || value is int?) {
        result = literalNum(value);
      } else if (value is String || value is String?) {
        result = literalString(value);
      } else {
        result = literalString(value);
      }
    }

    return Field(
      (FieldBuilder fieldBuilder) => fieldBuilder
        ..modifier = FieldModifier.constant
        ..type = refer(
          isNullVal ? typeOnNull : value.runtimeType.toString(),
        )
        ..name = name
        ..assignment = result.code,
    );
  }
}

class _CustomDartEmitter extends DartEmitter {
  _CustomDartEmitter() : super(useNullSafetySyntax: true);

  @override
  StringSink visitField(Field spec, [StringSink? output]) {
    output ??= StringBuffer();

    super.visitField(spec, output);
    output.writeln('\n');

    return output;
  }
}
