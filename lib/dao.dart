///dao的抽象类
abstract class Dao<E> {
  String getTableName();

  E formMap(Map map);

  Map toMap(E entity);
}

abstract class DBEntity {}

///数据库 表
class DBTable {
  ///表名注解
  final String name;
  const DBTable(this.name);
  @override
  String toString() => 'DBTable name: $name';
}

///数据库 表 属性
class DBProperty {
  ///属性名
  final String name;

  ///属性类型
  final DBPropertyType type;

  ///是否是主键
  final bool isPrimary;

  const DBProperty(
    this.name, {
    this.type = DBPropertyType.Text,
    this.isPrimary = false,
  });

  @override
  String toString() => "DBProperty";

  factory DBProperty.fromJson(Map<String, dynamic> json) {
    return DBProperty(json['name'],
        type: DBPropertyType.fromJson(json['type'] as Map<String, dynamic>),
        isPrimary: json['isPrimary'] as bool);
  }

  Map<String, dynamic> toJson() =>
      {'name': name, 'type': type, 'isPrimary': isPrimary};
}

/// 数据类型
class DBPropertyType {
  final String value;
  final int type;

  /// 扩展
  final String expand;

  static const typeOfBool = 0;
  static const typeOfJson = 1;

  const DBPropertyType({this.value, this.type, this.expand});

  @override
  String toString() => "PropertyType";

  factory DBPropertyType.fromJson(Map<String, dynamic> json) {
    return DBPropertyType(value: json['value']);
  }

  Map<String, dynamic> toJson() => {'value': value};

  static json(Type type) =>
      DBPropertyType(value: "TEXT", type: typeOfJson, expand: type.toString());

  static const DBPropertyType Int = const DBPropertyType(value: "INT"),
      Text = const DBPropertyType(value: "TEXT"),
      Bool = const DBPropertyType(value: "INT", type: typeOfBool),
      DOUBLE = const DBPropertyType(value: "REAL");
}
