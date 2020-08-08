import 'package:analyzer/dart/element/element.dart';
import 'package:fast_orm/dao.dart';
import 'package:source_gen/source_gen.dart';

import 'utils.dart';

final _dbPropertyExpando = Expando<DBProperty>();

DBProperty dbPropertyForField(FieldElement field) =>
    _dbPropertyExpando[field] ??= _from(field);

DBProperty _from(FieldElement element) {
  /// 如果 element 上存在注解，则源为real字段。如果结果是null，请检查getter–它是一个属性。
  final obj = dbPropertyAnnotation(element);
  ConstantReader _type = ConstantReader(obj.read("type").objectValue);
  return _populateDbProperty(
    element,
    name: obj.read('name').literalValue as String,
    isPrimary: obj.read("isPrimary").literalValue as bool,
    type: DBPropertyType(
      value: _type.read("value").literalValue as String,
      type: _type.read("type").literalValue as int,
      expand: _type.read("expand").literalValue as String,
    ),
  );
}

DBProperty _populateDbProperty(
  FieldElement element, {
  String name,
  bool isPrimary,
  DBPropertyType type,
}) {
  final jsonKey = DBProperty(
    name,
    isPrimary: isPrimary,
    type: type,
  );
  return jsonKey;
}
