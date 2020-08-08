import 'package:analyzer/dart/element/element.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/element/inheritance_manager3.dart';
import 'package:source_gen/source_gen.dart';

import 'utils.dart';

const _dartCoreObjectChecker = TypeChecker.fromRuntime(Object);

class _FieldSet implements Comparable<_FieldSet> {
  final FieldElement field;
  final FieldElement sortField;

  _FieldSet._(this.field, this.sortField)
      : assert(field.name == sortField.name);

  factory _FieldSet(FieldElement classField, FieldElement superField) {
    /// 这些中的至少一个将！= null，也许两者都为。
    final fields = [classField, superField].where((fe) => fe != null).toList();

    /// 排序时，将class字段优先于继承字段。
    final sortField = fields.first;

    /// 如果有的话，最好使用用`JsonKey`注释的字段。 如果不是，请使用class字段。
    final fieldHasJsonKey =
        fields.firstWhere(hasDbPropertyAnnotation, orElse: () => fields.first);

    return _FieldSet._(fieldHasJsonKey, sortField);
  }

  @override
  int compareTo(_FieldSet other) => _sortByLocation(sortField, other.sortField);

  static int _sortByLocation(FieldElement a, FieldElement b) {
    final checkerA =
        TypeChecker.fromStatic((a.enclosingElement as ClassElement).thisType);

    if (!checkerA.isExactly(b.enclosingElement)) {
      /// 在这种情况下，您要优先考虑“超级”的enclosingElement。

      if (checkerA.isAssignableFrom(b.enclosingElement)) {
        return -1;
      }

      final checkerB =
          TypeChecker.fromStatic((b.enclosingElement as ClassElement).thisType);
      if (checkerB.isAssignableFrom(a.enclosingElement)) {
        return 1;
      }
    }

    /// 返回给定字段/属性在其源文件中的偏移量-如果定义了getter，则优先使用getter。
    int _offsetFor(FieldElement e) {
      if (e.getter != null && e.getter.nameOffset != e.nameOffset) {
        assert(e.nameOffset == -1);
        return e.getter.nameOffset;
      }
      return e.nameOffset;
    }

    return _offsetFor(a).compareTo(_offsetFor(b));
  }
}

/// 返回[element]和超级类的所有实例[FieldElement]项的[Set]，
/// 首先按它们在继承层次结构中的位置排序（super first），然后按它们在源文件中的位置排序。
Iterable<FieldElement> createSortedFieldSet(ClassElement element) {
  // 获取所有需要分配的字段
  // TODO: 支持使用注释选项覆盖字段集
  final elementInstanceFields = Map.fromEntries(
      element.fields.where((e) => !e.isStatic).map((e) => MapEntry(e.name, e)));

  final inheritedFields = <String, FieldElement>{};
  final manager = InheritanceManager3();

  for (final v in manager.getInheritedConcreteMap2(element).values) {
    assert(v is! FieldElement);
    if (_dartCoreObjectChecker.isExactly(v.enclosingElement)) {
      continue;
    }

    if (v is PropertyAccessorElement && v.isGetter) {
      assert(v.variable is FieldElement);
      final variable = v.variable as FieldElement;
      assert(!inheritedFields.containsKey(variable.name));
      inheritedFields[variable.name] = variable;
    }
  }

  /// 获取element的所有字段的列表
  final allFields =
      elementInstanceFields.keys.toSet().union(inheritedFields.keys.toSet());

  final fields = allFields
      .map((e) => _FieldSet(elementInstanceFields[e], inheritedFields[e]))
      .toList()
        ..sort();

  return fields.map((fs) => fs.field).toList();
}
