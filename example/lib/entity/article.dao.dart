// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// DaoGenerator
// **************************************************************************

///article表
import 'package:fast_orm/fast_orm.dart';
import 'article.dart';

class ArticleEntityDao extends Dao<ArticleEntity> {
  static List propertyMapList = [
    {
      "name": "id",
      "type": {"value": "TEXT"},
      "isPrimary": true
    },
    {
      "name": "article_title",
      "type": {"value": "TEXT"},
      "isPrimary": false
    }
  ];

  ///初始化数据库
  static Future<bool> init() async {
    DBManager dbManager = DBManager();
    List<Map> maps =
        await dbManager.db.query("sqlite_master", where: " name = 'article'");
    if (maps == null || maps.length == 0) {
      List<DBProperty> propertyList = List();
      for (Map map in propertyMapList) {
        propertyList.add(DBProperty.fromJson(map));
      }
      dbManager.db.execute(
          "CREATE TABLE article(id TEXT PRIMARY KEY,article_title TEXT)");
    }
    return true;
  }

  ///查询表中所有数据
  static Future<List<ArticleEntity>> queryAll() async {
    DBManager dbManager = DBManager();
    List<ArticleEntity> entityList = List();
    ArticleEntityDao entityDao = ArticleEntityDao();
    List<Map> maps = await dbManager.db.query("article");
    for (Map map in maps) {
      entityList.add(entityDao.formMap(map));
    }
    return entityList;
  }

  ///增加一条数据
  static Future<bool> insert(ArticleEntity entity) async {
    DBManager dbManager = DBManager();
    ArticleEntityDao entityDao = ArticleEntityDao();
    await dbManager.db.insert("article", entityDao.toMap(entity));
    return true;
  }

  ///增加多条条数据
  static Future<bool> insertList(List<ArticleEntity> entityList) async {
    DBManager dbManager = DBManager();
    List<Map> maps = List();
    ArticleEntityDao entityDao = ArticleEntityDao();
    for (ArticleEntity entity in entityList) {
      maps.add(entityDao.toMap(entity));
    }
    await dbManager.db.rawInsert("article", maps);
    return true;
  }

  ///更新数据
  static Future<int> update(ArticleEntity entity) async {
    DBManager dbManager = DBManager();
    ArticleEntityDao entityDao = ArticleEntityDao();
    return await dbManager.db.update("article", entityDao.toMap(entity),
        where: 'id = ?', whereArgs: [entity.id]);
  }

  ///删除数据
  static Future<int> delete(ArticleEntity entity) async {
    DBManager dbManager = DBManager();
    return await dbManager.db
        .delete("article", where: 'id = ?', whereArgs: [entity.id]);
  }

  ///map转为entity
  @override
  ArticleEntity formMap(Map map) {
    ArticleEntity entity = ArticleEntity();
    entity.id = map['id'];
    entity.title = map['article_title'];
    return entity;
  }

  ///entity转为map
  @override
  Map toMap(ArticleEntity entity) {
    var map = Map<String, dynamic>();
    map['id'] = entity.id;
    map['article_title'] = entity.title;
    return map;
  }

  @override
  String getTableName() {
    return "article";
  }

  static QueryProperty id = QueryProperty(name: 'id');
  static QueryProperty title = QueryProperty(name: 'article_title');

  static Query queryBuild() {
    Query query = Query(ArticleEntityDao());
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
