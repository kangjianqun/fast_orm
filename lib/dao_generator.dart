import 'dart:convert';
import 'package:build/build.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:fast_orm/src/helper_core.dart';
import 'package:mustache4dart/mustache4dart.dart';
import 'package:source_gen/source_gen.dart';

import 'dao.dart';
import 'src/field_helpers.dart';
import 'src/utils.dart';

/// flutter packages pub run build_runner build
Builder entityGenerator(BuilderOptions options) =>
    LibraryBuilder(DaoGenerator(), generatedExtension: '.dao.dart');

/// 代码生成
class DaoGenerator extends GeneratorForAnnotation<DBTable> {
  @override
  dynamic generateForAnnotatedElement(
      Element element, ConstantReader annotation, __) {
    var helper = _GeneratorHelper(element, annotation);
    return helper._generate();
  }
}

class _GeneratorHelper extends HelperCore {
  _GeneratorHelper(ClassElement element, ConstantReader annotation)
      : super(element, annotation);

  dynamic _generate() {
    final sortedFields = createSortedFieldSet(element);

    /// 用于跟踪字段被忽略的原因。在生成尝试使用这些字段之一的构造函数调用时，可以提供有用的错误。
    final unavailableReasons = <String, String>{};
    final accessibleFields = sortedFields.fold<Map<String, FieldElement>>(
      <String, FieldElement>{},
      (map, field) {
        if (!field.isPublic) {
          unavailableReasons[field.name] = 'It is assigned to a private field.';
        } else if (field.getter == null) {
          assert(field.setter != null);
          unavailableReasons[field.name] =
              'Setter-only properties are not supported.';
          log.warning('Setters are ignored: ${element.name}.${field.name}');
        } else {
          assert(!map.containsKey(field.name));
          map[field.name] = field;
        }
        return map;
      },
    );

    var accessibleFieldSet = accessibleFields.values.toSet();
    var propertyList = List<DBProperty>();

    String entityName = element.name;
    String formMap = "$entityName entity = $entityName();";
    String toMap = " var map = Map<String, dynamic>();\n";
    String primaryField;
    String tableProperty = "";
    String sqlTable = "";

    /// 检查注释是否存在重复的冲突。
    /// 我们现在这样做，因为在任何修剪完成后，我们有一个最终的字段列表
    accessibleFieldSet.fold(
      <String>{},
      (Set<String> set, fe) {
        var item = dbPropertyFor(fe);
        var elementName = fe.name;
        final key = item.name;
        if (item.isPrimary && primaryField != null) {
          throw InvalidGenerationSourceError('不能拥有两个主键',
              todo: '检查字段上的“DBProperty”注释。', element: fe);
        }
        if (!set.add(key)) {
          throw InvalidGenerationSourceError('多个字段有重复的`$key`.',
              todo: '检查字段上的“DBProperty”注释。', element: fe);
        }
        tableProperty +=
            "static QueryProperty $elementName = QueryProperty(name: '$key');\n";

        toMap += mapToOrFrom(item, key, elementName, true);
        formMap += mapToOrFrom(item, key, elementName, false);

        sqlTable += "${item.name} ${item.type.value}"
            "${item.isPrimary ? " PRIMARY KEY" : ""},";
        propertyList.add(item);
        if (item.isPrimary) primaryField = elementName;
        return set;
      },
    );

    if (sqlTable.endsWith(","))
      sqlTable = sqlTable.substring(0, sqlTable.length - 1);

    if (primaryField == null) throw '$entityName必须设置主键!';

    return render(clazzTpl, <String, dynamic>{
      'className': element.name + "Dao",
      'entityName': entityName,
      'tableName': annotation.peek("name")?.stringValue,
      "propertyList": "${json.encode(propertyList)}",
      "source": element.source.shortName,
      "toMap": toMap + "return map;",
      "formMap": formMap + "return entity;",
      "createSql": sqlTable,
      "primary": primaryField,
      "propertyClass": tableProperty
    });
  }
}
