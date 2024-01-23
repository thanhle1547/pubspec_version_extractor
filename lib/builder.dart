import 'package:build/build.dart';
import 'package:pubspec_version_extractor/pubspec_version_extractor.dart';

Builder pubspecVersionExtractor(BuilderOptions options) {
  return PubspecVersionExtractor(outputFolder: options.config['output']);
}
