import 'package:analyzer/dart/element/element.dart';
import 'package:fast_orm/dao.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import 'db_property_utils.dart';
import 'utils.dart';

abstract class HelperCore {
  final ClassElement element;
  final ConstantReader annotation;
  HelperCore(this.element, this.annotation);

  @protected
  String nameAccess(FieldElement field) => dbPropertyFor(field).name;

  @protected
  String safeNameAccess(FieldElement field) =>
      escapeDartString(nameAccess(field));

  @protected
  DBProperty dbPropertyFor(FieldElement field) => dbPropertyForField(field);
}
