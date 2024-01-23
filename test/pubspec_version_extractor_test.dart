import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:test_process/test_process.dart';

void main() {
  test('Empty version should generate empty test', () async {
    await _structurePackage();

    await _run(
      expectNoFileGenerated: false,
      expectMatchGeneratedContent: true,
      willGeneratedContent: '''
const String? pubspecVersion = null;

const String? pubspecVersionNumber = null;

const int? pubspecBuildNumber = null;

const String? pubspecBuildIdentifiers = null;

const String? pubspecVersionPreRelease = null;

const String? pubspecVersionSuffix = null;
''',
    );
  });

  test('Non-empty version number should generate data test', () async {
    await _structurePackage(version: '1.2.3');

    await _run(
      expectNoFileGenerated: false,
      expectMatchGeneratedContent: true,
      willGeneratedContent: '''
const String pubspecVersion = '1.2.3';

const String pubspecVersionNumber = '1.2.3';

const int? pubspecBuildNumber = null;

const String? pubspecBuildIdentifiers = null;

const String? pubspecVersionPreRelease = null;

const String? pubspecVersionSuffix = null;
''',
    );
  });

  test('Non-empty build number should generate data test', () async {
    await _structurePackage(version: '1.2.3+15');

    await _run(
      expectNoFileGenerated: false,
      expectMatchGeneratedContent: true,
      willGeneratedContent: '''
const String pubspecVersion = '1.2.3+15';

const String pubspecVersionNumber = '1.2.3';

const int pubspecBuildNumber = 15;

const String pubspecBuildIdentifiers = '15';

const String? pubspecVersionPreRelease = null;

const String pubspecVersionSuffix = '+15';
''',
    );
  });

  test('Non-empty pre-release should generate data test', () async {
    await _structurePackage(version: '1.2.3-dev');

    await _run(
      expectNoFileGenerated: false,
      expectMatchGeneratedContent: true,
      willGeneratedContent: '''
const String pubspecVersion = '1.2.3-dev';

const String pubspecVersionNumber = '1.2.3';

const int? pubspecBuildNumber = null;

const String? pubspecBuildIdentifiers = null;

const String pubspecVersionPreRelease = 'dev';

const String pubspecVersionSuffix = '-dev';
''',
    );
  });

  test('Non-empty version should generate data test', () async {
    await _structurePackage(version: '1.2.3-dev+40');

    await _run(
      expectNoFileGenerated: false,
      expectMatchGeneratedContent: true,
      willGeneratedContent: '''
const String pubspecVersion = '1.2.3-dev+40';

const String pubspecVersionNumber = '1.2.3';

const int pubspecBuildNumber = 40;

const String pubspecBuildIdentifiers = '40';

const String pubspecVersionPreRelease = 'dev';

const String pubspecVersionSuffix = '-dev+40';
''',
    );
  });

  group('Overrided output path at pubspec.yaml should generate at right place test', () {
    test(
      '1 level above lib',
      () async {
        final pubspecOverrideOutput = 'lib/config';

        await _structurePackage(
          version: '1.2.3-dev+40',
          pubspecOverrideOutput: pubspecOverrideOutput,
        );

        await _run(
          expectNoFileGenerated: false,
          expectMatchGeneratedContent: true,
          willGeneratedContentLocation: pubspecOverrideOutput,
          willGeneratedContent: '''
const String pubspecVersion = '1.2.3-dev+40';

const String pubspecVersionNumber = '1.2.3';

const int pubspecBuildNumber = 40;

const String pubspecBuildIdentifiers = '40';

const String pubspecVersionPreRelease = 'dev';

const String pubspecVersionSuffix = '-dev+40';
''',
        );
      },
    );

    test(
      '2 levels above lib',
      () async {
        final pubspecOverrideOutput = 'lib/app/config';

        await _structurePackage(
          version: '1.2.3-dev+40',
          pubspecOverrideOutput: pubspecOverrideOutput,
        );

        await _run(
          expectNoFileGenerated: false,
          expectMatchGeneratedContent: true,
          willGeneratedContentLocation: pubspecOverrideOutput,
          willGeneratedContent: '''
const String pubspecVersion = '1.2.3-dev+40';

const String pubspecVersionNumber = '1.2.3';

const int pubspecBuildNumber = 40;

const String pubspecBuildIdentifiers = '40';

const String pubspecVersionPreRelease = 'dev';

const String pubspecVersionSuffix = '-dev+40';
''',
        );
      },
    );
  });

  group('Overrided output path at build.yaml should generate at right place test', () {
    test(
      '1 level above lib',
      () async {
        final buildOverrideOutput = 'lib/config';

        await _structurePackage(
          version: '1.2.3-dev+40',
          buildOverrideOutput: buildOverrideOutput,
        );

        await _run(
          expectNoFileGenerated: false,
          expectMatchGeneratedContent: true,
          willGeneratedContentLocation: buildOverrideOutput,
          willGeneratedContent: '''
const String pubspecVersion = '1.2.3-dev+40';

const String pubspecVersionNumber = '1.2.3';

const int pubspecBuildNumber = 40;

const String pubspecBuildIdentifiers = '40';

const String pubspecVersionPreRelease = 'dev';

const String pubspecVersionSuffix = '-dev+40';
''',
        );
      },
    );

    test(
      '2 levels above lib',
      () async {
        final buildOverrideOutput = 'lib/app/config';

        await _structurePackage(
          version: '1.2.3-dev+40',
          buildOverrideOutput: buildOverrideOutput,
        );

        await _run(
          expectNoFileGenerated: false,
          expectMatchGeneratedContent: true,
          willGeneratedContentLocation: buildOverrideOutput,
          willGeneratedContent: '''
const String pubspecVersion = '1.2.3-dev+40';

const String pubspecVersionNumber = '1.2.3';

const int pubspecBuildNumber = 40;

const String pubspecBuildIdentifiers = '40';

const String pubspecVersionPreRelease = 'dev';

const String pubspecVersionSuffix = '-dev+40';
''',
        );
      },
    );
  });

  group(
      'Overrided output path at both pubspec.yaml and build.yaml '
      'should generate at location specified inside build.yaml test', () {
    test(
      '1 level above lib',
      () async {
        final pubspecOverrideOutput = 'lib/app';
        final buildOverrideOutput = 'lib/config';

        await _structurePackage(
          version: '1.2.3-dev+40',
          pubspecOverrideOutput: pubspecOverrideOutput,
          buildOverrideOutput: buildOverrideOutput,
        );

        await _run(
          message: '[pubspec_version_extractor] output path is specified inside build.yaml and pubspec.yaml',
          expectNoFileGenerated: false,
          expectMatchGeneratedContent: true,
          willGeneratedContentLocation: buildOverrideOutput,
          willGeneratedContent: '''
const String pubspecVersion = '1.2.3-dev+40';

const String pubspecVersionNumber = '1.2.3';

const int pubspecBuildNumber = 40;

const String pubspecBuildIdentifiers = '40';

const String pubspecVersionPreRelease = 'dev';

const String pubspecVersionSuffix = '-dev+40';
''',
        );
      },
    );

    test(
      '2 levels above lib',
      () async {
        final pubspecOverrideOutput = 'lib/app/constant';
        final buildOverrideOutput = 'lib/app/config';

        await _structurePackage(
          version: '1.2.3-dev+40',
          pubspecOverrideOutput: pubspecOverrideOutput,
          buildOverrideOutput: buildOverrideOutput,
        );

        await _run(
          message: '[pubspec_version_extractor] output path is specified inside build.yaml and pubspec.yaml',
          expectNoFileGenerated: false,
          expectMatchGeneratedContent: true,
          willGeneratedContentLocation: buildOverrideOutput,
          willGeneratedContent: '''
const String pubspecVersion = '1.2.3-dev+40';

const String pubspecVersionNumber = '1.2.3';

const int pubspecBuildNumber = 40;

const String pubspecBuildIdentifiers = '40';

const String pubspecVersionPreRelease = 'dev';

const String pubspecVersionSuffix = '-dev+40';
''',
        );
      },
    );
  });
}

