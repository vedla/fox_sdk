/// A simple YAML writer that converts Dart objects
/// (maps and lists) into YAML strings.
String toYamlString(dynamic data, [int indent = 0]) {
  final spaces = ' ' * indent;
  if (data is Map) {
    if (data.isEmpty) return '{}${chr(10)}';
    final buffer = StringBuffer();
    if (indent > 0) buffer.writeln();
    data.forEach((key, value) {
      buffer.write('$spaces$key: ');
      if (value is Map || value is List) {
        buffer.write(toYamlString(value, indent + 2));
      } else {
        buffer.writeln(_yamlValue(value));
      }
    });
    return buffer.toString();
  } else if (data is List) {
    if (data.isEmpty) return '[]${chr(10)}';
    final buffer = StringBuffer();
    if (indent > 0) buffer.writeln();
    for (final item in data) {
      buffer.write('$spaces- ');
      if (item is Map || item is List) {
        final inner = toYamlString(item, indent + 2);
        buffer.write(inner.trimLeft());
      } else {
        buffer.writeln(_yamlValue(item));
      }
    }
    return buffer.toString();
  }
  return _yamlValue(data) + chr(10);
}

String _yamlValue(dynamic value) {
  if (value == null) return 'null';
  if (value is String) {
    if (value.contains(chr(10)) ||
        value.contains(':') ||
        value.startsWith(' ') ||
        value.endsWith(' ') ||
        value.isEmpty) {
      return "'${value.replaceAll("'", "''")}'";
    }
    return value;
  }
  return value.toString();
}

String chr(int charCode) => String.fromCharCode(charCode);
