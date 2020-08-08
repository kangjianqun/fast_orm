// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// DaoGenerator
// **************************************************************************

///asd表
import 'package:fast_orm/fast_orm.dart';
import 'package:fast_orm/asd.dart';

class ASDDao extends Dao<ASD> {
  static List propertyMapList = [
    {
      "name": "id",
      "type": {"value": "TEXT"},
      "isPrimary": true
    },
    {
      "name": "enable",
      "type": {"value": "INT"},
      "isPrimary": false
    }
  ];

  ///初始化数据库
  static Future<bool> init() async {
    DBManager dbManager = DBManager();
    List<Map> maps =
        await dbManager.db.query("sqlite_master", where: " name = 'asd'");
    if (maps == null || maps.length == 0) {
      List<DBProperty> propertyList = List();
      for (Map map in propertyMapList) {
        propertyList.add(DBProperty.fromJson(map));
      }
      dbManager.db.execute("CREATE TABLE asd(id TEXT PRIMARY KEY,enable INT)");
    }
    return true;
  }

  ///查询表中所有数据
  static Future<List<ASD>> queryAll() async {
    DBManager dbManager = DBManager();
    List<ASD> entityList = List();
    ASDDao entityDao = ASDDao();
    List<Map> maps = await dbManager.db.query("asd");
    for (Map map in maps) {
      entityList.add(entityDao.formMap(map));
    }
    return entityList;
  }

  ///增加一条数据
  static Future<bool> insert(ASD entity) async {
    DBManager dbManager = DBManager();
    ASDDao entityDao = ASDDao();
    await dbManager.db.insert("asd", entityDao.toMap(entity));
    return true;
  }

  ///增加多条条数据
  static Future<bool> insertList(List<ASD> entityList) async {
    DBManager dbManager = DBManager();
    List<Map> maps = List();
    ASDDao entityDao = ASDDao();
    for (ASD entity in entityList) {
      maps.add(entityDao.toMap(entity));
    }
    await dbManager.db.rawInsert("asd", maps);
    return true;
  }

  ///更新数据
  static Future<int> update(ASD entity) async {
    DBManager dbManager = DBManager();
    ASDDao entityDao = ASDDao();
    return await dbManager.db.update("asd", entityDao.toMap(entity),
        where: 'id = ?', whereArgs: [entity.id]);
  }

  ///删除数据
  static Future<int> delete(ASD entity) async {
    DBManager dbManager = DBManager();
    return await dbManager.db
        .delete("asd", where: 'id = ?', whereArgs: [entity.id]);
  }

  ///map转为entity
  @override
  ASD formMap(Map map) {
    ASD entity = ASD();
    entity.id = map['id'];
    entity.enable = map['enable'] != 0;
    return entity;
  }

  ///entity转为map
  @override
  Map toMap(ASD entity) {
    var map = Map<String, dynamic>();
    map['id'] = entity.id;
    map['enable'] = entity.enable ? 1 : 0;
    return map;
  }

  @override
  String getTableName() {
    return "asd";
  }

  static QueryProperty id = QueryProperty(name: 'id');
  static QueryProperty enable = QueryProperty(name: 'enable');

  static Query queryBuild() {
    Query query = Query(ASDDao());
    return query;
  }
}

///查询条件生成
class QueryProperty {
  String name;
  QueryProperty({this.name});
  QueryCondition equal(dynamic queryValue) {
    QueryCondition queryCondition = QueryCondition();
    queryCondition.key = name;
    queryCondition.value = queryValue;
    return queryCondition;
  }
}