const libDirName = 'lib';

Future<void> _structurePackage({
  String? version,
  String? pubspecOverrideOutput,
  String? buildOverrideOutput,
}) async {
  final pubspec = loudEncode(
    {
      'name': '_test_pkg',
      'version': version,
      'publish_to': 'none',
      'environment': {'sdk': '>=2.12.0 <4.0.0'},
      'dependencies': _jsonSerialPathDependency,
      'dev_dependencies': {
        'build_runner': '2.4.7',
        'pubspec_version_extractor': {
          'path': _fixPath(''),
        },
      },
      if (pubspecOverrideOutput != null)
        'pubspec_version_extractor': {
          'output': pubspecOverrideOutput,
        }
    },
  );

  await d.file('pubspec.yaml', pubspec).create();

  if (buildOverrideOutput != null) {
    final build = loudEncode(
      {
        'targets': {
          r'$default': {
            'builders': {
              'pubspec_version_extractor': {
                'options': {
                  'output': buildOverrideOutput,
                }
              }
            }
          }
        }
      },
    );

    await d.file('build.yaml', build).create();
  }

  await d.dir(libDirName, [
    d.file('empty.dart', ''),
  ]).create();
}

Future<void> _run({
  String? message,
  bool expectNoFileGenerated = false,
  bool? expectMatchGeneratedContent,
  String? willGeneratedContentLocation,
  String? willGeneratedContent,
}) async {
  final proc = await TestProcess.start(
    Platform.resolvedExecutable,
    ['run', 'build_runner', 'build', '--verbose'],
    workingDirectory: d.sandbox,
    forwardStdio: false,
  );

  final lines = StringBuffer();
  await Future.wait([
    proc.exitCode,
    proc.stdoutStream().forEach((line) {
      final willMatchLime = line.trimLeft();

      if (willMatchLime.isEmpty) return;

      if (willMatchLime.startsWith('[INFO]')) {
        return;
      } else {
        lines.writeln(line);
      }

      print("out  $line");
    }),
    proc.stderrStream().forEach((line) {
      lines.writeln(line);
      print("err  $line");
    }),
  ]);
  if (message != null) {
    expect(lines.toString(), contains(message));
  }

  if (willGeneratedContent != null) {
    const defaultGeneratedDir = "/$libDirName/generated/";
    final generatedDir = willGeneratedContentLocation ?? defaultGeneratedDir;
    // final effectiveGeneratedDir = generatedDir[generatedDir.length - 1] == '/' ? generatedDir : "$generatedDir/";
    const generatedFileName = "pubspec_version.g.dart";
    final generatedFilePath = p.fromUri(
      Uri.directory(generatedDir).resolveUri(Uri.file(generatedFileName)),
    );

    final generatedFileDirContents = [
      d.file(generatedFileName, contains(willGeneratedContent)),
    ];
    final relativeDirPath = generatedDir[0] != '/' ? generatedDir : generatedDir.substring(1);
    final dirNames = p.split(p.relative(relativeDirPath, from: libDirName));
    d.DirectoryDescriptor? oldDirContent;
    late d.DirectoryDescriptor dirContent;
    for (int i = dirNames.length - 1; i > -1; i--) {
      dirContent = d.dir(
        dirNames[i],
        i == dirNames.length - 1 ? generatedFileDirContents : [oldDirContent!],
      );
      oldDirContent = dirContent;
    }

    final generatedDirPattern = d.dirPattern(
      libDirName,
      [dirContent],
    );
    final generatedFutureValidation = generatedDirPattern.validate();

    if (expectNoFileGenerated) {
      expect(
        generatedFutureValidation,
        throwsA(
          toString(equals('No entries found in sandbox matching $generatedFilePath.')),
        ),
      );
      return;
    }

    if (expectMatchGeneratedContent == true) {
      await generatedFutureValidation;
    } else if (expectMatchGeneratedContent == false) {
      expect(
        generatedFutureValidation,
        throwsA(
          toString(startsWith("File \"$generatedFilePath\" should contains:")),
        ),
      );
    }
  }

  // Assert that the process exits with code 0.
  await proc.shouldExit(0);
}

final _jsonSerialPubspec = Pubspec.parse(
  File('pubspec.yaml').readAsStringSync(),
  sourceUrl: Uri.file('pubspec.yaml'),
);

String _fixPath(String path) {
  if (p.isAbsolute(path)) return path;

  return p.canonicalize(p.join(p.current, path));
}

final _jsonSerialPathDependency = {
  for (var entry in _jsonSerialPubspec.dependencies.entries)
    if (entry.value is PathDependency)
      entry.key: {
        'path': _fixPath((entry.value as PathDependency).path),
      }
};

String loudEncode(Object? object) {
  return const JsonEncoder.withIndent(' ').convert(object);
}

/// Returns a matcher that verifies that the result of calling `toString()`
/// matches [matcher].
Matcher toString(Object? matcher) => predicate(
      (object) {
        expect(object.toString(), matcher);
        return true;
      },
      'toString() matches $matcher',
    );
