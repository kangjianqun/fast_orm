import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:fast_orm/dao.dart';
import 'package:source_gen/source_gen.dart';

const _dbPropertyChecker = TypeChecker.fromRuntime(DBProperty);

final _dollarQuoteRegexp = RegExp(r"""(?=[$'"])""");

/// A [Map] between whitespace characters & `\` and their escape sequences.
const _escapeMap = {
  '\b': r'\b', // 08 - backspace
  '\t': r'\t', // 09 - tab
  '\n': r'\n', // 0A - new line
  '\v': r'\v', // 0B - vertical tab
  '\f': r'\f', // 0C - form feed
  '\r': r'\r', // 0D - carriage return
  '\x7F': r'\x7F', // delete
  r'\': r'\\' // backslash
};
final _escapeMapRegexp = _escapeMap.keys.map(_getHexLiteral).join();

/// Given single-character string, return the hex-escaped equivalent.
String _getHexLiteral(String input) {
  final rune = input.runes.single;
  final value = rune.toRadixString(16).toUpperCase().padLeft(2, '0');
  return '\\x$value';
}

/// A [RegExp] that matches whitespace characters that should be escaped and
/// single-quote, double-quote, and `$`
final _escapeRegExp = RegExp('[\$\'"\\x00-\\x07\\x0E-\\x1F$_escapeMapRegexp]');

DartObject _dbPropertyAnnotation(FieldElement element) =>
    _dbPropertyChecker.firstAnnotationOf(element) ??
    (element.getter == null
        ? null
        : _dbPropertyChecker.firstAnnotationOf(element.getter));

ConstantReader dbPropertyAnnotation(FieldElement element) =>
    ConstantReader(_dbPropertyAnnotation(element));

/// Returns `true` if [element] is annotated with [DBProperty].
bool hasDbPropertyAnnotation(FieldElement element) =>
    _dbPropertyAnnotation(element) != null;

/// 返回[value]的带引号的字符串文字，该文字可以在生成的Dart代码中使用
String escapeDartString(String value) {
  var hasSingleQuote = false;
  var hasDoubleQuote = false;
  var hasDollar = false;
  var canBeRaw = true;

  value = value.replaceAllMapped(_escapeRegExp, (match) {
    final value = match[0];
    if (value == "'") {
      hasSingleQuote = true;
      return value;
    } else if (value == '"') {
      hasDoubleQuote = true;
      return value;
    } else if (value == r'$') {
      hasDollar = true;
      return value;
    }

    canBeRaw = false;
    return _escapeMap[value] ?? _getHexLiteral(value);
  });

  if (!hasDollar) {
    if (hasSingleQuote) {
      if (!hasDoubleQuote) {
        return '"$value"';
      }
      // something
    } else {
      // trivial!
      return "'$value'";
    }
  }

  if (hasDollar && canBeRaw) {
    if (hasSingleQuote) {
      if (!hasDoubleQuote) {
        // quote it with single quotes!
        return 'r"$value"';
      }
    } else {
      // quote it with single quotes!
      return "r'$value'";
    }
  }

  // The only safe way to wrap the content is to escape all of the
  // problematic characters - `$`, `'`, and `"`
  final string = value.replaceAll(_dollarQuoteRegexp, r'\');
  return "'$string'";
}

/// Returns a [String] representing a valid Dart literal for [value].
String jsonLiteralAsDart(dynamic value) {
  if (value == null) return 'null';

  if (value is String) return escapeDartString(value);

  if (value is double) {
    if (value.isNaN) {
      return 'double.nan';
    }
    if (value.isInfinite) {
      if (value.isNegative) {
        return 'double.negativeInfinity';
      }
      return 'double.infinity';
    }
  }

  if (value is bool || value is num) return value.toString();

  throw StateError(
      'Should never get here – with ${value.runtimeType} - `$value`.');
}

String mapToOrFrom(DBProperty item, String key, String eName, bool isToMap) {
  var data;
  if (isToMap) {
    data = "map['$key'] = entity.$eName;\n";
  } else {
    data = "entity.$eName = map['$key'];\n";
  }
  if (item.type == null) return data;

  if (item.type.type == DBPropertyType.typeOfBool) {
    if (isToMap) {
      data = "map['$key'] = entity.$eName ? 1 : 0;\n";
    } else {
      data = "entity.$eName = map['$key'] != 0;\n";
    }
  } else if (item.type.type == DBPropertyType.typeOfJson) {
    if (isToMap) {
      data = "map['$key'] = entity.$eName.toJson();\n";
    } else {
      data = "entity.$eName = ${item.type.expand}.fromJson(map['$key']);\n";
    }
  }
  return data;
}
