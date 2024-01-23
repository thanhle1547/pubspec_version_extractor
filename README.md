A Dart library generates a file with the version from pubspec.yaml.

## Usage

### Generated File Content

`pubspec_version.g.dart`

```dart
const String pubspecVersion = '1.2.3-dev+40';

const String pubspecVersionNumber = '1.2.3';

const int pubspecBuildNumber = 40;

const String pubspecBuildIdentifiers = '40';

const String pubspecVersionPreRelease = 'dev';

const String pubspecVersionSuffix = '-dev+40';
```

## Installation

If you are using creating a Flutter project:

```shell
$ flutter pub add --dev pubspec_version_extractor
$ flutter pub add --dev build_runner
```

If you are using creating a Dart project:

```shell
$ dart pub add --dev pubspec_version_extractor
$ dart pub add --dev build_runner
```

## Configuration

When called, `pubspec_version_extractor` will look for a `pubspec.yaml` file in the current directory, and will throw an error if it doesn't exist. The generated file location can be changed by declaring the `pubspec_version_extractor` node within the `pubspec.yaml` file.

`pubspec.yaml`

```yaml
pubspec_version_extractor:
  output: lib/src/custom/path
```

By default, `pubspec_version_extractor` will generate the file at location: `lib/generated`.

Another option to change the path of the generated file is by creating a `build.yaml` file in the root of your project. By changing the output option of this builder, the path can be customized:

`build.yaml`

```yaml
targets:
  $default:
    builders:
      pubspec_version_extractor:
        options:
          output: lib/src/custom/path
```

When the output path is specified inside `build.yaml` and `pubspec.yaml`, the one in `build.yaml` file has higher priority.
