///dao的抽象类
abstract class Dao<E> {
  String getTableName();

  E formMap(Map map);

  Map toMap(E entity);
}

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

const String clazzTpl = """
///{{{tableName}}}表
import 'package:fast_orm/fast_orm.dart';
import '{{{source}}}';

class {{{className}}} extends Dao<{{{entityName}}}>{
  static List propertyMapList =  {{{propertyList}}};
 
  ///初始化数据库
  static Future<bool> init() async{
      DBManager dbManager = DBManager();
      List<Map> maps = await dbManager.db.query("sqlite_master", where: " name = '{{{tableName}}}'");
      if(maps == null ||maps.length ==0){
           List<DBProperty> propertyList = List();
         for(Map map in propertyMapList){
            propertyList.add(DBProperty.fromJson(map));
            }
      dbManager.db.execute("CREATE TABLE {{{tableName}}}({{{createSql}}})");
      }
      return true;
  }
  
  ///查询表中所有数据
  static Future<List<{{{entityName}}}>> queryAll() async{
           DBManager dbManager = DBManager();
           List<{{{entityName}}}> entityList = List();
            {{{className}}} entityDao = {{{className}}}();
           List<Map> maps = await dbManager.db.query("{{{tableName}}}")  ;
           for(Map map in maps){
              entityList.add(entityDao.formMap(map));
           }
           return entityList;
  }
  
  ///增加一条数据
  static Future<bool> insert({{{entityName}}} entity) async{
       DBManager dbManager = DBManager();
        {{{className}}} entityDao = {{{className}}}();
       await dbManager.db.insert("{{{tableName}}}", entityDao.toMap(entity));
       return true;
  }
  
   ///增加多条条数据
  static Future<bool> insertList(List<{{{entityName}}}> entityList) async{
       DBManager dbManager = DBManager();
       List<Map> maps = List();
       {{{className}}} entityDao = {{{className}}}();
       for({{{entityName}}} entity in entityList){
            maps.add(entityDao.toMap(entity));
       }
       await dbManager.db.rawInsert("{{{tableName}}}", maps);
       return true;
  }
  
  ///更新数据
  static Future<int> update({{{entityName}}} entity) async {
    DBManager dbManager = DBManager();
     {{{className}}} entityDao = {{{className}}}();
    return await dbManager.db.update("{{{tableName}}}", entityDao.toMap(entity),
        where: '{{{primary}}} = ?', whereArgs: [entity.{{{primary}}}]);
  }
  
  ///删除数据
  static Future<int> delete({{{entityName}}} entity) async {
        DBManager dbManager = DBManager();
        return await dbManager.db.delete("{{{tableName}}}", where: '{{{primary}}} = ?', whereArgs: [entity.{{{primary}}}]);
  }
  
  ///map转为entity
  @override
  {{{entityName}}} formMap(Map map){
         {{{formMap}}}
  }
  
  ///entity转为map
  @override
  Map toMap({{{entityName}}} entity){
         {{{toMap}}}
 
  }
  
  @override
  String getTableName(){
      return "{{{tableName}}}";
  }
  
    {{{propertyClass}}}
  
  static Query queryBuild(){
       Query query = Query({{{className}}}());
       return query;
  }
}

///查询条件生成
class QueryProperty{
      String name;
      QueryProperty({this.name});
      QueryCondition equal(dynamic queryValue){
           QueryCondition queryCondition = QueryCondition();
           queryCondition.key= name;
           queryCondition.value = queryValue;
           return queryCondition;
      }
  }
""";
