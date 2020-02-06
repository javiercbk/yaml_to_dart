import 'package:yaml/yaml.dart';

String _capitalize(Match m) =>
    m[0].substring(0, 1).toUpperCase() + m[0].substring(1);
String _skip(String s) => "";

String _camelCase(String text) {
  return text.splitMapJoin(new RegExp(r'[a-zA-Z0-9]+'),
      onMatch: _capitalize, onNonMatch: _skip);
}

String _camelCaseFirstLower(String text) {
  if (allUpperCase(text)) {
    return text.toLowerCase();
  }
  final camelCaseText = _camelCase(text);
  final firstChar = camelCaseText.substring(0, 1).toLowerCase();
  final rest = camelCaseText.substring(1);
  return '$firstChar$rest';
}

bool allUpperCase(String str) {
  final strLen = str.length;
  for (int i = 0; i < strLen; i++) {
    if (str[i] != str[i].toUpperCase()) {
      return false;
    }
  }
  return true;
}

List<String> _generateClassCode(
    StringBuffer dartBuffer, String prefixPath, String name, YamlMap fields,
    {String parentPath = '', bool first = false}) {
  List<String> subClasses = List<String>();
  final className = _camelCase(name);
  final uniqueClassPrefix = parentPath + className[0];
  dartBuffer.write('class _$parentPath$className {');
  fields.forEach((key, value) {
    final fieldName = _camelCaseFirstLower(key);
    if (value is YamlMap) {
      subClasses.add(key);
      final subClassName = _camelCase(key);
      dartBuffer.write(
          'final _$uniqueClassPrefix$subClassName $fieldName = _$uniqueClassPrefix$subClassName();');
    } else {
      String fieldPath = key;
      if (!first) {
        fieldPath = prefixPath == '' ? '$name.$key' : '$prefixPath.$name.$key';
      }
      dartBuffer.write("final String $fieldName = '$fieldPath';");
    }
  });
  dartBuffer.write('}');
  return subClasses;
}

void generateClass(
    StringBuffer dartBuffer, String prefixPath, String name, YamlMap fields,
    {bool first = false, String parentPath = ''}) {
  final subclasses = _generateClassCode(dartBuffer, prefixPath, name, fields,
      parentPath: parentPath, first: first);
  subclasses.forEach((subClass) {
    String fullPrefix = '';
    if (!first) {
      if (prefixPath == '') {
        fullPrefix = name;
      } else {
        fullPrefix = '$prefixPath.$name';
      }
    }
    generateClass(dartBuffer, fullPrefix, subClass, fields[subClass],
        parentPath: parentPath + name[0].toUpperCase());
  });

  if (first) {
    final rootClassName = _camelCase(name);
    dartBuffer.write('final messages = _$rootClassName();');
  }
}
