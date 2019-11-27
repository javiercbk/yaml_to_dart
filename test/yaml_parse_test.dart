import 'dart:io';

import 'package:path/path.dart' show dirname, join, normalize;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_to_dart/generator.dart';

String _scriptPath() {
  var script = Platform.script.toString();
  if (script.startsWith("file://")) {
    script = script.substring(7);
  } else {
    final idx = script.indexOf("file:/");
    script = script.substring(idx + 5);
  }
  return script;
}

void main() {
  group("yaml parser", () {
    final currentDirectory = dirname(_scriptPath());

    test("Should generate the classes to reference a yaml file", () async {
      final yamlPath = normalize(join(currentDirectory, 'en.yaml'));
      final yamlFile = new File(yamlPath);
      final yamlContent = await yamlFile.readAsString();
      final dartCode = StringBuffer();
      final yamlMap = loadYaml(yamlContent);
      generateClass(dartCode, '', 'messages', yamlMap, first: true);
      final dartCodeContent = dartCode.toString();
      expect(dartCodeContent, contains("class Messages {"));
    });
  });
}
